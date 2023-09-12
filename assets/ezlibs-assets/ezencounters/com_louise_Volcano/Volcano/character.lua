-- Imports
---@type BattleHelper
local battle_helpers = include("battle_helpers.lua")
-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")
local CANON_SFX = Engine.load_audio(_folderpath .. "cannon.ogg")

local chip_attack = include("magma/magma.lua")
local heal = include("heal.lua")

--possible states for character
local states = { IDLE = 1, MOVE = 2, WAIT = 3 }
local debug = false

function debug_print(str)
    if debug then
        print("[volcano] " .. str)
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
    self:share_tile(false)
    self:set_explosion_behavior(4, 1, false)
    self:set_offset(0, 0)
    self:set_palette(Engine.load_texture(character_info.palette))
    self.shockwave_anim = character_info.shockwave_anim
    self.panelgrabs = character_info.panelgrabs
    self.attack_type = character_info.attack_type
    self.animation:set_state("SPAWN")
    self.frame_counter = 0
    self.started = false
    self.idle_frames = 8
    --Select bubble move direction
    self.move_direction = Direction.Up
    self.move_speed = character_info.move_speed
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)
    self.reached_edge = false
    self.has_attacked_once = false
    self:set_element(Element.Fire)
    self:set_float_shoe(true)


    self.attack_props = {
        damage = self.damage,
        element = Element.None,
        amount = character_info.fireballs
    }


    ---state idle
    ---@param frame number
    self.action_idle = function(frame)
        if (frame == self.idle_frames) then
            ---choose move direction.
            self.animation:set_state("IDLE")
            self.animation:set_playback(Playback.Loop)
            self.set_state(states.MOVE)
        end
    end

    self.turn = function()
        debug_print("shrimpy turned")
        self.move_direction = Direction.reverse(self.move_direction)

    end

    ---state move
    ---@param frame number
    self.action_move = function(frame)
        if (frame == 1) then
            -- get target to slide to
            local target_tile = self:get_tile(self.move_direction, 1)
            -- debug_print("Current tile " .. Tiletostring(self:get_tile()))
            -- debug_print("Target = " .. Tiletostring(target_tile))
            -- debug_print("Direction = " .. directiontostring(self.move_direction))
            --if not free, change direction.
            if (not is_tile_free_for_movement(target_tile, self)) then
                self.turn()
                local turned_tile = self:get_tile(self.move_direction, 1)
                if (is_tile_free_for_movement(turned_tile, self)) then
                    --free to move to the turned tile, otherwise stuck.
                    self.set_state(states.WAIT)
                    self.frame_counter = 20
                end
            end
            self:slide(target_tile, frames(self.move_speed), frames(0), ActionOrder.Immediate, nil)

        end
        if (frame >= self.move_speed and not self:is_sliding()) then
            --debug_print(tostring(self.wait_tiles))
            if (self.wait_tiles == 0) then
                -- once volcano has moved enough tiles, attack
                self.attack()
                self.set_state(states.WAIT)
                self.wait_tiles = math.random(2, 4)
            else
                self.wait_tiles = self.wait_tiles - 1
                self.set_state(states.MOVE)
            end
        end
    end

    ---state wait
    ---@param frame number
    self.action_wait = function(frame)
        if (frame == 40) then

            self.set_state(states.IDLE)
        end
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
            self.move_direction = character_info.start_direction
            self.started = true
            self.set_state(states.IDLE)
            self.wait_tiles = math.random(2, 4)
            self.lavacooldown = 0
        else
            --- On every frame, we will call the state action func.
            local action_func = actions[self.state]
            action_func(self.frame_counter)
        end

        if (self.lavacooldown > 0) then
            self.lavacooldown = self.lavacooldown - 1
        end
        --lavaHeal
        if (self:get_tile():get_state() == TileState.Lava) then
            if (self.lavacooldown <= 0) then
                heal.card_create_action(self)
                self.lavacooldown = 90
            end

        end
    end

    self.attack = function()

        self.has_attacked_once = true
        self.animation:set_state("ERUPT")

        self.animation:on_frame(5, function()
            self:toggle_counter(true)
        end)
        self.animation:on_frame(8, function()
            debug_print("attacking")
            Engine.play_audio(CANON_SFX, AudioPriority.High)
            self:toggle_counter(false)
            local magma = chip_attack.card_create_action(self, self.attack_props, self.attack_type)
            self.set_state(states.WAIT)
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
