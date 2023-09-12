local TEXTURE_ICECUBE = Engine.load_texture(_folderpath .. "cubes.png")
local ANIMPATH_ICECUBE = _folderpath .. "cubes.animation"
local AUDIO_ICECUBE = Engine.load_audio(_folderpath .. "icecube.ogg")
local TEXTURE_ICECUBE_PIECE_1 = Engine.load_texture(_folderpath .. "icecube_piece_1.png")
local ANIMPATH_ICECUBE_PIECE_1 = _folderpath .. "icecube_piece_1.animation"
local TEXTURE_ICECUBE_PIECE_2 = Engine.load_texture(_folderpath .. "icecube_piece_2.png")
local ANIMPATH_ICECUBE_PIECE_2 = _folderpath .. "icecube_piece_2.animation"
local TEXTURE_SMOKE = Engine.load_texture(_folderpath .. "smoke.png")
local ANIMPATH_SMOKE = _folderpath .. "smoke.animation"
local AUDIO_DAMAGE = Engine.load_audio(_folderpath .. "hitsound.ogg")
local TEXTURE_THUNDERBOLT = Engine.load_texture(_folderpath .. "thunderbolt.png")
local ANIMPATH_THUNDERBOLT = _folderpath .. "thunderbolt.animation"
local AUDIO_THUNDERBOLT = Engine.load_audio(_folderpath .. "thunderbolt.ogg")
local TEXTURE_EFFECT = Engine.load_texture(_folderpath .. "../lib/effect.png")
local ANIMPATH_EFFECT = _folderpath .. "../lib/effect.animation"
local TEXTURE_VINEGRAB = Engine.load_texture(_folderpath .. "greenrope.png")
local ANIMPATH_VINEGRAB = _folderpath .. "greenrope.animation"
local TEXTURE_VINES = Engine.load_texture(_folderpath .. "vines.png")
local ANIMPATH_VINES = _folderpath .. "vines.animation"
local AUDIO_GREENROPE = Engine.load_audio(_folderpath .. "greenrope.ogg")
local TEXTURE_LASER = Engine.load_texture(_folderpath .. "laser.png")
local ANIMPATH_LASER = _folderpath .. "laser.animation"
local AUDIO_LASER = Engine.load_audio(_folderpath .. "laser.ogg")

---@class SpellsLib
local spells_lib = {}

---@type BattleHelpers
local battle_helpers = include("../lib/battle_helpers.lua")

