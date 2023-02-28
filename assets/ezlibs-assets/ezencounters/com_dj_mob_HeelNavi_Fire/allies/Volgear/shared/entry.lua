local MobTracker = include("mob_tracker.lua")
local battle_helpers = include("battle_helpers.lua")
local left_mob_tracker = MobTracker:new()
local right_mob_tracker = MobTracker:new()

local wave_texture = Engine.load_texture(_folderpath .. "flame.png")
local wave_sfx = Engine.load_audio(_folderpath .. "burn.ogg")
local teleport_animation_path = _folderpath .. "teleport.animation"
local teleport_texture_path = _folderpath .. "teleport.png"
local teleport_texture = Engine.load_texture(teleport_texture_path)
local impacts_texture = Engine.load_texture(_folderpath .. "impacts.png")
local impacts_animation_path = _folderpath .. "impacts.animation"

local function debug_print(text)
    --print("[volgear] " .. text)
end

function get_tracker_from_direction(facing)
    if facing == Direction.Left then
        return left_mob_tracker
    elseif facing == Direction.Right then
        return right_mob_tracker
    end
end

function advance_a_turn_by_facing(facing)
    local mob_tracker = get_tracker_from_direction(facing)
    return mob_tracker:advance_a_turn()
end

function get_active_mob_id_for_same_direction(facing)
    local mob_tracker = get_tracker_from_direction(facing)
    return mob_tracker:get_active_mob()
end

function add_enemy_to_tracking(enemy)
    local facing = enemy:get_facing()
    local id = enemy:get_id()
    local mob_tracker = get_tracker_from_direction(facing)
    mob_tracker:add_by_id(id)
end

function remove_enemy_from_tracking(enemy)
    local facing = enemy:get_facing()
    local id = enemy:get_id()
    local mob_tracker = get_tracker_from_direction(facing)
    mob_tracker:remove_by_id(id)
end

function package_init(self, character_info)
    debug_print("package_init called")
    -- Required function, main package information

    -- Load character resources
    self.texture = Engine.load_texture(_folderpath .. "battle.greyscaled.png")
    self.animation = self:get_animation()
    self.animation:load(_folderpath .. "battle.animation")

    -- Load extra resources

    -- Set up character meta
    self:set_name(character_info.name)
    self:set_health(character_info.hp)
    self:set_texture(self.texture, true)
    self:set_height(character_info.height)
    self:share_tile(false)
    self:set_explosion_behavior(2, 1, false)
    self:set_offset(0, 0)
    self:set_palette(Engine.load_texture(character_info.palette))
    self:set_element(Element.Fire)
    self:set_float_shoe(true)


    --defense rules
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)

    -- Initial state
    self.animation:set_state("IDLE")
    self.animation:set_playback(Playback.Loop)
    self.frames_between_actions = character_info.move_delay
    self.cascade_frame_index = character_info.cascade_frame --lower = faster flames
    self.flame_animation = character_info.flame_animation
    self.flame_damage = character_info.damage
    self.can_guard = character_info.can_guard
    self.ai_wait = self.frames_between_actions
    self.steps = 0
    self.steps_before_attack = 3
    self.attacking = false
    self.ai_taken_turn = false

    self.update_func = function(self, dt)
        local facing = self:get_facing()
        local id = self:get_id()
        local active_mob_id = get_active_mob_id_for_same_direction(facing)
        if active_mob_id == id then
            take_turn(self)
        end

        if self.ai_wait > 0 or self.attacking then
            self.ai_wait = self.ai_wait - 1
            return
        else
            move_random(self)
            self.ai_wait = self.frames_between_actions
            if active_mob_id == id and not self.attacking then
                self.steps = self.steps + 1
            end
        end
    end

    self.battle_start_func = function(self)
        add_enemy_to_tracking(self)
        debug_print(tostring(self))
        local field = self:get_field()
        local mob_sort_func = function(a, b)
            local met_a_tile = field:get_entity(a):get_current_tile()
            local met_b_tile = field:get_entity(b):get_current_tile()
            local var_a = (met_a_tile:x() * 3) + met_a_tile:y()
            local var_b = (met_b_tile:x() * 3) + met_b_tile:y()
            return var_a < var_b
        end
        left_mob_tracker:sort_turn_order(mob_sort_func)
        right_mob_tracker:sort_turn_order(mob_sort_func, true) --reverse sort direction
    end
    self.on_spawn_func = function(self, spawn_tile)
        debug_print("on_spawn_func called")
        left_mob_tracker:clear()
        right_mob_tracker:clear()
    end
    self.can_move_to_func = function(tile)
        return is_tile_free_for_movement(tile, self)
    end
    self.delete_func = function(self)
        debug_print("delete_func called")
        remove_enemy_from_tracking(self)
    end
end

function find_target(self)
    local field = self:get_field()
    local team = self:get_team()
    local target_list = field:find_characters(function(other_character)
        return other_character:get_team() ~= team
    end)
    if #target_list == 0 then
        debug_print("No targets found!")
        return
    end
    local target_character = target_list[1]
    return target_character
end

