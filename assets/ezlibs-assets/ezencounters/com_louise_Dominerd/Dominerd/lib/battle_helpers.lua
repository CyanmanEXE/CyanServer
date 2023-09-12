--Functions for easy reuse in scripts
--Version 1.1

---@class BattleHelpers
battle_helpers = {}

local teleport_texture = Engine.load_texture(_folderpath .. "teleport.png")
local teleport_anim = _folderpath .. "teleport.animation"

-- #region Visual effects

---@param field #reference to battlefield
---@param tile #tile to spawn the visual artifact on
---@param texture #texture to use
---@param animation_path #path to animation
---@param animation_state #state to use
---@param position_x #offsetX
---@param position_y #offsetY
function battle_helpers.spawn_visual_artifact(field, tile, texture, animation_path, animation_state, position_x,
                                              position_y)
    local visual_artifact = Battle.Artifact.new()
    visual_artifact:set_texture(texture, true)
    local anim = visual_artifact:get_animation()
    anim:load(animation_path)
    anim:set_state(animation_state)
    anim:on_complete(function()
        visual_artifact:delete()
    end)
    visual_artifact:sprite():set_offset(position_x, position_y)
    anim:refresh(visual_artifact:sprite())
    field:spawn(visual_artifact, tile:x(), tile:y())
    return visual_artifact
end

function battle_helpers.spawn_teleport_dust(entity)
    battle_helpers.spawn_visual_artifact(entity:get_field(), entity:get_tile(), teleport_texture, teleport_anim,
        "MEDIUM_TELEPORT_FROM",
        0, 0)
end

function battle_helpers.spawn_afterimage(entity, anim_path)
    local art = battle_helpers.spawn_visual_artifact(entity:get_field(), entity:get_tile(), entity:get_texture(),
        anim_path,
        "WARP_OUT",
        0, 0)
    art:sprite():set_color_mode(ColorMode.Multiply)
    local color = Color.new(40, 40, 120, 255)
    local sprite = art:sprite()
    art.update_func = function(self)
        sprite:set_color(color)
    end
end

-- #endregion

-- #region Movement Checks

battle_helpers.can_move_to_func = function(tile, entity)
    if not tile:is_walkable() or tile:get_team() ~= entity:get_team() or
        tile:is_reserved({ entity:get_id(), entity._reserver }) then
        return false
    end

    local has_character = false

    tile:find_characters(function(c)
        if c:get_id() ~= entity:get_id() then
            has_character = true
        end
        return false
    end)

    tile:find_obstacles(function(c)
        if c:get_id() ~= entity:get_id() then
            has_character = true
        end
        return false
    end)

    return not has_character
end


battle_helpers.can_move_to_func_front_row = function(tile)
    if not tile:is_walkable() or tile:get_team() ~= self:get_team() or
        tile:is_reserved({ self:get_id(), self._reserver }) then
        return false
    end

    local has_character = false

    tile:find_characters(function(c)
        if c:get_id() ~= self:get_id() then
            has_character = true
        end
        return false
    end)

    if tile:get_tile(Direction.Left, 1):get_team() == self:get_team() then
        has_character = true
    end

    return not has_character
end


battle_helpers.can_move_to_func_target_enemy = function(tile)
    if not tile:is_walkable() or tile:get_team() ~= self:get_team() or
        tile:is_reserved({ self:get_id(), self._reserver }) then
        return false
    end

    local has_enemy = false
    local x = 0
    while x < 6 do
        if tile:get_tile(Direction.Left, x):is_edge() then
            return has_enemy
        end
        tile:get_tile(Direction.Left, x):find_characters(function(c)
            if c:get_id() ~= self:get_id() then
                has_enemy = true
            end
            return false
        end)
        x = x + 1
    end
    return has_enemy
end

battle_helpers.is_occupied = function(tile, entity)
    if tile:is_reserved({ entity:get_id(), entity._reserver }) then
        return false
    end

    local has_character = false

    tile:find_characters(function(c)
        if c:get_id() ~= entity:get_id() then
            has_character = true
        end
        return false
    end)

    tile:find_obstacles(function(c)
        if c:get_id() ~= entity:get_id() then
            has_character = true
        end
        return false
    end)

    return not has_character
end

-- #endregion

-- #region movements

