-- Imports
---@type BattleHelper
local battle_helpers = include("battle_helpers.lua")

---@type FxHelper
local fx_helper = include("fx_helper.lua")


local HeroSword = include("chipattacks/HeroSword/entry.lua")
local Lilbomb = include("chipattacks/Lilbomb/entry.lua")
local Cannonball = include("chipattacks/Cannonball/entry.lua")

-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.png")
local SFX_SUMMON = Engine.load_audio(_folderpath .. "SummonAlly.ogg")
local states = { DEFAULT = 1, PREPARE_CLOSE_ATTACK = 2, PREPARE_RANGE_ATTACK = 3 }
local shine_fx = Engine.load_texture(_folderpath .. "shine.png")
local shine_anim = _folderpath .. "shine.animation"
local spawn_fx = Engine.load_texture(_folderpath .. "spawn.png")
local spawn_anim = _folderpath .. "spawn.animation"



local enemies = {
    "included.Volgear",
    "included.Piranha",
    "included.Boomer",
}



local chips = {
    "Lilbomb", "Cannonball", "Herosword"
}

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
    self.sword_dmg = character_info.sword_dmg;
    self.ball_dmg = character_info.ball_dmg;
    self.bomb_dmg = character_info.bomb_dmg;
    self:share_tile(false)
    self:set_explosion_behavior(4, 1, true)
    self:set_offset(0, 0)
    self.animation:set_state("IDLE")
    self.frame_counter = 0
    self.started = false
    self.move_speed = character_info.move_speed
    self.moves = 0
    self:set_element(Element.Aqua)

    --name replacement
    if (self:get_rank() == Rank.V2) then
        enemies[3] = "included.Gloomer"
    elseif (self:get_rank() == Rank.V3) then
        enemies[3] = "included.Doomer"
    end

    ---stores entity id and column that enemy occupies. -1, means nil
    self.minions = { [1] = { -1, 4 }, [2] = { -1, 5 } }
    self.available_columns = {}
    if (self:get_facing() == Direction.Right) then
        self.minions = { [1] = { -1, 2 }, [2] = { -1, 3 } }
    end


    ---state idle
    ---@param frame number
    self.action_idle = function(frame)
        if (frame == self.move_speed) then
            ---choose move direction.
            if (self.moves < 7) then
                battle_helpers.move_to_back_col(self)
                self.set_state(states.DEFAULT)
                self.animation:set_state("PLAYER_IDLE")
            elseif (self.moves >= 7) then
                summon(self)
                self.moves = 0
            end
            if (self.moves == 5) then
                self.chip = chips[math.random(1, #chips)]
                if (self.chip == "Herosword") then

                    self.set_state(states.PREPARE_CLOSE_ATTACK)
                else
                    self.set_state(states.PREPARE_RANGE_ATTACK)
                end
            end
            self.moves = self.moves + 1
        end
    end


    ---state move
    ---@param frame number
    self.prepare_close_attack_action = function(frame)
        if (frame == self.move_speed) then
            battle_helpers.move_to_front_col(self)
            self.animation:set_state("PLAYER_IDLE")

        elseif (frame == self.move_speed + 10) then
            local props = Battle.CardProperties.new()
            props.damage = self.sword_dmg
            local action = HeroSword.card_create_action(self, props)
            action.action_end_func = function()
                self.set_state(states.DEFAULT)
            end
            self:card_action_event(action, ActionOrder.Involuntary)

        end
    end

    ---state prepare_range_attack_action
    --- move can be started from anywhere.
    ---@param frame number
    self.prepare_range_attack_action = function(frame)
        if (frame == 1) then
            local props = Battle.CardProperties.new()

            local target = find_target(self)

            local action = nil
            if (self.chip == "Cannonball") then
                props.damage = self.ball_dmg
                action = Cannonball.card_create_action(self, props, target:get_tile())
            elseif (self.chip == "Lilbomb") then
                props.damage = self.bomb_dmg
                action = Lilbomb.card_create_action(self, props, target:get_tile())
            end
            action.action_end_func = function()
                self.set_state(states.DEFAULT)
                print("action_end")
            end
            self:card_action_event(action, ActionOrder.Involuntary)

        end
    end

    --utility to set the update state, and reset frame counter
    ---@param state number
    self.set_state = function(state)
        self.state = state
        self.frame_counter = 0
    end

    local actions = { [1] = self.action_idle, [2] = self.prepare_close_attack_action,
        [3] = self.prepare_range_attack_action }

    self.update_func = function()
        self.frame_counter = self.frame_counter + 1
        if not self.started then
            --- this runs once the battle is started
            self.current_direction = self:get_facing()
            self.started = true
            self.set_state(states.DEFAULT)

        else
            --- On every frame, we will call the state action func.
            local action_func = actions[self.state]
            action_func(self.frame_counter)
        end
    end

    ---Deleting Heel Navi deletes his minions as well.
    self.delete_func = function()

        for key, value in pairs(self.minions) do
            if (self.minions[key][1] ~= -1) then
                local minion = self:get_field():get_entity(self.minions[key][1])
                if (not minion:is_deleted()) then
                    minion:delete()
                end
            end
        end
    end



    function summon(character)
        -- refresh minions
        local canSummon = false
        for key, value in pairs(self.minions) do
            if (self.minions[key][1] ~= -1) then
                if (character:get_field():get_entity(self.minions[key][1]):is_deleted()) then
                    self.minions[key][1] = -1
                    canSummon = true
                else
                end
            elseif (self.minions[key][1] == -1) then
                canSummon = true
            end
        end
        if (canSummon) then
            character.animation:set_state("SUMMON")
            character.animation:on_frame(10, function()
                spawn_ally(character)
            end);
            character.animation:on_complete(function()
                character.animation:set_state("PLAYER_IDLE")
                character.set_state(states.DEFAULT)
            end)
        else
            character.animation:set_state("CHEER")
            character.animation:on_complete(function()
                character.animation:set_state("PLAYER_IDLE")
                character.set_state(states.DEFAULT)
            end)
        end
    end

    function spawn_ally(owner)

        local num = math.random(1, #enemies)
        local randomenemytype = enemies[num]
        local enemy = Battle.Character.from_package(randomenemytype, owner:get_team(), owner:get_rank())
        local spawnColumn = insert_into_available(enemy:get_id())
        local spawntile = battle_helpers.choose_random_tile(owner, spawnColumn)
        if (spawntile == nil) then
            return
        end
        fx_helper.create_basic_effect(owner:get_field(), spawntile, spawn_fx, spawn_anim, "DEFAULT")
        fx_helper.create_hit_effect(owner:get_field(), spawntile, shine_fx, shine_anim, "SHINE", SFX_SUMMON)
        owner:get_field():spawn(enemy, spawntile)
    end

    function insert_into_available(id)
        for key, value in pairs(self.minions) do
            if (self.minions[key][1] == -1) then
                self.minions[key][1] = id
                return value[2]
            end
        end
    end

    function tiletostring(tile)
        return "Tile: [" .. tostring(tile:x()) .. "," .. tostring(tile:y()) .. "]"
    end

    --find a target character
    function find_target(self)
        local field = self:get_field()
        local team = self:get_team()
        local target_list = field:find_characters(function(other_character)
            return other_character:get_team() ~= team and not other_character:is_deleted()
        end)
        if #target_list == 0 then
            return
        end
        local target_character = target_list[1]
        return target_character
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
end

return package_init