---comment
---@param owner any Owner of spell
---@param team any Team of spell
---@param direction any Direction spell travels
---@param field any Field ref
---@param tile any Tile to spawn iceCube on
---@param damage number damage that spell will deal.
function spells_lib.spawn_icecube(owner, team, direction, field, tile, damage)
    local spell = Battle.Spell.new(team)
    spell:set_facing(direction)
    spell:set_hit_props(HitProps.new(
        damage,
        Hit.Impact | Hit.Flash | Hit.Flinch,
        Element.Aqua,
        owner:get_id(),
        Drag.new())
    )
    spell.slide_started = false

    Engine.play_audio(AUDIO_ICECUBE, AudioPriority.High)

    local sprite = spell:sprite()
    sprite:set_texture(TEXTURE_ICECUBE)
    sprite:set_layer(-3)

    local animation = spell:get_animation()
    animation:load(ANIMPATH_ICECUBE)
    animation:set_state("4")
    animation:refresh(sprite)

    local icecube = Battle.Artifact.new()
    icecube:set_facing(direction)
    icecube:set_texture(TEXTURE_ICECUBE, true)
    local icecube_sprite = icecube:sprite()
    icecube_sprite:set_layer(-3)
    local icecube_anim = icecube:get_animation()
    icecube_anim:load(ANIMPATH_ICECUBE)
    icecube_anim:set_state("0")
    icecube_anim:refresh(icecube_sprite)
    icecube_anim:on_complete(function()
        icecube:erase()
        field:spawn(spell, tile)
    end)

    local icecube_piece_1 = Battle.Artifact.new()
    icecube_piece_1:set_facing(Direction.Right)
    icecube_piece_1:set_texture(TEXTURE_ICECUBE_PIECE_1, true)
    local piece_1_sprite = icecube_piece_1:sprite()
    piece_1_sprite:set_layer(-9)
    local piece_1_anim = icecube_piece_1:get_animation()
    piece_1_anim:load(ANIMPATH_ICECUBE_PIECE_1)
    piece_1_anim:set_state("0")
    piece_1_anim:refresh(piece_1_sprite)
    piece_1_anim:on_frame(18, function()
        create_effect(TEXTURE_SMOKE, ANIMPATH_SMOKE, "1", 32, 36, field, icecube_piece_1:get_current_tile())
    end)
    piece_1_anim:on_complete(function()
        icecube_piece_1:erase()
    end)

    local icecube_piece_2 = Battle.Artifact.new()
    icecube_piece_2:set_facing(Direction.Right)
    icecube_piece_2:set_texture(TEXTURE_ICECUBE_PIECE_2, true)
    local piece_2_sprite = icecube_piece_2:sprite()
    piece_2_sprite:set_layer(-9)
    local piece_2_anim = icecube_piece_2:get_animation()
    piece_2_anim:load(ANIMPATH_ICECUBE_PIECE_2)
    piece_2_anim:set_state("0")
    piece_2_anim:refresh(piece_2_sprite)
    piece_2_anim:on_frame(21, function()
        create_effect(TEXTURE_SMOKE, ANIMPATH_SMOKE, "1", -36, 73, field, icecube_piece_2:get_current_tile())
    end)
    piece_2_anim:on_complete(function()
        icecube_piece_2:erase()
    end)

    spell.update_func = function(self, dt)
        self:get_current_tile():attack_entities(self)

        if self:is_sliding() == false then
            if self:get_current_tile():is_edge() and self.slide_started then
                owner.set_current_action(owner.action_move)
                self:delete()
            end

            local dest = self:get_tile(direction, 1)
            local ref = self
            self:slide(dest, frames(4), frames(0), ActionOrder.Voluntary,
                function()
                    ref.slide_started = true
                end
            )
        end
    end

    spell.collision_func = function(self, other)
        self:erase()
        owner.set_current_action(owner.action_move)
        create_effect(TEXTURE_SMOKE, ANIMPATH_SMOKE, "1", 0, 0, field, self:get_current_tile())
        field:spawn(icecube_piece_1, self:get_current_tile())
        field:spawn(icecube_piece_2, self:get_current_tile())
    end

    spell.attack_func = function(self)
        Engine.play_audio(AUDIO_DAMAGE, AudioPriority.Highest)
        create_effect(TEXTURE_EFFECT, ANIMPATH_EFFECT, "AQUA", math.random(-30, 30), math.random(-30, 30), field,
            spell:get_current_tile())
    end

    spell.can_move_to_func = function(tile)
        return true
    end

    field:spawn(icecube, tile)

    return spell


end

function spells_lib.spawn_thunderbolt(owner, team, direction, field, damage)

    local tile = battle_helpers.find_target(owner):get_tile()
    local spell = Battle.Spell.new(team)
    spell:set_facing(direction)
    spell:highlight_tile(Highlight.Flash)
    spell:set_hit_props(HitProps.new(
        damage,
        Hit.Impact | Hit.Flash | Hit.Flinch | Hit.Breaking,
        Element.Elec,
        owner:get_context(),
        Drag.new())
    )

    local sprite = spell:sprite()
    sprite:set_texture(TEXTURE_THUNDERBOLT)
    sprite:set_layer(-3)

    local animation = spell:get_animation()
    animation:load(ANIMPATH_THUNDERBOLT)
    animation:set_state("0")
    animation:refresh(sprite)

    spell.update_func = function(self, dt)
        if animation:get_state() == "0" then
            animation:on_complete(function()
                animation:set_state("1")
                animation:refresh(sprite)
            end)
        end
        if animation:get_state() == "1" then
            self:get_current_tile():attack_entities(self)
            animation:on_frame(1, function()
                Engine.play_audio(AUDIO_THUNDERBOLT, AudioPriority.High)
            end)
            animation:on_complete(function()
                spell:erase()
            end)
        end
    end

    spell.attack_func = function(self)
        Engine.play_audio(AUDIO_DAMAGE, AudioPriority.High)
        create_effect(TEXTURE_EFFECT, ANIMPATH_EFFECT, "ELEC", math.random(-30, 30), math.random(-30, 30), field,
            spell:get_current_tile())
    end

    spell.can_move_to_func = function(tile)
        return true
    end

    field:spawn(spell, tile)

    return spell
