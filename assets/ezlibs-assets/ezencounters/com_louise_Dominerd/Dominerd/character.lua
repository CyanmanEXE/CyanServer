-- Imports
---@type EnemyUtils
local enemy_utils = include("lib/enemy_utils.lua")

---@type BattleHelpers
local battle_helpers = include("lib/battle_helpers.lua")

local geddon = include("geddon/entry.lua")
-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.png")
local CRUNCH_SFX = Engine.load_audio(_folderpath .. "crunch.ogg")

local HIT_SFX = Engine.load_audio(_folderpath .. "hit.ogg")

--current attacker, only 1 enemy can begin an attack per frame.
local current_attacker_id = nil
local current_attacker_cooldown = 0

local geddon_used = false

---@param self Entity
function package_init(self, character_info)
    -- Required function, main package information
    local base_animation_path = CHARACTER_ANIMATION
    self:set_texture(CHARACTER_TEXTURE)
    self.animation = self:get_animation()
    self.animation:load(base_animation_path)
    -- Set up character meta
    self:set_palette(Engine.load_texture(character_info.palette))
    self:set_name(character_info.name)
    self.name = character_info.name
    self:set_health(character_info.hp)
    self:set_height(character_info.height)
    self.damage = (character_info.damage)
    self:set_element(character_info.element)
    self:set_explosion_behavior(4, 1, false)
    self.animation:set_state("SPAWN")
    self.move_speed = character_info.move_speed
    self.has_geddon = character_info.has_geddon
    self.geddon_countdown = character_info.geddon_countdown
    self:share_tile(false)
    self:set_float_shoe(true)
    self.vulnerable = false

    self.defense_rule = Battle.DefenseRule.new(0, DefenseOrder.Always)
    self.defense_rule.can_block_func = function(judge, attacker, defender)
        local attacker_hit_props = attacker:copy_hit_props()
        if self.vulnerable or attacker_hit_props.flags & Hit.Breaking == Hit.Breaking then
            --takes full damage from breaking
            return
        end
        judge:block_damage()
        -- damage turns to 1
        self:set_health(self:get_health() - 1)

    end
    self:add_defense_rule(self.defense_rule)

    self.reserved_tile = nil
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)

    self.can_move_to_func = function(tile)
        return true
    end

    self.delete_func = function(self)
        if (self:get_id() == current_attacker_id) then
            current_attacker_id = nil
        end
    end

    self.battle_start_func = function()
        current_attacker_id = nil
        geddon_used = false
    end

    local ref = self
    self.action_move = enemy_utils.move_toward_enemy_row(self, self.move_speed, attack_logic, nil)
    self.wait = enemy_utils.wait
    self.pause_after_attack = enemy_utils.wait_for_frames(self, 60, function()
        self.set_current_action(self.action_move)
    end)
    self.play_idle_anim = function()
        self.animation:set_state("IDLE")
        self.animation:set_playback(Playback.Loop)
    end

    self.update_hook = function()
        if (not geddon_used and self.geddon_countdown > 0 and self:get_team() == self:get_current_tile():get_team()) then
            self.geddon_countdown = self.geddon_countdown - 1
            if (self.geddon_countdown == 0) then
                local chip = geddon.card_create_action(self, props)
                props = {}
                geddon_used = true
                self:card_action_event(chip, ActionOrder.Immediate)
            end
        end
        if (self:get_id() == current_attacker_id) then
            current_attacker_cooldown = current_attacker_cooldown - 1
            if (current_attacker_cooldown == 0) then
                current_attacker_id = nil
            end
        end

    end

    enemy_utils.use_enemy_framework(self)
    self.init_func = function()
        self.set_current_action(self.action_move)
        self.play_idle_anim()
    end
end

function should_move_to(character, tile)
    local characters = tile:find_characters(function(c)
        return c:get_team() == character:get_team()
    end)
    return #characters
end

function attack_logic(character)

    if (current_attacker_id ~= nil) then
        return
    end
    battle_helpers.spawn_teleport_dust(character)
    local target_char = battle_helpers.find_target(character)
    local target_tile = target_char:get_tile()

    character.set_current_action(character.wait)
    if (should_move_to(character, target_tile)) then
        character.reserved_tile = character:get_current_tile()
        character.vulnerable = true
        current_attacker_id = character:get_id()
        current_attacker_cooldown = 40
        character:teleport(target_tile, ActionOrder.Immediate, function()
            character:set_float_shoe(false)
        end)
        character.animation:set_state("OPEN")
        character.animation:on_frame(1, function()
            character.reserved_tile:reserve_entity_by_id(character:get_id())
        end)
        character.animation:on_complete(function()
            character.animation:set_state("BITE")
            character.animation:on_frame(1, function()
                character:toggle_counter(true)
            end)
            character.animation:on_frame(2, function()
                create_bite(character, character.damage)
            end)
            character.animation:on_complete(function()
                character:teleport(character.reserved_tile)
                character:toggle_counter(false)
                character.vulnerable = false
                character.animation:set_state("IDLE")
                character.animation:set_playback(Playback.Loop)
                character.set_current_action(character.pause_after_attack)
            end)
        end)
    end
end

create_bite = function(user, damage)
    local field = user:get_field()
    Engine.play_audio(CRUNCH_SFX, AudioPriority.Highest)
    local spell = Battle.Spell.new(user:get_team())
    local direction = user:get_facing()

    local spell_animation = spell:get_animation()
    spell.frames = 0
    spell:set_facing(direction)
    spell:set_hit_props(
        HitProps.new(
            damage,
            Hit.Impact | Hit.Flash | Hit.Flinch,
            Element.None,
            user:get_id(),
            Drag.None
        )
    )
    spell.target_hit = false
    spell:set_facing(user:get_facing())
    local tile = user:get_tile()
    field:spawn(spell, tile)

    spell.update_func = function(self, dt)
        spell.frames = spell.frames + 1
        self:get_current_tile():attack_entities(self)
        spell:erase()
    end

    spell.collision_func = function(self, other)
    end

    spell.can_move_to_func = function(self, other)
        return true
    end

    spell.battle_end_func = function(self)
        spell:erase()
    end

    spell.attack_func = function(self, other)
        Engine.play_audio(HIT_SFX, AudioPriority.Highest)
    end
end

return package_init