function take_turn(self)
    local id = self:get_id()
    if self.ai_taken_turn then
        return
    end
    self.ai_taken_turn = true

    if self.steps < self.steps_before_attack then
        self.ai_taken_turn = false
        return

    end
    self.flame_action = action_flame(self)
    self.attacking = true
    self.flame_action.action_end_func = function()
        local facing = self:get_facing()
        self.ai_wait = self.frames_between_actions
        self.flame_action = nil
        self.animation:set_state("IDLE")
        self.animation:set_playback(Playback.Loop)
        self.steps = 0
    end
    debug_print(tostring(self:get_id()) .. "begin attack")
    self:card_action_event(self.flame_action, ActionOrder.Voluntary)
end

function move_random(self)
    local target_character = find_target(self)
    if (not target_character) then
        return
    end
    local target_character_tileY = target_character:get_current_tile():y()
    local tile = self:get_current_tile()
    local field = self:get_field()
    local moved = false
    local target_movement_tile = nil
    local randomTileY = nil
    for i = 1, 3 do
        if (target_character_tileY ~= i and tile:y() ~= i) then
            randomTileY = i
            break
        end
    end

    if (randomTileY == nil) then
        randomTileY = tile:y()
    end
    target_movement_tile = field:tile_at(tile:x(), randomTileY)
    if target_movement_tile then
        moved = self:teleport(target_movement_tile, ActionOrder.Immediate)
        if moved then
            battle_helpers.spawn_visual_artifact(self, tile, teleport_texture, teleport_animation_path,
                "SMALL_TELEPORT_FROM", 0, 0)
        end
    end
    return moved
end

function action_flame(character)
    local facing = character:get_facing()
    local action = Battle.CardAction.new(character, "ATTACK")
    action:set_lockout(make_animation_lockout())
    action.execute_func = function(self, user)
        self:add_anim_action(8, function()
            character:toggle_counter(true)
        end)
        self:add_anim_action(12, function()
            local tile = character:get_tile(facing, 1)
            spawn_flame(character, tile, facing, character.flame_damage, wave_texture, character.flame_animation,
                wave_sfx, character.cascade_frame_index)
        end)
        self:add_anim_action(14, function()
            character:toggle_counter(false)
        end)
    end
    return action
end

function is_tile_free_for_movement(tile, character)
    --Basic check to see if a tile is suitable for a chracter of a team to move to
    if tile:get_team() ~= character:get_team() then return false end
    if not tile:is_walkable() then return false end
    local occupants = tile:find_characters(function(other_character)
        return true
    end)
    if #occupants > 0 then
        return false
    end
    return true
end

function getNextTile(direction, spell)
    local target_character = find_target(spell)
    local target_character_tile = target_character:get_current_tile()
    local tile = spell:get_current_tile():get_tile(direction, 1)
    local target_movement_tile = tile
    if tile:y() < target_character_tile:y() then
        target_movement_tile = tile:get_tile(Direction.Down, 1)
    end
    if tile:y() > target_character_tile:y() then
        target_movement_tile = tile:get_tile(Direction.Up, 1)
    end
    return target_movement_tile;
end

function spawn_flame(owner, tile, direction, damage, wave_texture, wave_animation, wave_sfx, cascade_frame_index)
    local owner_id = owner:get_id()
    local team = owner:get_team()
    local field = owner:get_field()
    local cascade_frame = cascade_frame_index
    local spawn_next
    spawn_next = function()
        if not tile:is_walkable() then
            if (not owner:is_deleted()) then
                local facing = owner:get_facing()
                owner.ai_taken_turn = false
                owner.attacking = false
                advance_a_turn_by_facing(facing)
            end
            return
        end

        Engine.play_audio(wave_sfx, AudioPriority.Highest)

        local spell = Battle.Spell.new(team)
        spell:set_facing(direction)
        spell:highlight_tile(Highlight.Solid)
        spell:set_hit_props(HitProps.new(damage, Hit.Flash | Hit.Flinch | Hit.Impact, Element.Fire, owner_id, Drag.new()))

        local sprite = spell:sprite()
        sprite:set_texture(wave_texture)
        sprite:set_layer(-1)

        spell.collision_func = function(self, other)
            local artifact = Battle.Artifact.new()
            artifact:never_flip(true)
            artifact:set_texture(impacts_texture)
            artifact:set_animation(impacts_animation_path)
            --FX
            local anim = artifact:get_animation()
            anim:set_state("flame_impact")
            anim:on_complete(function()
                artifact:erase()
            end)
            anim:refresh(artifact:sprite())
            field:spawn(artifact, spell:get_current_tile())
        end

        local animation = spell:get_animation()
        animation:load(_folderpath .. wave_animation)
        animation:set_state("DEFAULT")
        animation:refresh(sprite)

        animation:on_frame(cascade_frame - 10, function()
            tile = getNextTile(direction, spell)
        end)
        animation:on_frame(cascade_frame, function()

            spawn_next()
        end, true)
        animation:on_complete(function()
            spell:erase()

        end)

        spell.update_func = function()
            spell:get_current_tile():attack_entities(spell)
        end

        field:spawn(spell, tile)
    end

    spawn_next()
end

return package_init
