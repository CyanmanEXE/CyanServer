-- Includes
---@type BattleHelpers
local battle_helpers = include("battle_helpers.lua")

-- Animations and Textures
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")

local circ_SFX = Engine.load_audio(_folderpath .. "Circ.ogg")

local circ = Engine.load_texture(_folderpath .. "projectile.png")
local circ_anim = _folderpath .. "projectile.animation"

local fx = Engine.load_texture(_folderpath .. "fx.png")
local fx_anim = _folderpath .. "fx.animation"

--possible states for character
local states = { DEFAULT = 1, REVERSE = 2 }
-- Load character resources
---@param self Entity
function package_init(self, character_info)
    -- Required function, main package information
    local base_animation_path = CHARACTER_ANIMATION
    self:set_texture(CHARACTER_TEXTURE)
    self.animation = self:get_animation()
    self.animation:load(base_animation_path)
    -- Load extra resources
    -- Set up character meta
    -- Common Properties
    self:set_name(character_info.name)
    self:set_health(character_info.hp)
    self:set_height(character_info.height)
    self:set_palette(Engine.load_texture(character_info.palette))
    self.damage = (character_info.damage)
    -- CirKill Specific
    self:set_element(character_info.element)
    self.move_speed = character_info.move_speed
    self.bullet_speed = character_info.bullet_speed
    --Other Setup
    self.cooldown_amount = 30
    self:set_explosion_behavior(4, 1, false)
    -- entity will spawn with this animation.
    self.animation:set_state("SPAWN")
    self.frame_counter = 0
    self.started = false
    --This defense rule is added to prevent enemy from gaining invincibility after taking damage.
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)
    self.move_counter = 0
    self.cooldown_frames = 0


    -- actions for states

    -- Code that runs in the default state
    ---@param frame number
    self.action_default = function(frame)
        if (frame == 1) then
            local target_tile = getNextTile(self)
            if (not target_tile) then
                self.set_state(states.REVERSE)
                self.rev_dir = Direction.reverse(self.current_dir)
                return
            end
            self:slide(target_tile, frames(self.move_speed), frames(0), ActionOrder.Immediate, nil)
            target_tile:reserve_entity_by_id(self:get_id())
        end
        if (frame >= self.move_speed and not self:is_sliding()) then
            self.set_state(states.DEFAULT)
            self.do_attack()
        end
    end

    self.action_reverse = function(frame)
        if (frame == 1) then
            target_tile = self:get_tile(self.rev_dir, 1)
            if not battle_helpers.can_move_to_func(target_tile, self) then
                self.set_state(states.DEFAULT)
                return
            end
            self:slide(target_tile, frames(self.move_speed), frames(0), ActionOrder.Immediate, nil)
        end
        if (frame >= self.move_speed and not self:is_sliding()) then
            self.set_state(states.REVERSE)
            self.do_attack()
        end
    end

    self.do_attack = function()
        if (self.cooldown_frames > 0) then
            return
        end
        local targ = battle_helpers.find_target(self)
        if not targ then return end
        if (targ:get_tile():y() == self:get_tile():y()) then
            self.animation:set_state("SHOOT")
            Engine.play_audio(circ_SFX, AudioPriority.Highest)
            self.animation:on_frame(1, function()
                battle_helpers.spawn_visual_artifact(self:get_field(), self:get_tile(), fx, fx_anim, "0", 0, 0)
            end)
            self.animation:on_frame(2, function()
                create_shot(self, self:get_tile(self:get_facing(), 1), self.damage, self.bullet_speed, self:get_facing())
                self.cooldown_frames = self.cooldown_amount
            end)
            self.animation:on_complete(function()
                self.animation:set_state("IDLE")
                self.animation:set_playback(Playback.Loop)
            end)
        end
    end


    --utility to set the update state, and reset frame counter
    ---@param state number
    self.set_state = function(state)
        self.state = state
        self.frame_counter = 0
    end
    local actions = { [1] = self.action_default, [2] = self.action_reverse }
    self.update_func = function()
        self.frame_counter = self.frame_counter + 1
        if not self.started then
            self.started = true
            self.set_state(states.DEFAULT)
            self.animation:set_state("IDLE")
            self.animation:set_playback(Playback.Loop)
            local start_tile = self:get_tile()
            if (start_tile:y() == 1) then
                self.current_dir = self:get_facing_away()
            else
                self.current_dir = self:get_facing()
            end
            if (self:get_facing() == Direction.Right) then
                self.current_dir = Direction.reverse(self.current_dir)
            end
        else
            local action_func = actions[self.state]
            action_func(self.frame_counter)
            if (self.cooldown_frames > 0) then
                self.cooldown_frames = self.cooldown_frames - 1
            end
        end
    end
end

