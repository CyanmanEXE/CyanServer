-- Imports
---@type EnemyUtils
local enemy_utils = include("lib/enemy_utils.lua")

---@type BattleHelpers
local battle_helpers = include("lib/battle_helpers.lua")

---@type MobTracker
local mob_tracker = include("lib/mob_tracker.lua")

-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.png")
local EFFECT_TEXTURE = Engine.load_texture(_folderpath .. "lib/effect.png")
local EFFECT_ANIMPATH = _folderpath .. "lib/effect.animation"

local THUNDER_TEXTURE = Engine.load_texture(_folderpath .. "thunderball.png")
local THUNDER_ANIM = _folderpath .. "thunderball.animation"

local THUNDER_SFX = Engine.load_audio(_folderpath .. "thunder.ogg")

local attack_duration = 40

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
    self:set_shadow(Shadow.Small)
    self:show_shadow(true)
    self:set_float_shoe(true)
    self:set_air_shoe(true)
    self.animation:set_state("SPAWN")
    self.type = character_info.type

    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)

    self.in_attack = true

    self.base_move_speed = character_info.move_speed
    self.frames_before_attack = 30
    self.attack_end_time = 200

    self.can_move_to_func = function()
        if (self.in_attack) then
            return true
        end
    end

    self.random_teleport = function(frame)
        if (frame == 1) then
            battle_helpers.spawn_teleport_dust(self)
            battle_helpers.move_at_random(self)
            self.move_delay = self.base_move_speed * 0.85 ^ (10 - self.move_count)
        elseif (frame >= self.move_delay) then
            if (self.move_count ~= 0) then
                self.move_count = self.move_count - 1
                self.repeat_state()
            else
                start_attack(self)
                self.move_count = 10
            end
        end
    end

    self.action_move = self.random_teleport

    self.action_wait = enemy_utils.wait
    self.thunderPattern = nil

    self.get_thunder_pattern = function(type, center_tile)
        tiles = {}
        if (type == 1) then
            table.insert(tiles, center_tile:get_tile(Direction.Up, 1))
            table.insert(tiles, center_tile:get_tile(Direction.Down, 1))
            table.insert(tiles, center_tile:get_tile(Direction.Left, 1))
            table.insert(tiles, center_tile:get_tile(Direction.Right, 1))
        elseif (type == 2) then
            table.insert(tiles, center_tile:get_tile(Direction.UpLeft, 1))
            table.insert(tiles, center_tile:get_tile(Direction.UpRight, 1))
            table.insert(tiles, center_tile:get_tile(Direction.DownLeft, 1))
            table.insert(tiles, center_tile:get_tile(Direction.DownRight, 1))
        end
        return tiles
    end

    self.do_thunder_attack = function(self, type, teleport_after_end)
        if (teleport_after_end) then
            self.animation:set_state("ATTACKANDIDLE")

        else
            self.animation:set_state("ATTACK")
        end
        local flashy = self
        Engine.play_audio(THUNDER_SFX, AudioPriority.High)
        local props = {}
        props.damage = self.damage
        props.element = Element.Elec

        self.animation:on_frame(2, function()
            for index, value in ipairs(self.thunderPattern) do
                create_thunderball(self, props, value, self:get_team(),
                    self:get_field())
                flashy.warning_component:eject()
            end
        end)
        self.animation:on_frame(4, function()
            flashy:toggle_counter(false)
        end)
        self.animation:on_complete(function()
            if (teleport_after_end) then
                self:teleport(self.reserved_tile, ActionOrder.Immediate, nil)
                mob_tracker.advance_a_turn(self:get_team())
            else
                flashy:toggle_counter(true)
            end
            self.animation:set_state("IDLE")
            self.animation:set_playback(Playback.Loop)
        end)
    end

    self.action_attack = function(frame)
        if (frame == self.frames_before_attack - 10) then
            self:toggle_counter(true)
        end
        if (frame == self.frames_before_attack) then
            self:do_thunder_attack(self.type, self:get_rank() < Rank.V3)
        elseif (frame == self.frames_before_attack + attack_duration) then
            if (self:get_rank() > Rank.V2) then
                self.thunderPattern = self.get_thunder_pattern(self.type + 1, self:get_tile())
                self.warning_component = create_warning_component(self)
                self:register_component(self.warning_component)
                self:do_thunder_attack(self.type + 1, true)
                self.attack_end_time = self.frames_before_attack + attack_duration * 3
            else
                self.move_count = 9
                self.attack_end_time = self.frames_before_attack + attack_duration * 2
            end
        elseif (frame >= self.attack_end_time) then
            self.set_current_action(self.action_move)
        end
    end

    enemy_utils.use_enemy_framework(self)
    mob_tracker.enable_mob_tracker(self)

    self.init_func = function()
        self.set_current_action(self.action_move)
        self.animation:set_state("IDLE")
        self.move_count = 10
        self.move_delay = self.base_move_speed * 1.2
        self.animation:set_playback(Playback.Loop)
    end
