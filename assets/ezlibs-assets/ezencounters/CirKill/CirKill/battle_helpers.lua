--Functions for easy reuse in scripts
--Version 1.0

---@class BattleHelpers
battle_helpers = {}

-- This function returns a target enemy.
function battle_helpers.find_target(self)
    local field = self:get_field()
    local team = self:get_team()
    local target_list = field:find_characters(function(other_character)
        return other_character:get_team() ~= team
    end)
    if #target_list == 0 then
        --print("No targets found!")
        return
    end
    local target_character = target_list[1]
    return target_character
end

-- This function spawns a visual effect that will remove itself once the effect animation completes.
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
end

-- This function returns true if the entity can move to the tile, false otherwise.
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

--This function moves the character towards a position.
function battle_helpers.move_towards_row(character, row)
    local field = character:get_field()
    local my_tile = character:get_tile()
    local tile_array = {}
    local target_tile = nil

    -- Check which tile the bunny needs to move towards to reach megaman.
    if (row < my_tile:y()) then
        target_tile = my_tile:get_tile(Direction.Up, 1)
    else
        target_tile = my_tile:get_tile(Direction.Down, 1)
    end

    if battle_helpers.can_move_to_func(target_tile, character) then
        moved = character:teleport(target_tile, ActionOrder.Immediate)
        return moved
    else
        --if cant move to prospective tile, move to a random tile left or right.
        local alternate_tiles = { my_tile:get_tile(Direction.Left, 1),
            my_tile:get_tile(Direction.Right, 1) }

        for index, prospective_tile in ipairs(alternate_tiles) do
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

end

return battle_helpers
