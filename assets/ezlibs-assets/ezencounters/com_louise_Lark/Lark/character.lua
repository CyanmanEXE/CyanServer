-- Imports
---@type BattleHelper
local battle_helpers = include("battle_helpers.lua")
---@type FxHelper
local fx_helper = include("fx.lua")
-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")
---@type WideSht
local widesht = include("WideSht/entry.lua")


--possible states for character
local states = { IDLE = 1, MOVE = 2, WAIT = 3 }
local debug = false

function debug_print(str)
    if debug then
        print("[oldSTOVE] " .. str)
    end
end

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
    self.cracks_panels = (character_info.cracks_panels)
    self:share_tile(false)
    self:set_explosion_behavior(4, 1, false)
    self:set_offset(0, 0)
    self:set_palette(Engine.load_texture(character_info.palette))
    self:set_element(Element.Aqua)
    self.animation:set_state("SPAWN")
    self.frame_counter = 0
    self.started = false
    self.idle_frames = character_info.frames_between_actions
    self.moves = 0
    --Select move direction
    self.move_direction = Direction.Up
    self.move_speed = character_info.move_speed
    self.widespeed = character_info.widespeed
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)

    self.idle_state = "IDLE"
    if (self:get_rank() == Rank.NM) then
        self.idle_state = "FAST_IDLE"
    end




    ---state idle
    ---@param frame number
    self.action_idle = function(frame)
        if (frame == 1) then
            self.animation:set_state(self.idle_state)
            self.animation:set_playback(Playback.Loop)
        end
        if (frame == self.idle_frames) then
            ---choose move direction.

            self.set_state(states.MOVE)
        end
    end




    ---state move
    ---@param frame number
    self.action_move = function(frame)
        if (frame == 1) then
            local target_tile = getNextTile(self)
            if (not is_tile_free_for_movement(target_tile, self)) then
                self.attack()
                self.set_state(states.WAIT)
            else
                self.moves = self.moves + 1
            end
            local nextDir = battle_helpers.get_direction_towards_tile(self:get_current_tile(), target_tile)

            local moveSpeed = self.move_speed
            if (nextDir == Direction.Up or nextDir == Direction.Down) then
                moveSpeed = moveSpeed // 2
            end
            self:slide(target_tile, frames(moveSpeed), frames(0), ActionOrder.Immediate, nil)
            target_tile:reserve_entity_by_id(self:get_id())
        end
        if (frame >= self.move_speed // 2 and not self:is_sliding()) then
            if (self.moves > 2) then
                -- once LARK travelled 3 tiles, attack
                self.attack()
            else
                self.set_state(states.MOVE)
            end
        end
    end

    ---state wait
    ---@param frame number
    self.action_wait = function(frame)
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
            self.animation:set_state(self.idle_state)
            self.animation:set_playback(Playback.Loop)
            self.set_state(states.MOVE)
        else
            --- On every frame, we will call the state action func.
            local action_func = actions[self.state]
            action_func(self.frame_counter)
        end
    end

    self.attack_find_query = function(s)
        if s then
            return s:get_name() == "WideSht"
        end
        return false
    end

    self.attack = function()
        local attacks = self:get_field():find_entities(self.attack_find_query)
        if #attacks > 0 then self.set_state(states.MOVE) self.moves = 2 - math.random(1, 4) return end
        if (self:get_tile():y() == 2) then
            self.moves = 0
            self.set_state(states.MOVE)
            self.animation:set_state(self.idle_state)
            self.animation:set_playback(Playback.Loop)
            return
        end
        self.set_state(states.WAIT)
        self.moves = 0
        self.has_attacked_once = true
        self.animation:set_state("ATTACK")
        self.animation:on_frame(1, function()
            self.guard = false
            self:toggle_counter(true)
        end)
        self.animation:on_frame(3, function()
            self:toggle_counter(false)
            props = {
                damage = self.damage,
                element = Element.Aqua,
                speed = self.widespeed
            }
            self.flames = widesht.card_create_action(self, props)

        end)

        self.animation:on_complete(function()
            self.set_state(states.MOVE)
            self.animation:set_state(self.idle_state)
            self.animation:set_playback(Playback.Loop)
        end)
    end


    function Tiletostring(tile)
        return "Tile: [" .. tostring(tile:x()) .. "," .. tostring(tile:y()) .. "]"
    end

    function directiontostring(dir)

        if dir == Direction.Up then return "Up"
        elseif dir == Direction.Down then return "Down"
        end
    end

end

function getNextTile(entity)

    local target_character = find_target(entity)
    if not (target_character) then
        return entity:get_tile()
    end
    local target_character_tile = target_character:get_current_tile()
    local tile = entity:get_current_tile()
    local target_movement_tile = tile
    local rand = math.random(1, 6)

    local facing = tile:get_tile(entity:get_facing(), 1)
    local facing_away = tile:get_tile(entity:get_facing_away(), 1)
    local up = tile:get_tile(Direction.Up, 1)
    local down = tile:get_tile(Direction.Down, 1)

    local prospective_tiles = {}

    --prioritize moving towards target
    if (tile:y() ~= target_character_tile:y()) then
        if tile:y() < target_character_tile:y() then
            table.insert(prospective_tiles, tile:get_tile(Direction.Down, 1))
        end
        if tile:y() > target_character_tile:y() then
            table.insert(prospective_tiles, tile:get_tile(Direction.Up, 1))
        end
    end


    -- other directions
    table.insert(prospective_tiles, facing)
    table.insert(prospective_tiles, facing_away)
    table.insert(prospective_tiles, up)
    table.insert(prospective_tiles, down)
    shuffle(prospective_tiles)
    for index, tile in ipairs(prospective_tiles) do
        if (is_tile_free_for_movement(tile, entity)) then
            return tile
        end
    end

    return target_movement_tile;
end

--shuffle function to provide some randomness
function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

--find a target character
function find_target(self)
    local field = self:get_field()
    local team = self:get_team()
    local target_list = field:find_characters(function(other_character)
        return other_character:get_team() ~= team
    end)
    if #target_list == 0 then
        return
    end
    local target_character = target_list[1]
    return target_character
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

    if tile:get_team() ~= character:get_team() or tile:is_reserved({ character:get_id(), character._reserver }) then
        return false
    end
    if (tile:is_edge() or not tile:is_walkable()) then
        return false
    end
    local occupants = tile:find_entities(function(ent)
        if (ent:get_health() <= 0) then
            return false
        end
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