function battle_helpers.jump_to_target_row(character, jump_speed, jump_height)

    local field = character:get_field()
    local target = battle_helpers.find_target(character)
    local my_tile = character:get_tile()
    local y = target:get_tile():y();
    local tile_array = {}
    for x = 1, 6, 1 do
        local prospective_tile = field:tile_at(x, y)
        if battle_helpers.can_move_to_func(prospective_tile, character) and
            my_tile ~= prospective_tile then
            table.insert(tile_array, prospective_tile)
        end
    end

    if #tile_array == 0 then return false end
    local target_tile = tile_array[math.random(1, #tile_array)]
    if target_tile then
        target_tile:reserve_entity_by_id(character:get_id())
        moved = character:jump(target_tile, jump_height, frames(jump_speed), frames(0), ActionOrder.Immediate, nil)
    end
    return moved
end

function battle_helpers.move_at_random(character)

    local field = character:get_field()
    local my_tile = character:get_tile()
    local tile_array = {}
    for x = 1, 6, 1 do
        for y = 1, 3, 1 do
            local prospective_tile = field:tile_at(x, y)
            if battle_helpers.can_move_to_func(prospective_tile, character) and
                my_tile ~= prospective_tile then
                table.insert(tile_array, prospective_tile)
            end
        end
    end

    if #tile_array == 0 then return false end
    target_tile = tile_array[math.random(1, #tile_array)]
    if target_tile then
        moved = character:teleport(target_tile, ActionOrder.Immediate)
    end
    return moved
end

-- This function moves the character to an adjacent tile.
function battle_helpers.move_random_adjacent(character)
    local field = character:get_field()
    local my_tile = character:get_tile()
    local tile_array = {}
    local adjacent_tiles = { my_tile:get_tile(Direction.Up, 1),
        my_tile:get_tile(Direction.Down, 1),
        my_tile:get_tile(Direction.Left, 1),
        my_tile:get_tile(Direction.Right, 1)
    }
    for index, prospective_tile in ipairs(adjacent_tiles) do
        if battle_helpers.can_move_to_func(prospective_tile, character) and
            my_tile ~= prospective_tile then
            table.insert(tile_array, prospective_tile)
        end
    end
    if #tile_array == 0 then return false end
    target_tile = tile_array[math.random(1, #tile_array)]
    if target_tile then
        moved = character:teleport(target_tile, ActionOrder.Immediate)
    end
    return moved
end

-- #endregion

-- #region logic
function battle_helpers.getNextTile(entity)
    local target_character = battle_helpers.find_target(entity)
    if not (target_character) then
        return entity:get_tile()
    end
    local target_character_tile = target_character:get_current_tile()
    local tile = entity:get_current_tile()
    local target_movement_tile = tile
    if tile:y() < target_character_tile:y() then
        target_movement_tile = tile:get_tile(Direction.Down, 1)
    end
    if tile:y() > target_character_tile:y() then
        target_movement_tile = tile:get_tile(Direction.Up, 1)
    end
    return target_movement_tile;
end

function battle_helpers.find_target(self)
    local field = self:get_field()
    local team = self:get_team()
    local target_list = field:find_characters(function(other_character)
        return other_character:get_team() ~= team
    end)
    if #target_list == 0 then
        print("No targets found!")
        return self
    end
    local target_character = target_list[1]
    return target_character
end

function battle_helpers.getRandomAdjacentTile(entity)

    local target_character = battle_helpers.find_target(entity)
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
        if (battle_helpers.is_tile_free_for_movement(tile, entity)) then
            return tile
        end
    end

    return target_movement_tile;

end

function battle_helpers.getDirTowardsTarget(entity)
    local target_character = battle_helpers.find_target(entity)
    if not (target_character) then
        return entity:get_tile()
    end
    local target_character_tile = target_character:get_current_tile()
    local tile = entity:get_tile()

    if tile:x() < target_character_tile:x() then
        return Direction.Right
    end
    if tile:x() > target_character_tile:x() then
        return Direction.Left
    end
    if tile:y() < target_character_tile:y() then
        return Direction.Down
    end
    if tile:y() > target_character_tile:y() then
        return Direction.Up
    end
    return entity:get_facing();
end

---Checks if the tile in 2 given directions is free and returns that direction
function battle_helpers.get_free_direction(tile, direction1, direction2)
    if (not tile:get_tile(direction1, 1):is_edge()) then
        return direction1
    else return direction2
    end
end

function battle_helpers.is_tile_free_for_movement(tile, character)
    --Basic check to see if a tile is suitable for a chracter of a team to move to

    if tile:get_team() ~= character:get_team() or tile:is_reserved({ character:get_id(), character._reserver }) then
        return false
    end
    if (tile:is_edge()) then
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

-- #endregion

--#region Utils

--shuffle function to provide some randomness
function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function battle_helpers.Tiletostring(tile)
    return "Tile: [" .. tostring(tile:x()) .. "," .. tostring(tile:y()) .. "]"
end

function battle_helpers.directiontostring(dir)

    if dir == Direction.Up then return "Up"
    elseif dir == Direction.Down then return "Down"
    end
end

-- #endregion Utils

return battle_helpers
