--Functions for easy reuse in enemy scripts
--Version 1.6


---@type BattleHelpers
local battle_helpers = include("battle_helpers.lua")

---@class EnemyUtils
action_library = {}

local debug = true

---@enum TeleportStyle
action_library.TeleportStyle = {
    None = 1,
    TeleportDust = 2,
    AfterImage = 3
}

function debug_print(msg)
    if (debug) then
        print("[EnemyUtils] " .. msg)
    end
end

--- Sets up some variables and the update_func for a basic enemy.
---@param character any
action_library.use_enemy_framework = function(character)
    character.frame_counter = 0
    character.init = false
    character.repeat_state = function()
        character.frame_counter = 0
    end

    character.update_func = function()
        character.frame_counter = character.frame_counter + 1
        if not character.init then
            --- this runs once the battle is started
            character.init_func()
            character.init = true
        else
            --- On every frame, we will call the current action func.
            if (character.update_hook) then
                character.update_hook()
            end
            character.current_action(character.frame_counter, character)
        end
    end

    --utility to set the current action, and reset frame counter
    ---@param action function
    character.set_current_action = function(action)
        character.current_action = action
        character.frame_counter = 0
    end
end


---Wait the specified frames then execute callback.
action_library.wait_for_frames = function(character, wait_frames, callback)
    return function(frame)
        if (frame == wait_frames) then
            callback(character)
        end
    end
end

---Blank state to wait indefinitely.
action_library.wait = function()

end
--- This action func will make the enemy move toward the enemy target.
---@param character character The character
---@param move_speed number move speed, in frames
---@param on_target_lined_up function callback function when enemy lines up with target
---@param on_stuck function? callback function when enemy can't move toward character
action_library.move_toward_enemy_row = function(character, move_speed, on_target_lined_up, on_stuck)

    return function(frame, character)
        local function check_lined_up()
            local target_tile = battle_helpers.getNextTile(character)
            if (character:get_tile():y() == target_tile:y()) then
                on_target_lined_up(character)
            else
                if (on_stuck) then
                    on_stuck(character)
                end
                character.repeat_state()
            end
        end

        if (frame == 1) then
            local target_tile = battle_helpers.getNextTile(character)
            if (not battle_helpers.is_tile_free_for_movement(target_tile, character)) then
                check_lined_up()
                return
            end
            character:slide(target_tile, frames(move_speed), frames(0), ActionOrder.Immediate, function()
                target_tile:reserve_entity_by_id(character:get_id())
            end)
        end
        if (frame >= move_speed and not character:is_sliding()) then
            check_lined_up()
        end
    end
end

---This action func will make the enemy jump on a random tile on its field, trying to line up with the enemy if possible
---@param character any character performing action
---@param delay number in frames before jumping.
---@param jump_speed number the jump lasts
---@param jump_height number the jump height
---@param on_landing function callback func when landing.
---@return function
action_library.jump_toward_enemy = function(character, delay, jump_speed, jump_height, on_landing)

    return function(frame)
        if (frame == delay) then
            local moved = battle_helpers.jump_to_target_row(character, jump_speed, jump_height)
            if (not moved) then
                -- jump in place.
                character:jump(character:get_tile(), jump_height, frames(jump_speed), frames(0), ActionOrder.Immediate,
                    nil)
            end
            character.animation:set_state("JUMP")
            character.animation:on_complete(function()
                --not targetable in air.
                character:toggle_hitbox(false)
            end)
        elseif frame == delay + jump_speed - 4 then
            character:toggle_hitbox(true)
        elseif frame == delay + jump_speed then
            on_landing(character)
        end
    end
end

---This action func will make the enemy hop to a random adjacent panel. (Bunny)
---@param character any character performing action
---@param iterations number number of times to move before callback
---@param interval number number of frames to pause before next teleport
---@param after_hop function callback after hopping
---@param on_complete function callback func
---@return function
action_library.hop_adjacent = function(character, iterations, interval, after_hop, on_complete)
    local action = {}
    action.iterations = iterations;
    action.interval = math.max(2, interval)
    action.action_func = function(frame)
        if (frame == 1) then
            action.iterations = action.iterations - 1
            local anim = character:get_animation()
            anim:set_state("WARP_OUT")
            battle_helpers.spawn_teleport_dust(character)
            anim:on_complete(function()
                battle_helpers.move_random_adjacent(character)
                anim:set_state("WARP_IN")
                anim:on_complete(function()
                    after_hop(character)
                end)
            end)
        elseif (frame == interval) then
            if (action.iterations > 0) then
                character.repeat_state()
            else
                on_complete(character)
                action.iterations = iterations;
            end
        end
    end
    return action.action_func
end
---This action func will make the enemy warp to a random panel on its side.
---@param character any character performing action
---@param iterations number number of times to move before callback
---@param interval number number of frames to pause before next teleport
---@param on_complete function callback func
---@param teleport_style? TeleportStyle TeleportStyle of the action
---@return function
action_library.move_at_random = function(character, iterations, interval, on_complete, teleport_style, anim_path)
    local action = {}
    action.iterations = iterations;
    action.interval = math.max(2, interval)
    action.action_func = function(frame)
        if (frame == 1) then
            if (teleport_style == action_library.TeleportStyle.TeleportDust) then
                battle_helpers.spawn_teleport_dust(character)
            elseif (teleport_style == action_library.TeleportStyle.AfterImage) then
                battle_helpers.spawn_afterimage(character, anim_path)
            end
            battle_helpers.move_at_random(character)
        elseif (frame == action.interval) then
            if (action.iterations > 0) then
                action.iterations = action.iterations - 1
                character.repeat_state()
            else
                on_complete(character)
                action.iterations = iterations;
            end
        end
    end

    return action.action_func
end

action_library.slide_random_adjacent = function(character, iterations, move_speed, on_complete)
    local action = {}
    action.iterations = iterations;
    action.move_speed = math.max(2, move_speed)

    action.action_func = function(frame)
        if (frame == 1) then
            local target_tile = battle_helpers.getRandomAdjacentTile(character)
            character:slide(target_tile, frames(move_speed), frames(0), ActionOrder.Immediate, nil)
            target_tile:reserve_entity_by_id(character:get_id())
        end
        if (frame >= character.move_speed and not character:is_sliding()) then
            if (action.iterations == 0) then
                on_complete(character)
                action.iterations = iterations;
            else
                action.iterations = action.iterations - 1
                character.repeat_state()
            end
        end
    end
    return action.action_func
end
return action_library
