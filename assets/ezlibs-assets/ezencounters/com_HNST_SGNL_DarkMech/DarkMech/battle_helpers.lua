--Functions for easy reuse in scripts
--Borrowed from louise's Bunny virus, modified for DarkMech
--Version 1.1

-- Holds a table of stunned characters
local stunned_characters = { }
-- Holds a table of characters currently being targeted for attack by a virus in the DarkMech family
local targeted_characters = { }

battle_helpers = {}

-- This function spawns a visual effect that will remove itself once the effect animation completes.
function battle_helpers.spawn_visual_artifact(field, tile, texture, animation_path, animation_state, position_x,
                                              position_y, layer, direction, palette)
    local visual_artifact = Battle.Artifact.new()
    visual_artifact:set_texture(texture, true)
    local anim = visual_artifact:get_animation()
    anim:load(animation_path)
    anim:set_state(animation_state)
    anim:on_complete(function()
        visual_artifact:delete()
    end)
    if layer then visual_artifact:sprite():set_layer(layer) end
    if direction then visual_artifact:set_facing(direction) end
    if palette then visual_artifact:set_palette(palette) end
    visual_artifact:set_offset(position_x, position_y)
    anim:refresh(visual_artifact:sprite())
    field:spawn(visual_artifact, tile)
end

-- This functions handle the spawning of the afterimages for the slide to an enemy.
function battle_helpers.spawn_afterimages(self, slide_frames)
    local field = self:get_field()
    local distance = slide_frames / 2
    if distance < 2 then return false end

    -- Internal function creates the afterimage artifacts necessary and deletes them when done.
    local function create_afterimages(offset_and_tile)
        local offset = offset_and_tile[1]
        local tile = offset_and_tile[2]
        local texture = Engine.load_texture(_folderpath .. "battle.png")
        local palette = Engine.load_texture(_folderpath .. "afterimage.png")
        local afterimage_main = Battle.Artifact.new()
        local afterimage_arm = Battle.Artifact.new()
        afterimage_main:set_texture(texture, true)
        afterimage_arm:set_texture(texture, true)
        afterimage_main:set_palette(palette)
        afterimage_arm:set_palette(palette)
        local anim = afterimage_main:get_animation()
        local anim_arm = afterimage_arm:get_animation()
        anim:load(_folderpath .. "battle.animation")
        anim_arm:load(_folderpath .. "battle_arm.animation")
        anim:set_state("SLASH_AFTERIMAGE")
        anim_arm:set_state("SLASH_AFTERIMAGE")
        anim:on_frame(3, function()
            afterimage_main:hide()
            afterimage_arm:hide()
        end)
        anim:on_frame(4, function()
            afterimage_main:reveal()
            afterimage_arm:reveal()
        end)
        anim:on_complete(function()
            afterimage_main:delete()
            afterimage_arm:delete()
        end)
        afterimage_main:set_facing(self:get_facing())
        afterimage_arm:set_facing(self:get_facing())
        afterimage_main:set_offset(offset.x, offset.y-4)
        afterimage_arm:set_offset(offset.x, offset.y-4)
        afterimage_main:sprite():set_layer(1)
        afterimage_arm:sprite():set_layer(1)
        field:spawn(afterimage_main, tile)
        field:spawn(afterimage_arm, tile)
    end
    
    -- component keeps the timing in sync with movement.
    -- frame_counter keeps track of the frames
    -- start_frame exists because odd-distance slides produce a slight delay on afterimages starting
    -- positions is simply used to keep track of prior positions, 
    -- as an afterimage is spawned in the tile where DarkMech just was.
    local component = Battle.Component.new(self, Lifetimes.Local)
    local frame_counter = 1
    local start_frame = 1
    if distance % 2 ~= 0 then
        start_frame = 3
    end
    local positions = { }
    
    -- func_index keeps track of what to do for what frame of animation, as the afterimages loop in a 4-frame pattern.
    component.update_func = function(component, dt)
        local func_index = ((frame_counter - start_frame) % 4) + 1
        
        if frame_counter >= start_frame then
            if func_index == 1 then
                positions[1] = { self:get_tile_offset(), self:get_current_tile() }
                
            elseif func_index == 2 then
                positions[2] = { self:get_tile_offset(), self:get_current_tile() }
                create_afterimages(positions[1])
                
            elseif func_index == 3 then
                create_afterimages(positions[2])
                
            elseif func_index == 4 then
                -- If the slide is 3/4 over
                if frame_counter > (slide_frames * .75) then component:eject() end
                
            end
        end
        
        frame_counter = frame_counter + 1
    end
    
    self:register_component(component)
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

