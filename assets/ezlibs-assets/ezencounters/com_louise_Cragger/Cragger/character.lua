-- Imports
---@type EnemyUtils
local enemy_utils = include("lib/enemy_utils.lua")

---@type GolemHit
local golemhit = include("golemhit/entry.lua")

-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.png")

---@param self Entity
function package_init(self, character_info)
    -- Required function, main package information
    local base_animation_path = CHARACTER_ANIMATION
    self:set_texture(CHARACTER_TEXTURE)
    self.animation = self:get_animation()
    self.animation:load(base_animation_path)
    -- Set up character meta
    self:set_name(character_info.name)
    self.name = character_info.name
    self:set_health(character_info.hp)
    self:set_height(character_info.height)
    self.damage = (character_info.damage)
    self:set_element(character_info.element)
    self:set_palette(Engine.load_texture(character_info.palette))
    self:set_explosion_behavior(4, 1, false)
    self.animation:set_state("SPAWN")
    self.type = character_info.type
    self.base_move_speed = character_info.move_speed
    self.frames_before_attack = 30

    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)

    self.defense_rule = Battle.DefenseRule.new(0, DefenseOrder.Always)
    local defense_audio = Engine.load_audio(_folderpath .. "craggerdmg.ogg")
    self.defense_rule.can_block_func = function(judge, attacker, defender)
        local attacker_hit_props = attacker:copy_hit_props()
        if (attacker_hit_props.damage < 5) then
            Engine.play_audio(defense_audio, AudioPriority.Highest)
            return
        end

        if attacker_hit_props.flags & Hit.Breaking == Hit.Breaking then
            --dies from breaking
            self:set_health(0)
            return
        end
        judge:block_damage()
        flash_red(self)

        self:set_health(self:get_health() - (attacker_hit_props.damage // 2))
        Engine.play_audio(defense_audio, AudioPriority.Highest)

    end
    self:add_defense_rule(self.defense_rule)

    --Cragger Arm node
    self.arm = self:create_node() --Nodes automatically attach to what you create them off of. No need to spawn!
    self.arm:set_texture(Engine.load_texture(_folderpath .. "arm.png")) --Just set their texture...
    self.arm_anim = Engine.Animation.new(_folderpath .. "arm.animation") --And they have no get_animation, so we create one...
    self.arm:set_layer(-5) --Set their layer, they're already a sprite...
    self.arm_anim:set_state("SPAWN")
    self.arm_anim:refresh(self.arm)
    self.arm:enable_parent_shader(true)

    local ref = self
    --This is how we animate nodes.
    self.animate_component = Battle.Component.new(self, Lifetimes.Battlestep)
    self.animate_component.update_func = function(self, dt)
        ref.arm_anim:update(dt, ref.arm)
    end
    self:register_component(self.animate_component)
    -- actions for states

    self.set_anims = function(stateName)
        self.animation:set_state(stateName)
        self.arm_anim:set_state(stateName)
    end

    self.start_attack = function(character)
        local props = {
            damage = character.damage
        }
        golemhit.card_create_action(character, props)
    end

    if (self:get_rank() <= Rank.V2) then
        -- v1/v2 doesnt move lol
        self.action_move = enemy_utils.wait_for_frames(self, self.base_move_speed * 3, self.start_attack)
    else
        self.action_move = enemy_utils.move_at_random(self, 0, self.base_move_speed, self.start_attack,
            enemy_utils.TeleportStyle.TeleportDust)
    end

    self.action_wait = enemy_utils.wait
    self.thunderPattern = nil

    enemy_utils.use_enemy_framework(self)

    self.idle = function()
        self.set_anims("IDLE")
        self.animation:set_playback(Playback.Loop)
        self.arm_anim:set_playback(Playback.Loop)
    end
    self.init_func = function()
        self.set_current_action(self.action_move)
        self.set_anims("IDLE")
        self.move_count = 10
        self.move_delay = self.base_move_speed * 1.2
        self.animation:set_playback(Playback.Loop)
    end
end

local red_tint = Color.new(255, 0, 0, 255)

function flash_red(character)
    if (character.flash_component) then
        return
    end
    local flash_component = Battle.Component.new(character, Lifetimes.Battlestep)
    flash_component.frame = 0
    flash_component.update_func = function(self)
        if (flash_component.frame % 4 == 0) then
            character:sprite():set_color(red_tint)
        end
        flash_component.frame = flash_component.frame + 1
        if (flash_component.frame > 30) then
            flash_component:eject()
            character.flash_component = nil
        end
    end
    character:register_component(flash_component)
    character.flash_component = flash_component
end

function create_warning_component(character)
    local warning_component = Battle.Component.new(character, Lifetimes.Battlestep)
    warning_component.update_func = function(self)
        for index, tile in ipairs(character.thunderPattern) do
            tile:highlight(Highlight.Flash)
        end
    end
    return warning_component
end

function create_effect(effect_texture, effect_animpath, effect_state, offset_x, offset_y, field, tile)
    local hitfx = Battle.Artifact.new()
    hitfx:set_facing(Direction.Right)
    hitfx:set_texture(effect_texture, true)
    hitfx:set_offset(offset_x, offset_y)
    local hitfx_sprite = hitfx:sprite()
    hitfx_sprite:set_layer(-99999)
    local hitfx_anim = hitfx:get_animation()
    hitfx_anim:load(effect_animpath)
    hitfx_anim:set_state(effect_state)
    hitfx_anim:refresh(hitfx_sprite)
    hitfx_anim:on_complete(function()
        hitfx:erase()
    end)
    field:spawn(hitfx, tile)

    return hitfx
end

return package_init