end

function spells_lib.spawn_greenrope_1(owner, team, direction, field, tile, damage)

    local max_steps = 8
    local function spawn_next()
        local spell = Battle.Spell.new(team)
        spell:set_facing(Direction.Right)
        spell:set_hit_props(HitProps.new(
            damage,
            Hit.Impact | Hit.Flinch | Hit.Stun | Hit.Breaking,
            Element.Wood,
            owner:get_id(),
            Drag.new())
        )

        local sprite = spell:sprite()
        sprite:set_texture(TEXTURE_VINES, true)
        sprite:set_layer(-999999)

        spell.animation = spell:get_animation()
        spell.animation:load(ANIMPATH_VINES)
        spell.animation:set_state("VINES_ANIM")
        spell.animation:refresh(sprite)
        local vine_state = 0

        spell.animation:on_frame(6, function()
            vine_state = 1
        end)
        spell.animation:on_frame(8, function()
            next_dir = battle_helpers.getDirTowardsTarget(spell)
            tile = tile:get_tile(next_dir, 1)
        end)
        spell.animation:on_frame(11, function()
            vine_state = 2
            if (max_steps > 0) then
                spawn_next()
            else
                owner.set_current_action(owner.action_move)
            end
            max_steps = max_steps - 1
        end)
        spell.animation:on_complete(function()
            spell:erase()

        end)

        spell.update_func = function(self, field, dt)
            if (vine_state == 0) then
                spell:get_current_tile():highlight(Highlight.Flash)

            elseif (vine_state == 1) then
                spell:get_current_tile():attack_entities(spell)
                spell:get_current_tile():highlight(Highlight.Solid)
            end
        end

        spell.attack_func = function(self, other)
            Engine.play_audio(AUDIO_DAMAGE, AudioPriority.High)
            create_effect(TEXTURE_EFFECT, ANIMPATH_EFFECT, "WOOD", math.random(-30, 30), math.random(-30, 30), field,
                spell:get_current_tile())
            spawn_greenrope_2(owner, team, direction, field, tile)

            local rope_component = Battle.Component.new(other, Lifetimes.Battlestep) --Battlestep so it doesn't animate during time freeze
            --create the colors once instead of every time in the update function
            rope_component.green_color = Color.new(0, 255, 0, 255)
            rope_component.regular_color = Color.new(0, 0, 0, 0)
            --240 frame countdown.
            rope_component.removal_count = 250
            rope_component.update_func = function(self, dt)
                --assign owner and sprite once so we don't have to call the function every time
                if not self.owner then self.owner = self:get_owner();
                    self.sprite = self.owner:sprite();
                end
                --if they move, they're not trapped by the spell. eject.
                if self.owner:is_moving() then self:eject() return end
                --tick removal.
                self.removal_count = self.removal_count - 1
                --at zero frames remaining, eject.
                if self.removal_count <= 0 then self:eject() return end
                --on even frames, turn them green.
                if self.removal_count % 2 == 0 then
                    self.owner:set_color(self.green_color)
                    self.sprite:set_color_mode(ColorMode.Multiply)
                else
                    --on odd frames, turn them normal color.
                    self.owner:set_color(self.regular_color)
                    self.sprite:set_color_mode(ColorMode.Additive)
                end
            end
            other:register_component(rope_component)
            spell:erase()
        end

        Engine.play_audio(AUDIO_GREENROPE, AudioPriority.Highest)
        field:spawn(spell, tile)
        return spell
    end

    spawn_next()
end

function spawn_greenrope_2(owner, team, direction, field, tile)
    local rope2 = Battle.Artifact.new()
    rope2:set_facing(Direction.Right)
    rope2:set_texture(TEXTURE_VINEGRAB, true)
    local rope2_sprite = rope2:sprite()
    rope2_sprite:set_layer(-999999)
    local rope2_anim = rope2:get_animation()
    rope2_anim:load(ANIMPATH_VINEGRAB)
    rope2_anim:set_state("1")
    rope2_anim:refresh(rope2_sprite)
    rope2_anim:on_complete(function()
        rope2:erase()
        owner.set_current_action(owner.action_move)
    end)

    field:spawn(rope2, tile)

    return rope2
