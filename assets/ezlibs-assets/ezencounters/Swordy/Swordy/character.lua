-- Imports
---@type EnemyUtils
local enemy_utils = include("lib/enemy_utils.lua")

---@type BattleHelpers
local battle_helpers = include("lib/battle_helpers.lua")

local sword_spell = include("sword.lua")

local areagrab = include("com_claris_card_areagrab/entry.lua")
-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.png")

local longswords = 0

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
    self.dash_speed = 10


    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)

    --Swordy Sword node
    self.swordNode = self:create_node() --Nodes automatically attach to what you create them off of. No need to spawn!
    self.swordNode:set_texture(Engine.load_texture(_folderpath .. "sword.png")) --Just set their texture...
    self.swordNode_anim = Engine.Animation.new(_folderpath .. "sword.animation") --And they have no get_animation, so we create one...
    self.swordNode:set_layer(1) --Set their layer, they're already a sprite...
    self.swordNode_anim:set_state("SPAWN")
    self.swordNode_anim:refresh(self.swordNode)
    self.swordNode:enable_parent_shader(true)

    self.battle_start_func = function()
        longswords = 0
    end

    local ref = self
    --This is how we animate nodes.
    self.animate_component = Battle.Component.new(self, Lifetimes.Battlestep)
    self.animate_component.update_func = function(self, dt)
        ref.swordNode_anim:update(dt, ref.swordNode)
    end
    self:register_component(self.animate_component)
    -- actions for states


    self.action_move = enemy_utils.move_toward_enemy_row(self, self.move_speed, attack_logic, attack_logic)
    self.action_wait = enemy_utils.wait
    self.action_wait_areagrab = enemy_utils.wait_for_frames(self, 2, function()
        self.set_current_action(self.action_move)
    end)
    self.action_wait_dash = enemy_utils.wait_for_frames(self, self.dash_speed, function()
        self.set_current_action(self.action_move)
    end)


    self.play_idle_anim = function()
        self.animation:set_state("IDLE")
        self.swordNode_anim:set_state("IDLE")
        self.swordNode_anim:set_playback(Playback.Loop)
        self.animation:set_playback(Playback.Loop)
    end

    enemy_utils.use_enemy_framework(self)
    self.init_func = function()
        self.set_current_action(self.action_move)
        self.play_idle_anim()
    end
end

function attack_logic(character)
    local target_enemy = battle_helpers.find_target(character)
    local target_enemy_x = target_enemy:get_tile():x()
    local character_x = character:get_tile():x()
    local dir = character:get_facing_away()
    local end_lag = 0
    if (target_enemy_x < character_x) then
        dir = Direction.Left
    elseif (target_enemy_x > character_x) then
        dir = Direction.Right
    else
        end_lag = 30
    end
    local target_tile = character:get_tile(dir, 1)

    if (
        battle_helpers.is_tile_free_for_movement(target_tile, character) and not should_widesword(character, target_tile)
        ) then
        character:slide(target_tile, frames(character.dash_speed), frames(end_lag), ActionOrder.Involuntary, function()
            target_tile:reserve_entity_by_id(character:get_id())
        end)
        character.set_current_action(character.action_wait_dash)
    else
        if (should_widesword(character, target_tile)) then
            character.animation:set_state("WIDESWORD")
            character.swordNode_anim:set_state("WIDESWORD")
            character.animation:on_frame(2, function()
                character:toggle_counter(true)
            end)
            character.animation:on_frame(4, function()
                character:toggle_counter(false)
                sword_spell.create_slash(character, character.damage, "WIDE")
            end)
            character.animation:on_complete(function()
                character.play_idle_anim()
                character.set_current_action(character.action_move)
            end)
            character.set_current_action(character.action_wait)
        elseif (
            tile_has_enemies(target_tile:get_tile(character:get_facing(), 1), character) or
                tile_has_enemies(target_tile:get_tile(character:get_facing(), 2), character)) then
            character.animation:set_state("LONGSWORD")
            character.swordNode_anim:set_state("LONGSWORD")
            character.animation:on_frame(6, function()
                character:toggle_counter(true)
            end)
            character.animation:on_frame(8, function()
                character:toggle_counter(false)
                sword_spell.create_slash(character, character.damage, "LONG")
                longswords = longswords + 1
            end)
            character.animation:on_complete(function()
                character.play_idle_anim()
                if (longswords >= 3) then
                    if (can_grab_more_area(character)) then
                        local areagrabChip = areagrab.card_create_action(character)
                        character.set_current_action(character.action_wait_areagrab)
                        character:card_action_event(areagrabChip, ActionOrder.Involuntary)
                    else
                        character.set_current_action(character.action_move)
                    end
                    longswords = 0

                else
                    character.set_current_action(character.action_move)
                end
            end)
            character.set_current_action(character.action_wait)
        else
            character.set_current_action(character.action_move)
        end
    end
end

function should_widesword(character, center_tile)
    local tile_up = center_tile:get_tile(Direction.Up, 1)
    local tile_down = center_tile:get_tile(Direction.Down, 1)
    return tile_has_enemies(center_tile, character) or tile_has_enemies(tile_up, character) or
        tile_has_enemies(tile_down, character)
end

function can_grab_more_area(user)
    local x_max = 5
    if (user:get_facing() == Direction.Left) then
        x_max = 2
    end
    if (user:get_field():tile_at(x_max, 2):get_team() == user:get_team()) then
        return false
    end
    return true
end

---@param tile Tile
---@param user Entity
function tile_has_enemies(tile, user)
    if not tile then return false end
    local enemies = tile:find_characters(function(char)
        if char:get_team() ~= user:get_team() then
            return true
        end
        return false
    end)
    return #enemies >= 1
end

return package_init
