local function find_best_target(enemy)
    local target = nil
    local field = enemy:get_field()
    local query = function(c)
        return c:get_team() ~= enemy:get_team()
    end
    local potential_threats = field:find_characters(query)
    local goal_hp = 0
    if #potential_threats > 0 then
        for i = 1, #potential_threats, 1 do
            local possible_target = potential_threats[i]
            if possible_target and not possible_target:is_deleted() and possible_target:get_health() >= goal_hp then
                target = possible_target
            end
        end
    end
    return target
end

local function teleport_at_random(self)
    local teleport_back_array = {}
    for x = 1, 6, 1 do
        for y = 1, 3, 1 do
            local tile = self.field:tile_at(x, y)
            if self.can_move_to_func(tile) then
                table.insert(teleport_back_array, tile)
            end
        end
    end
    if #teleport_back_array == 0 then return false end
    self:teleport(teleport_back_array[math.random(#teleport_back_array)], ActionOrder.Immediate, function()
        self.target = nil
        self.is_aggro = false
        self.moves_before_aggro = 4
        self.warp_cooldown = self.warp_cooldown_max
        self.anim_once = true
    end)
    return true
end

local function create_stab(user)
    local spell = Battle.Spell.new(user:get_team())
    spell:set_facing(user:get_facing())
    spell:highlight_tile(Highlight.Flash)
    spell:set_hit_props(
        HitProps.new(
            user.damage,
            Hit.Impact | Hit.Flinch | Hit.Flash,
            Element.Sword,
            user:get_context(),
            Drag.None
        )
    )
    spell:set_texture(Engine.load_texture(_modpath .. "../spell_normal_slash.png"))
    local anim = spell:get_animation()
    anim:load(_modpath .. "../spell_normal_slash.animation")
    anim:set_state("DEFAULT")
    anim:refresh(spell:sprite())
    anim:on_complete(function()
        spell:erase()
    end)
    spell.update_func = function(self, dt)
        self:get_tile():attack_entities(self)
    end

    spell.can_move_to_func = function(tile)
        return true
    end
    Engine.play_audio(Engine.load_audio(_modpath .. "../sfx.ogg"), AudioPriority.Low)

    return spell
end

function package_init(self, character_info)
    --Set up metadata and related
    self:set_health(character_info.hp) --How long it can last in battle in numerical form
    self:set_name(character_info.name) --The fish's name
    self:set_height(character_info.height) --Height, from shadow to scaleback
    self:set_element(Element.Aqua) --Water element
    self:set_texture(Engine.load_texture(character_info.texture)) --What they look like
    self.damage = character_info.damage --How much damage each fish deals with its attack.
    self.slide_speed = character_info.slide_frame --How fast they slide between tiles.
    self.pause_between_moves = math.floor(self.slide_speed / 3) --How long they wait before moving again. It's just their slide speed divided by three.
    self.is_aggro = false --Whether or not a player has upset them
    self.target = nil --Who they're attacking
    self.field = nil --The field, of course.
    self.original_tile = nil --The original tile before moving to attack
    self.moves_before_aggro = 4 --How many times they move before an attack is valid
    self.warp_cooldown_max = 40 --How long they wait before teleporting when otherwise ready to teleport
    self.warp_cooldown = self.warp_cooldown_max --The current cooldown, which actually ticks down
    self.moved = false --Whether or not they managed to move
    self.move_tile = nil --The tile they're targeting
    self.anim_once = true --A boolean useful for making things only happen once in an update loop

    --Add virus body, etc
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)
    self:set_float_shoe(true)
    self:set_air_shoe(true)

    --Set up useful information for animations.
    local sprite = self:sprite()
    local animation = self:get_animation()
    animation:load(_folderpath .. "battle.animation")
    animation:set_state("IDLE")
    animation:refresh(sprite)

    --Useful table stuff for picking directions.
    --The valid directions in a list, the current direction, you get it.
    local direction_table = { Direction.Up, Direction.Down, Direction.Left, Direction.Right }
    local random_move_direction = Direction.None
    local new_direction = Direction.None
    local has_picked_direction = false

    --For if a tile is occupied and thus we can't occupy it.
    local is_occupied = function(ent)
        if ent:get_health() <= 0 then return false end
        return Battle.Character.from(ent) ~= nil or Battle.Obstacle.from(ent) ~= nil
    end

    --Set up functions
    self.can_move_to_func = function(tile)
        --No tile, no go. If it doesn't exist we can't occupy it.
        if not tile then return false end
        --No tile, no go, part 2: electric boogaloo. If it's on the edge of the battle space it isn't ours to take.
        if tile:is_edge() then return false end
        if not self.is_aggro then --If we're not aggressive, we play by one set of rules.
            return self:is_team(tile:get_team()) and #tile:find_entities(is_occupied) == 0 and not tile:is_reserved({ self:get_id() })
        end
        --If we ARE aggressive then we can get a little more fast and loose with it.
        return #tile:find_entities(is_occupied) == 0 and not tile:is_reserved({ self:get_id() })
    end

    --Assign a few things on battle start.
    self.battle_start_func = function()
        self.target = find_best_target(self) --Obtain a target at battle start.
        self.field = self:get_field()
        self.original_tile = self:get_tile()
        self:set_facing(self.original_tile:get_facing())
        self.move_tile = self.original_tile
        if self.target ~= nil then self.move_tile = self.target:get_tile(self:get_facing_away(), 1) end
    end

    self.update_func = function(self, dt)
        if not self.is_aggro then
            --Ratty move logic. Pick a random non-diagonal direction to move in.
            --If we haven't picked a tile, and we're not sliding...
            if not has_picked_direction and not self:is_sliding() then
                --Then pick a direction at random from the table.
                random_move_direction = direction_table[math.random(1, #direction_table)]
                --Try to see the tile.
                local next_tile = self:get_tile(random_move_direction, 1)
                --If we can move to it,
                if self.can_move_to_func(next_tile) then
                    --Reserve it and say we picked a direction.
                    next_tile:reserve_entity_by_id(self:get_id())
                    has_picked_direction = true
                else
                    --otherwise repeat.
                    new_direction = Direction.flip_x(random_move_direction)
                    next_tile = self:get_tile(new_direction, 1)
                    if self.can_move_to_func(next_tile) then
                        next_tile:reserve_entity_by_id(self:get_id())
                        has_picked_direction = true
                        random_move_direction = new_direction
                    else
                        new_direction = Direction.flip_y(random_move_direction)
                        next_tile = self:get_tile(new_direction, 1)
                        if self.can_move_to_func(next_tile) then
                            next_tile:reserve_entity_by_id(self:get_id())
                            has_picked_direction = true
                            random_move_direction = new_direction
                        else
                            new_direction = Direction.reverse(random_move_direction)
                            next_tile = self:get_tile(new_direction, 1)
                            if self.can_move_to_func(next_tile) then
                                next_tile:reserve_entity_by_id(self:get_id())
                                has_picked_direction = true
                                random_move_direction = new_direction
                            else
                                --If all else fails, we're stuck and we should try to warp
                                --Teleport at random has failsafes for if there's nowhere to go as well,
                                --So this shouldn't be an issue.
                                teleport_at_random(self)
                            end
                        end
                    end
                end
            else
                if not self:is_sliding() then
                    --Airtight. Make sure we're trying to hit SOMETHING.
                    if not self.target or self.target:is_deleted() then self.target = find_best_target(self) end
                    if self:get_tile():y() == self.target:get_tile():y() then
                        --Only aggro if we're allowed to, which is after 4 moves or more.
                        if self.moves_before_aggro <= 0 then self.is_aggro = true end
                    end
                    --If we aren't already aggressive...
                    if not self.is_aggro then
                        --Then slide in a random direction.
                        self:slide(self:get_tile(random_move_direction, 1), frames(self.slide_speed),
                            frames(self.pause_between_moves), ActionOrder.Involuntary, function()
                            self.original_tile = self:get_tile()
                            --Don't forget to set our tile, and decrement our moves before aggro.
                            self.moves_before_aggro = self.moves_before_aggro - 1
                        end)
                    end
                    has_picked_direction = false
                end
            end
        else
            --On a boolean check, obtain the target.
            --This used to handle animating so it's called anim once.
            if self.anim_once then
                self.anim_once = false
                --Airtight. Make sure we're trying to hit SOMETHING.
                if not self.target or self.target:is_deleted() then self.target = find_best_target(self) end
                --Get the tile we want to move to. It's always the opposite direction from the way the fish is facing.
                self.move_tile = self.target:get_tile(self:get_facing_away(), 1)
                --Save our tile.
                self.original_tile = self:get_tile()
                if self.can_move_to_func(self.move_tile) then
                    --Reserve our tile if we can move.
                    self.move_tile:reserve_entity_by_id(self:get_id())
                    --Get the distance calculated.
                    local dist = math.abs((self.move_tile:x() - self.original_tile:x()) + (self.move_tile:y() - self.original_tile:y()))
                    --Slide a variable speed based on how many tiles we're moving across.
                    self.moved = self:slide(self.move_tile, frames(6 * (dist)), frames(0), ActionOrder.Involuntary, nil)
                else
                    --If we can't move, just warp around. We'll find an opening...
                    teleport_at_random(self)
                end
            end
            --Begin attack checks.
            if self.moved and animation:get_state() == "IDLE" and not self:is_moving() then
                --Change to attack once if we're at our destination.
                self.moved = not (self:get_tile() == self.move_tile)
                --Airtight. Make sure we're trying to hit SOMETHING.
                if not self.target or self.target:is_deleted() then self.target = find_best_target(self) end
                --If our tile is the move tile and we're no longer sliding, LET'S STAB!
                if self:get_tile() == self.move_tile and not self:is_sliding() then
                    animation:set_state("ATTACK_TWO")
                    animation:on_frame(3, function()
                        self.field:spawn(create_stab(self), self:get_tile(self:get_facing(), 1))
                    end)
                    animation:on_complete(function()
                        animation:set_state("ATTACK_ONE")
                        animation:set_playback(Playback.Reverse)
                        animation:on_complete(function()
                            animation:set_state("IDLE")
                            animation:set_playback(Playback.Loop)
                        end)
                    end)
                end
            --If the cooldown is at or below zero, check for teleport conditions
            elseif self.warp_cooldown <= 0 then
                --Only teleport if we're idle
                if animation:get_state() == "IDLE" then teleport_at_random(self) end
            else
                --Decrement the cooldown
                self.warp_cooldown = self.warp_cooldown - 1
            end
        end
    end
end

return package_init