end

function spells_lib.spawn_laser(owner, team, direction, field, start_tile, damage)
    local laserfx = Battle.Artifact.new()
    laserfx:set_facing(direction)
    laserfx:set_texture(TEXTURE_LASER, true)
    if direction == Direction.Right then
        laserfx:set_offset(-50, 0)
    else
        laserfx:set_offset(50, 0)
    end

    local laserfx_sprite = laserfx:sprite()
    laserfx_sprite:set_layer(-9)
    local laserfx_anim = laserfx:get_animation()
    laserfx_anim:load(ANIMPATH_LASER)
    laserfx_anim:set_state("0")
    laserfx_anim:refresh(laserfx_sprite)
    local laser_hitboxes = {}
    laserfx_anim:on_frame(6, function()
        local lasr = laser_hitbox(owner, start_tile, team, direction, field, damage)
        table.insert(laser_hitboxes, lasr)
    end)
    laserfx_anim:on_frame(8, function()
        local lasr = laser_hitbox(owner, start_tile:get_tile(direction, 1), team, direction, field, damage)
        table.insert(laser_hitboxes, lasr)
    end)
    laserfx_anim:on_frame(10, function()
        local lasr = laser_hitbox(owner, start_tile:get_tile(direction, 2), team, direction, field, damage)
        table.insert(laser_hitboxes, lasr)
    end)
    laserfx_anim:on_frame(12, function()
        local lasr = laser_hitbox(owner, start_tile:get_tile(direction, 3), team, direction, field, damage)
        table.insert(laser_hitboxes, lasr)
    end)
    laserfx_anim:on_frame(14, function()
        local lasr = laser_hitbox(owner, start_tile:get_tile(direction, 4), team, direction, field, damage)
        table.insert(laser_hitboxes, lasr)
    end)
    laserfx_anim:on_frame(16, function()
        local lasr = laser_hitbox(owner, start_tile:get_tile(direction, 5), team, direction, field, damage)
        table.insert(laser_hitboxes, lasr)
    end)
    laserfx_anim:on_frame(18, function()
        local lasr = laser_hitbox(owner, start_tile:get_tile(direction, 6), team, direction, field, damage)
        table.insert(laser_hitboxes, lasr)
    end)
    laserfx_anim:on_complete(function()
        owner.set_current_action(owner.action_move)
        for index, lasr in ipairs(laser_hitboxes) do
            lasr:erase()
        end
        laserfx:erase()
    end)

    Engine.play_audio(AUDIO_LASER, AudioPriority.High)

    field:spawn(laserfx, start_tile:get_tile(direction, 3))

    return laserfx
end

function laser_hitbox(owner, tile, team, direction, field, damage)

    if tile == nil or tile:is_edge() then return end
    local spell = Battle.Spell.new(team)
    spell:set_facing(direction)
    spell:set_hit_props(HitProps.new(
        damage,
        Hit.Impact | Hit.Flash | Hit.Flinch,
        Element.None,
        owner:get_id(),
        Drag.new())
    )

    local animation = spell:get_animation()


    spell.update_func = function()
        spell:get_current_tile():attack_entities(spell)
    end

    spell.attack_func = function()
        Engine.play_audio(AUDIO_DAMAGE, AudioPriority.Highest)
    end

    spell.can_move_to_func = function(tile)
        return true
    end

    field:spawn(spell, tile)


    return spell
end

function create_effect(effect_texture, effect_animpath, effect_state, offset_x, offset_y, field, tile)
    local hitfx = Battle.Artifact.new()
    hitfx:set_facing(Direction.Right)
    hitfx:set_texture(effect_texture, true)
    hitfx:set_offset(offset_x, offset_y)
    local hitfx_sprite = hitfx:sprite()
    hitfx_sprite:set_layer(-9)
    local hitfx_anim = hitfx:get_animation()
    hitfx_anim:load(effect_animpath)
    hitfx_anim:set_state(effect_state)
    hitfx_anim:refresh(hitfx_sprite)
    hitfx_anim:on_complete(function()
        hitfx:erase()
    end)
    field:spawn(hitfx, tile)

    return hitfx
end

return spells_lib
