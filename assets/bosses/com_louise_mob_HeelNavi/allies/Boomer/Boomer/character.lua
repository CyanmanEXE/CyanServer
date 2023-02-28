-- Imports
---@type BattleHelper
local battle_helpers = include("battle_helpers.lua")
local panelgrab_chip = include("PanelGrab/entry.lua")
-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")
local BOOMERANG_SOUND = Engine.load_audio(_folderpath .. "boomer.ogg")
local BOOMERANG_SPRITE = Engine.load_texture(_folderpath .. "boomer.png")
local BOOMERANG_ANIM = _folderpath .. "boomer.animation"
local effects_texture = Engine.load_texture(_folderpath .. "effect.png")
local effects_anim = _folderpath .. "effect.animation"

--possible states for character
local states = { IDLE = 1, MOVE = 2, WAIT = 3 }
---@param self Entity
function package_init(self, character_info)
    -- Required function, main package information
    -- Load extra resources
    local base_animation_path = CHARACTER_ANIMATION
    self:set_texture(CHARACTER_TEXTURE)
    self.animation = self:get_animation()
    self.animation:load(base_animation_path)

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
    self.panelgrabs = character_info.panelgrabs
    self.boomer_speed = character_info.boomer_speed
    self.animation:set_state("SPAWN")
    self.frame_counter = 0
    self.started = false
    self.idle_frames = 45
    --Select Boomer move direction
    self.move_direction = Direction.Up
    self.move_speed = character_info.move_speed
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)
    self.reached_edge = false
    self.has_attacked_once = false
    self.guard = true
    self.end_wait = false

    self:set_air_shoe(true)
    self:set_float_shoe(true)

    self.defense_rule = Battle.DefenseRule.new(0, DefenseOrder.Always)
    local defense_texture = Engine.load_texture(_folderpath .. "guard_hit.png")
    local defense_animation = _folderpath .. "guard_hit.animation"
    local defense_audio = Engine.load_audio(_folderpath .. "tink.ogg")
    self.defense_rule.can_block_func = function(judge, attacker, defender)
        local attacker_hit_props = attacker:copy_hit_props()

        if (self.guard) then

            if attacker_hit_props.flags & Hit.Breaking == Hit.Breaking then
                --cant block breaking hits
                return
            end
            judge:block_impact()
            judge:block_damage()
            local artifact = Battle.Spell.new(self:get_team())
            artifact:set_texture(defense_texture)
            local anim = artifact:get_animation()
            anim:load(defense_animation)
            anim:set_state("DEFAULT")
            anim:refresh(artifact:sprite())
            anim:on_complete(function()
                artifact:erase()
            end)
            self:get_field():spawn(artifact, self:get_tile())
            Engine.play_audio(defense_audio, AudioPriority.High)
        end
    end
    self:add_defense_rule(self.defense_rule)


    ---state idle
    ---@param frame number
    self.action_idle = function(frame)
        if (frame == self.idle_frames) then
            ---choose move direction.
            self.animation:set_state("IDLE")
            self.animation:set_playback(Playback.Loop)
            self.end_wait = false
            self.turn()
        end
    end

    self.turn = function()
        self.move_direction = Direction.reverse(self.move_direction)

        self.set_state(states.MOVE)
    end

    ---state move
    ---@param frame number
    self.action_move = function(frame)
        if (frame == 1) then
            local target_tile = self:get_tile(self.move_direction, 1)
            if (not is_tile_free_for_movement(target_tile, self)) then
                if (target_tile:is_edge()) then
                    self.reached_edge = true
                else
                    if (not is_tile_free_for_movement(self:get_tile(Direction.Up, 1), self) and
                        not is_tile_free_for_movement(self:get_tile(Direction.Down, 1), self)) then
                        --detect if stuck
                        self.reached_edge = true
                    else
                        self.turn()
                    end
                end
            end
            self:slide(target_tile, frames(self.move_speed), frames(0), ActionOrder.Immediate, nil)
        end
        if (frame > 2 and not self:is_sliding()) then
            if (self.reached_edge) then
                -- if at the edge(or stuck), throw boomerang
                self.throw_boomerang()
                self.set_state(states.WAIT)
                self.reached_edge = false
            else
                -- keep moving to edge.
                if (self:get_tile():y() == 2 and self.has_attacked_once and self.panelgrabs > 0) then
                    local grab = panelgrab_chip.card_create_action(self)
                    self:card_action_event(grab, ActionOrder.Involuntary)
                    self.panelgrabs = self.panelgrabs - 1
                end
                self.set_state(states.MOVE)
                self.reached_edge = false
            end

        end
    end

    ---state wait
    ---@param frame number
    self.action_wait = function(frame)
        if (not self.end_wait) then
            self.wait_frame_counter = 0
        end
        if (frame == 12) then
            self:toggle_counter(false)
        end
        self.wait_frame_counter = self.wait_frame_counter + 1
        if (self.wait_frame_counter == 60) then
            self.animation:set_state("RECOVER")
            self.set_state(states.IDLE)
            self.guard = true
        end
    end

    --utility to set the update state, and reset frame counter
    ---@param state number
    self.set_state = function(state)
        self.state = state
        self.frame_counter = 0
    end

    local actions = { [1] = self.action_idle, [2] = self.action_move, [3] = self.action_wait }

    self.update_func = function()
        self.frame_counter = self.frame_counter + 1
        if not self.started then
            --- this runs once the battle is started
            self.current_direction = self:get_facing()
            self.started = true
            self.set_state(states.IDLE)

        else
            --- On every frame, we will call the state action func.
            local action_func = actions[self.state]
            action_func(self.frame_counter)
        end
    end

    self.throw_boomerang = function()

        self.animation:set_state("THROW")


        self.has_attacked_once = true
        self.animation:on_frame(3, function()
            self.guard = false
            self:toggle_counter(true)
        end)
        self.animation:on_complete(function()
            Engine.play_audio(BOOMERANG_SOUND, AudioPriority.High)
            boomerang(self)

            self.set_state(states.WAIT)
            self.animation:set_state("WAIT")
            self.animation:set_playback(Playback.Loop)
            self.end_wait = false
        end)
    end

    function Tiletostring(tile)
        return "Tile: [" .. tostring(tile:x()) .. "," .. tostring(tile:y()) .. "]"
    end

    ---Boomerang!
    ---@param user Entity
    function boomerang(user)
        local field = user:get_field()
        ---@class Spell
        local spell = Battle.Spell.new(user:get_team())
        local spell_animation = spell:get_animation()
        local start_tile = user:get_tile(user:get_facing(), 1)
        -- Spell Hit Properties
        spell:set_hit_props(
            HitProps.new(
                user.damage,
                Hit.Impact | Hit.Flinch,
                Element.Wood,
                user:get_context(),
                Drag.None
            )
        )
        spell:set_facing(user:get_facing())
        spell_animation:load(BOOMERANG_ANIM)
        spell_animation:set_state("DEFAULT")
        spell_animation:set_playback(Playback.Loop)
        spell:set_texture(BOOMERANG_SPRITE)
        spell_animation:refresh(spell:sprite())
        spell:sprite():set_layer(-2)
        -- Starting direction is user's facing
        spell.direction = user:get_facing()
        spell.userfacing = user:get_facing()
        spell.boomer_speed = user.boomer_speed
        spell.next_tile = start_tile:get_tile(spell.direction, 1)
        spell.update_func = function(self, dt)
            if (spell.next_tile:is_edge()) then
                ---need to change a direction.
                if (spell.direction == Direction.Left or spell.direction == Direction.Right) then
                    local end_of_field =
                    (spell.userfacing == Direction.Left and spell.next_tile:x() == 7) or
                        (spell.userfacing == Direction.Right and spell.next_tile:x() == 0)
                    if (end_of_field) then
                        spell:erase()
                        if (not user:is_deleted()) then
                            user.animation:on_complete(function()
                                user.end_wait = true
                            end)
                        end
                    end
                    --next direction is up or down
                    spell.direction = get_free_direction(spell:get_current_tile(), Direction.Up, Direction.Down)
                else if (spell.direction == Direction.Up or spell.direction == Direction.Down) then
                        --next direction is left or right
                        spell.direction = get_free_direction(spell:get_current_tile(), Direction.Left, Direction.Right)
                    end
                end
            end
            spell:slide(spell.next_tile, frames(spell.boomer_speed), frames(0), ActionOrder.Voluntary, nil)
            spell.next_tile = spell:get_current_tile():get_tile(spell.direction, 1)
            spell:get_current_tile():attack_entities(self)
        end
        spell.collision_func = function(self, other)
        end
        spell.attack_func = function(self, other)
            battle_helpers.spawn_visual_artifact(self:get_field(), self:get_tile(), effects_texture, effects_anim, "WOOD"
                , 0, 0)
        end
        spell.delete_func = function(self)
            self:erase()
        end
        spell.can_move_to_func = function(tile)
            return true
        end
        field:spawn(spell, start_tile)
    end
end

---Checks if the tile in 2 given directions is free and returns that direction
function get_free_direction(tile, direction1, direction2)
    if (not tile:get_tile(direction1, 1):is_edge()) then
        return direction1
    else return direction2

    end
end

function is_tile_free_for_movement(tile, character)
    --Basic check to see if a tile is suitable for a chracter of a team to move to

    if tile:get_team() ~= character:get_team() then
        return false
    end
    if (tile:is_edge()) then
        return false
    end
    local occupants = tile:find_entities(function(ent)
        if (Battle.Character.from(ent) ~= nil or Battle.Obstacle.from(ent) ~= nil) then
            return true
        else
            return false
        end
    end)
    if #occupants == 1 and occupants[1]:get_id() == character:get_id() then
        return true
    end
    if #occupants > 0 then
        return false
    end

    return true
end

return package_init