local dir_array = { Direction.Left, Direction.Up, Direction.Right, Direction.Down, Direction.Left, Direction.Up }
---comment
---@param clockwise boolean whether clockwise or not.
---@return number
function getNextDirection(direction, clockwise)
    local dir = 1;
    if (direction == Direction.Up) then
        dir = 2
    elseif (direction == Direction.Right) then
        dir = 3
    elseif (direction == Direction.Down) then
        dir = 4
    elseif (direction == Direction.Left) then
        dir = 5
    end

    if (clockwise) then
        return dir_array[dir + 1]
    end
    return dir_array[dir - 1]
end

function getNextTile(entity)
    local tile = entity:get_current_tile()
    local target_movement_tile = nil
    local prospective_tiles = {}
    -- cardinal directions
    local new_direction = getNextDirection(entity.current_dir, true)
    table.insert(prospective_tiles, entity:get_tile(entity.current_dir, 1))
    table.insert(prospective_tiles, entity:get_tile(new_direction, 1))

    for index, tile in ipairs(prospective_tiles) do
        if (is_tile_free_for_movement(tile, entity)) then
            if (index == 2) then
                entity.current_dir = new_direction
            end
            return tile
        end
    end

    return target_movement_tile;
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

---@param user Entity The user summoning a shot
---@param tile Tile The tile to summon the shot on
---@param damage number The amount of damage the shot will do
---@param speed number The number of frames it takes the shot to travel 1 tile.
---@param direction any The direction the
function create_shot(user, tile, damage, speed, direction)
    -- Creates a new spell that belongs to the user's team.
    local spell = Battle.Spell.new(user:get_team())


    local hitprops = Hit.Impact | Hit.Flinch | Hit.Flash

    if (user:get_rank() == Rank.NM) then
        hitprops = Hit.Impact | Hit.Flinch
    end

    --Set the hit properties of this spell.
    spell:set_hit_props(
        HitProps.new(
            damage,
            hitprops,
            Element.None,
            user:get_context(),
            Drag.new()
        )
    )
    -- Setup sprite of the spell
    local sprite = spell:sprite()
    sprite:set_texture(circ)
    sprite:set_layer(-1)
    -- Setup animation of the spell
    local anim = spell:get_animation()
    anim:load(circ_anim)
    anim:set_state("0")
    anim:set_playback(Playback.Loop)
    anim:refresh(sprite)
    spell:set_facing(user:get_facing())
    spell.update_func = function(self, dt)
        --- Gets the next tile in the specified direction.
        --- If that tile is out of bounds, it returns nil
        local tile = spell:get_tile(direction, 1)

        if (tile == nil) then
            -- Spell will be erased once it reaches the end of the field.
            spell:erase()
            return
        end
        self:get_current_tile():highlight(Highlight.Solid)
        --- Makes the spell slide to the next tile over a certain number of frames.
        spell:slide(tile, frames(speed), frames(0), ActionOrder.Voluntary, nil)
        --- Attacks the entities this spell collides with.
        self:get_current_tile():attack_entities(self)
    end

    spell.attack_func = function(self, other)
        -- Erases the spell once it hits something
        --create_hit_effect(spell:get_field(), spell:get_current_tile(), HIT_TEXTURE, HIT_ANIM_PATH, "8", HIT_SOUND)
        spell:erase()
    end

    spell.delete_func = function(self)
        spell:erase()
    end
    spell.battle_end_func = function(self)
        spell:erase()
    end

    --- Function that decides whether or not this spell is allowed
    --- to move to a certain tile. This is automatically called for
    --- functions such as slide and teleport.
    --- In this case since it always returns true, it can move over
    --- any tile.
    spell.can_move_to_func = function(tile)
        return true
    end
    user:get_field():spawn(spell, tile)
    return spell
end

--- create hit effect.
---@param field any #A field to spawn the effect on
---@param tile Tile tile to spawn effect on
---@param hit_texture any Texture hit effect. (Engine.load_texture)
---@param hit_anim_path any The animation file path
---@param hit_anim_state any The hit animation to play
---@param sfx any Audio # Audio object to play
---@return any returns the hit fx
function create_hit_effect(field, tile, hit_texture, hit_anim_path, hit_anim_state, sfx)
    -- Create artifact, artifacts do not have hitboxes and are used mostly for special effects
    local hitfx = Battle.Artifact.new()
    hitfx:set_texture(hit_texture, true)
    -- This will randomize the position of the effect a bit.
    hitfx:set_offset(math.random(-25, 25), math.random(-25, 25))
    local hitfx_sprite = hitfx:sprite()
    hitfx_sprite:set_layer(-3)
    local hitfx_anim = hitfx:get_animation()
    hitfx_anim:load(hit_anim_path)
    hitfx_anim:set_state(hit_anim_state)
    hitfx_anim:refresh(hitfx_sprite)
    hitfx_anim:on_frame(1, function()
        Engine.play_audio(sfx, AudioPriority.Highest)
    end)
    hitfx_anim:on_complete(function()
        hitfx:erase()
    end)
    field:spawn(hitfx, tile)
    return hitfx
end

return package_init