-- This function returns the corresponding tile if self can slide to the character, nil otherwise.
battle_helpers.can_slide_to_character_func = function(character, self)
    local tile = character:get_tile(self:get_facing_away(), 1)
    local tile2 = character:get_tile(self:get_facing(), 1)
    
    local slide_tile = nil
    while(tile and not slide_tile) do
        local has_character = false

        tile:find_characters(function(c)
            if c:get_id() ~= self:get_id() then
                has_character = true
            end
            return false
        end)
        tile:find_obstacles(function(c)
            if c:get_id() ~= self:get_id() then
                has_character = true
            end
            return false
        end)
        if not has_character then slide_tile = tile end
        
        if not tile:is_walkable() or tile:is_reserved({ self:get_id(), self._reserver }) then slide_tile = nil end
        
        if tile2 ~= tile then
            tile = tile2
        else
            tile = nil
        end
    end
    
    return slide_tile
end

-- This function gets the character an adjacent movable tile.
function battle_helpers.get_random_adjacent(character)
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
    return target_tile
end

--Updates how much time is left on characters' stuns. Should be called every frame
--Character_lock exists to ensure this is only called once per frame.
--Essentially it binds the function to a single character.
local character_lock = nil
function battle_helpers.update(char)
    local field  = char:get_field()
    if character_lock and character_lock:is_deleted() then 
        -- print("Character lock deleted.")
        character_lock = nil 
    end
    if not character_lock then
        -- print("Character lock set.")
        character_lock = char
    end
    if char == character_lock then
        for team, characters in pairs(stunned_characters) do
            for character, time in pairs(characters) do
                characters[character] = time - 1
                if characters[character] == 1 then characters[character] = nil end
            end
        end
    end
end

--Removes a stunned character from the table
function battle_helpers.remove_stunned_character(character)
    stunned_characters[character:get_team()][character] = nil
end

--Checks if there are any stunned and not already targeted enemies whatsoever
function battle_helpers.any_stunned_enemy(char)
    for team, characters in pairs(stunned_characters) do
        if team ~= char:get_team() then
            for enemy, time in pairs(characters) do
                if not targeted_characters[team][enemy] then
                    return true
                end
            end
        end
    end
    return false
end

--Finds the first stunned character that is not on our team, is already targeted, and has been stunned longest
--And the tile to slide to reach them, see battle_helpers.can_slide_to_character_func
function battle_helpers.get_first_accessible_stunned(char)
    local first_accessible_stunned = nil
    local first_accessible_stunned_time = nil
    local target_tile = nil
    for team, characters in pairs(stunned_characters) do
        if team ~= char:get_team() then
            for enemy, time in pairs(characters) do
                if not targeted_characters[team][enemy] then
                    local slide_tile = battle_helpers.can_slide_to_character_func(enemy, char)
                    if slide_tile then
                        if not first_accessible_stunned then 
                            first_accessible_stunned = enemy
                            first_accessible_stunned_time = time
                            target_tile = slide_tile
                        elseif first_accessible_stunned_time > time then 
                            first_accessible_stunned = enemy
                            first_accessible_stunned_time = time
                            target_tile = slide_tile
                        end
                    end
                end
            end
        end
    end
    
    return first_accessible_stunned, target_tile
end

--Adds or removes enemy from targeted_characters table
function battle_helpers.toggle_targeted_enemy(enemy, bool)
    if bool == true then
        targeted_characters[enemy:get_team()][enemy] = true
    else
        targeted_characters[enemy:get_team()][enemy] = false
    end
end

--Setup
--Resets tables, variables, and registers enemies for the stun callback
function battle_helpers.init(char)
    local field  = char:get_field()
    
    character_lock = nil
    stunned_characters = { [Team.Red] = {}, [Team.Blue] = {}, [Team.Other] = {} }
    targeted_characters = { [Team.Red] = {}, [Team.Blue] = {}, [Team.Other] = {} }
    
    --This callback registration is necessary until a character:is_stunned() type function exists.
    --It's all characters so that DarkMechs of any team can reference it.
    local all_characters = field:find_characters(function(character) 
        return true
    end)
    for k, character in pairs(all_characters) do
        character:register_status_callback(Hit.Stun, function()
            --This is the current ONB stun time. In the future this should be the stun_time of whoever stunned them...
            --Ideally is_stunned will exist by then.
            stunned_characters[character:get_team()][character] = 120 
        end)
    end
end

return battle_helpers