end

function start_fast_move(character)
    character.set_current_action(character.action_fast_move)
end

function start_attack(character)
    if (not mob_tracker.is_active(character)) then
        character.move_count = math.random(8, 10)
        character.set_current_action(character.action_move)
        return
    end
    character.in_attack = true
    local target = battle_helpers.find_target(character)
    character.reserved_tile = character:get_current_tile()
    character.reserved_tile:reserve_entity_by_id(character:get_id())
    local target_tile = target:get_tile(target:get_facing(), 1)
    if (battle_helpers.is_occupied(target_tile, character)) then
        character:teleport(target_tile, ActionOrder.Immediate)
        character.set_current_action(character.action_attack)
        character.warning_component = create_warning_component(character)
        character.thunderPattern = character.get_thunder_pattern(character.type, target_tile)
        character:register_component(character.warning_component)
    else
        character.move_count = math.random(2, 4)
        character.set_current_action(character.action_move)
    end
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

function create_thunderball(owner, props, tile, team, field)
    local spawn_next
    spawn_next = function()
        if tile == nil or tile:is_edge() then return end

        local spell = Battle.Spell.new(team)
        local spell_sprite = spell:sprite()
        spell_sprite:set_layer(-5)
        spell_sprite:set_texture(THUNDER_TEXTURE, true)
        local spell_anim = spell:get_animation()
        spell_anim:load(THUNDER_ANIM)
        spell_anim:set_state("0")
        spell_anim:refresh(spell_sprite)
        spell:set_hit_props(HitProps.new(
            props.damage,
            Hit.Impact | Hit.Flinch | Hit.Stun,
            props.element,
            owner:get_context(),
            Drag.new())
        )

        local function randomize_offset()
            spell:set_offset(math.random(-30, 30), math.random(-30, 30))
        end

        spell_anim:on_frame(1, randomize_offset)
        spell_anim:on_frame(2, randomize_offset)
        spell_anim:on_frame(3, randomize_offset)
        spell_anim:on_frame(4, randomize_offset)
        spell_anim:on_frame(5, randomize_offset)
        spell_anim:on_frame(6, randomize_offset)
        spell_anim:on_frame(7, randomize_offset)
        spell_anim:on_frame(8, randomize_offset)
        spell_anim:on_frame(9, randomize_offset)
        spell_anim:on_frame(10, randomize_offset)
        spell_anim:on_frame(11, randomize_offset)
        spell_anim:on_frame(12, randomize_offset)

        spell_anim:on_complete(function() spell:erase() end)

        spell.update_func = function(self)
            self:get_current_tile():attack_entities(self)
        end

        spell.attack_func = function(self)
            -- Engine.play_audio(AUDIO_DAMAGE, AudioPriority.Highest)
            create_effect(EFFECT_TEXTURE, EFFECT_ANIMPATH, "ELEC", math.random(-5, 5), math.random(-5, 5), field,
                self:get_current_tile())
        end

        spell.can_move_to_func = function(tile)
            return true
        end

        field:spawn(spell, tile)
    end

    spawn_next()
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
