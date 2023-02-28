local battle_helpers = include("battle_helpers.lua")
local character_animation = _folderpath .. "battle.animation"
local anim_speed = 1
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")
local areagrab_chip = include("AreaGrab/entry.lua")
local shockwave_sound = Engine.load_audio(_folderpath .. "shockwave.ogg")
local shockwave_sprite = Engine.load_texture(_folderpath .. "shockwave.png")
local shockwave_anim = "shockwave.animation"
local quake = Engine.load_audio(_folderpath .. "hammer.ogg")
local quakerCount = -1

--possible states for character
local states = { IDLE = 1, JUMP = 2, LAND = 3 }
-- Load character resources
---@param self Entity
function package_init(self, character_info)
    -- Required function, main package information

    local base_animation_path = character_animation
    self:set_texture(CHARACTER_TEXTURE)
    self.animation = self:get_animation()
    self.animation:load(base_animation_path)
    self.animation:set_playback_speed(anim_speed)
    -- Load extra resources
    -- Set up character meta
    self:set_name(character_info.name)
    self:set_health(character_info.hp)
    self:set_height(character_info.height)
    self.damage = (character_info.damage)
    self:share_tile(false)
    self:set_explosion_behavior(4, 1, false)
    self:set_offset(0, 0)
    self:set_palette(Engine.load_texture(character_info.palette))
    self.shockwave_anim = character_info.shockwave_anim
    self.has_areagrab = (character_info.has_areagrab)
    self.animation:set_state("SPAWN")
    self.frame_counter = 0
    self.frames_between_actions = character_info.frames_between_actions
    self.cascade_frame_index = character_info.cascade_frame
    self.started = false
    self.attack_count = 0
    self.jump_speed = 74
    if (self:get_rank() == Rank.NM) then
        self.jump_speed = 45
    end

    self.move_direction = Direction.Right
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)

    self:set_shadow(Shadow.Small)
    self:show_shadow(true)

    ---state idle
    ---@param frame number
    self.action_idle = function(frame)
        if (frame == self.frames_between_actions) then

            self.set_state(states.JUMP)
            local moved
            battle_helpers.jump_to_target_row(self, self.jump_speed)
            if (not moved) then
                self:jump(self:get_tile(), 140, frames(self.jump_speed), frames(0), ActionOrder.Immediate, nil)
            end
            self.animation:set_state("JUMP")
            self.animation:on_complete(function()
                --quaker not targetable in air.
                self:toggle_hitbox(false)
            end)
        end
    end

    ---state jump
    ---@param frame number
    self.action_jump = function(frame)

        if (self:get_facing() ~= self:get_tile():get_facing()) then
            self.animation:set_state("FLIP")
        end
        self:set_facing(self:get_tile():get_facing())
        if (frame == self.jump_speed - 1) then
            self.animation:set_state("LAND")
            self:toggle_hitbox(true)
            self:toggle_counter(true)
            self.animation:on_complete(function()
                self:toggle_counter(false);
            end)
        elseif (frame == self.jump_speed) then
            spawn_shockwave(self, self:get_tile():get_tile(self:get_facing(), 1), self:get_facing(), self.damage,
                shockwave_sprite, shockwave_anim,
                shockwave_sound, self.cascade_frame_index)
            self:shake_camera(4, 0.5)
            Engine.play_audio(quake, AudioPriority.Highest)
            -- cant configure root duration yet, commenting since it feels bad to play against.
            --root_all_enemies(self:get_team(), self:get_field())
            self.set_state(states.IDLE)

        end
    end

    ---state land
    ---@param frame number
    self.action_land = function(frame)
    end

    self.on_spawn_func = function(self)
        quakerCount = 0
    end

    self.battle_start_func = function(self)
        quakerCount = quakerCount + 1
        self.start_delay = quakerCount * 35
        if (quakerCount > 3) then
            quakerCount = -1
        end
    end
    --utility to set the update state, and reset frame counter
    ---@param state number
    self.set_state = function(state)
        self.state = state
        self.frame_counter = 0
    end

    local actions = { [1] = self.action_idle, [2] = self.action_jump, [3] = self.action_land }

    self.update_func = function()
        self.frame_counter = self.frame_counter + 1
        if not self.started then
            self.current_direction = self:get_facing()
            self.enemy_dir = self:get_facing()
            self.started = true
            self.set_state(states.IDLE)
            self.frame_counter = -self.start_delay
        else
            local action_func = actions[self.state]
            action_func(self.frame_counter)
        end
    end

    ---Used by quaker to shockwave
    ---@param owner Entity
    function spawn_shockwave(owner, tile, direction, damage, wave_texture, wave_animation, wave_sfx, cascade_frame_index)
        local owner_id = owner:get_id()
        local team = owner:get_team()
        local field = owner:get_field()
        local cascade_frame = cascade_frame_index
        local spawn_next
        local Tier = owner:get_rank()

        spawn_next = function()
            if not tile:is_walkable() then return end

            Engine.play_audio(wave_sfx, AudioPriority.Low)

            local spell = Battle.Spell.new(team)
            spell:set_facing(direction)
            spell:highlight_tile(Highlight.Solid)
            spell:set_hit_props(HitProps.new(damage, Hit.Flash | Hit.Flinch, Element.None, owner_id, Drag.new()))

            local sprite = spell:sprite()
            sprite:set_texture(wave_texture)
            sprite:set_layer(-1)

            local animation = spell:get_animation()
            animation:load(_folderpath .. wave_animation)
            animation:set_state("DEFAULT")
            animation:refresh(sprite)

            animation:on_frame(cascade_frame, function()
                tile = tile:get_tile(direction, 1)
                spawn_next()
            end, true)
            animation:on_complete(function() spell:erase() end)

            spell.update_func = function()
                spell:get_current_tile():attack_entities(spell)
            end

            field:spawn(spell, tile)
        end

        spawn_next()
    end

    ---function to create a spell to root all enemies
    ---@param team #The team of the attacker.
    function root_all_enemies(team, field)
        local target_list = field:find_characters(function(other_character)
            return other_character:get_team() ~= team
        end)
        for index, entity in ipairs(target_list) do
            local spell = Battle.Spell.new(team)
            spell:set_hit_props(HitProps.new(0, Hit.Root, Element.None, 0, Drag.new()))
            spell.update_func = function()
                print("Enemy Stunned")
                spell:get_current_tile():attack_entities(spell)
                spell:erase()
            end
            entity:get_field():spawn(spell, entity:get_tile())
        end
    end

    function tiletostring(tile)
        return "Tile: [" .. tostring(tile:x()) .. "," .. tostring(tile:y()) .. "]"
    end
end

return package_init
