-- Imports
---@type EnemyUtils
local enemy_utils = include("lib/enemy_utils.lua")

---@type SpellsLib
local spells_lib = include("spells/spells.lua")

-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")




local attackable_states = {
    NORMAL = 0,
    FALLING = 1,
    FALLEN = 2,
}

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
    self.move_speed = character_info.move_speed
    self.bonepauseframes = character_info.bone_delay
    self.boneslideframes = character_info.bone_speed
    self.frames_between_actions = character_info.frames_between_actions


    self.attackable_state = attackable_states.NORMAL
    self.can_attack = true
    self:set_explosion_behavior(4, 1, false)
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)
    self.animation:set_state("SPAWN")
    self.bone = nil


    self.action_move = enemy_utils.hop_adjacent(self, 2, self.move_speed, after_hop, action_attack)

    self.defense_rule = Battle.DefenseRule.new(0, DefenseOrder.Always)
    self.defense_rule.can_block_func = function(judge, attacker, defender)
        local attacker_hit_props = attacker:copy_hit_props()
        if attacker_hit_props.damage >= 10 then
            if (self.attackable_state == attackable_states.NORMAL) then
                self.animation:set_state("FALL_APART")
                self.animation:on_frame(2, function()
                    self.attackable_state = attackable_states.FALLEN
                    self:toggle_hitbox(false)
                end)
                self.attackable_state = attackable_states.FALLING
                self.set_current_action(self.action_fallen)
                if (self.bone and not self.bone:is_deleted()) then
                    self.bone.spawn_teleport_dust()
                    self.bone:erase()
                    self.can_attack = true
                end
            end
        end

    end
    self:add_defense_rule(self.defense_rule)

    enemy_utils.use_enemy_framework(self)
    self.init_func = function()
        self.set_current_action(enemy_utils.wait)
        self.animation:set_state("IDLE")
        self.animation:on_complete(function()
            action_attack(self)
        end)
    end

    self.action_fallen = function(frame)
        if (frame == 140) then
            self.set_current_action(self.action_move)
            self.attackable_state = attackable_states.NORMAL
            self:toggle_hitbox(true)
        end
    end
end

function after_hop(character)
    character.animation:set_state("IDLE")
    character.animation:set_playback(Playback.Loop)
end

function action_attack(character)
    if (character.can_attack) then
        if (character.bolts == 0) then
            character.set_current_action(character.action_move)
        end
        character.set_current_action(enemy_utils.wait)
        character.animation:set_state("THROW")
        character.animation:on_frame(3, function()
            character.bone = spells_lib.spawn_bone(character, character:get_tile(character:get_facing(), 1),
                character.damage)
            character.can_attack = false
        end)
        character.animation:on_complete(function()
            character.animation:set_state("IDLE")
            character.animation:set_playback(Playback.Loop)
            character.set_current_action(character.action_move)
        end)
    else
        character.set_current_action(character.action_move)
    end
end

return package_init
