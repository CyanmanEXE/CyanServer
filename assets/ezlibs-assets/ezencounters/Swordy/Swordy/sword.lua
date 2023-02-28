local TEXTURE_SLASH = Engine.load_texture(_modpath .. "spell_sword_slashes.png")
local ANIMPATH_SLASH = _modpath .. "spell_sword_slashes.animation"

local AUDIO_SLASH = Engine.load_audio(_modpath .. "slash.ogg")
local AUDIO_DAMAGE = Engine.load_audio(_modpath .. "hitsound.ogg")

local HIT_TEXTURE = Engine.load_texture(_modpath .. "/lib/effect.png")
local HIT_ANIM = _modpath .. "/lib/effect.animation"
local spell = {}

function spawn_wide_hitbox(field, spell, desired_tile, elem_name)
    local hitbox = Battle.Spell.new(spell:get_team())
    hitbox:set_hit_props(spell:copy_hit_props())
    hitbox.attack_func = function(self, other)
        spell.target_hit = true
        Engine.play_audio(AUDIO_DAMAGE, AudioPriority.Highest)
        if (elem_name) then
            create_basic_effect(spell:get_field(), other:get_current_tile(), HIT_TEXTURE, HIT_ANIM, elem_name)
        end
    end
    field:spawn(hitbox, desired_tile)
    return hitbox
end

--- Type can be "WIDE" or "LONG"
spell.create_slash = function(user, damage, type)
    local field = user:get_field()
    Engine.play_audio(AUDIO_SLASH, AudioPriority.High)
    local spell = Battle.Spell.new(user:get_team())
    local direction = user:get_facing()

    local spell_animation = spell:get_animation()
    local elem = user:get_element()
    if elem == Element.None then elem = Element.Sword end
    local elem_name = nil
    if (elem == Element.Fire) then
        elem_name = "FIRE"
    elseif (elem == Element.Aqua) then
        elem_name = "AQUA"
    elseif (elem == Element.Elec) then
        elem_name = "Elec"
    elseif (elem == Element.Wood) then
        elem_name = "WOOD"
    end
    spell.frames = 0
    spell:set_facing(direction)
    spell:set_hit_props(
        HitProps.new(
            damage,
            Hit.Impact | Hit.Flash | Hit.Flinch,
            elem,
            user:get_id(),
            Drag.None
        )
    )
    spell.target_hit = false
    spell:set_facing(user:get_facing())
    spell_animation:load(ANIMPATH_SLASH)
    spell_animation:set_state(type)
    spell:set_texture(TEXTURE_SLASH)
    spell_animation:refresh(spell:sprite())
    spell:sprite():set_layer(-2)
    spell_animation:on_complete(function()
        spell:erase()
    end)
    spell:set_palette(user:get_current_palette())
    local startTile = user:get_tile(user:get_facing(), 1)
    field:spawn(spell, startTile)
    local hitbox1 = nil
    local hitbox2 = nil
    if (type == "WIDE") then
        hitbox1 = spawn_wide_hitbox(field, spell, startTile:get_tile(Direction.Up, 1), elem_name)
        hitbox2 = spawn_wide_hitbox(field, spell, startTile:get_tile(Direction.Down, 1), elem_name)
    elseif (type == "LONG") then
        hitbox1 = spawn_wide_hitbox(field, spell, startTile:get_tile(user:get_facing(), 1), elem_name)
    end

    spell.update_func = function(self, dt)
        spell.frames = spell.frames + 1
        self:get_current_tile():attack_entities(self)
        hitbox1:get_current_tile():attack_entities(hitbox1)
        if (hitbox2) then
            hitbox2:get_current_tile():attack_entities(hitbox2)
        end
    end



    spell.collision_func = function(self, other)
    end

    spell.can_move_to_func = function(self, other)
        return true
    end

    spell.battle_end_func = function(self)
        spell:erase()
    end

    spell.attack_func = function(self, other)
        spell.target_hit = true
        Engine.play_audio(AUDIO_DAMAGE, AudioPriority.Highest)
        if (elem_name) then
            create_basic_effect(spell:get_field(), other:get_current_tile(), HIT_TEXTURE, HIT_ANIM, elem_name)
        end
    end
end

function create_basic_effect(field, tile, hit_texture, hit_anim_path, hit_anim_state)
    local fx = Battle.Artifact.new()
    fx:set_texture(hit_texture, true)
    local fx_sprite = fx:sprite()
    fx_sprite:set_layer(-3)
    local fx_anim = fx:get_animation()
    fx_anim:load(hit_anim_path)
    fx_anim:set_state(hit_anim_state)
    fx_anim:refresh(fx_sprite)
    fx_anim:on_complete(function()
        fx:erase()
    end)
    field:spawn(fx, tile)
    return fx
end

function Tiletostring(tile)
    return "Tile: [" .. tostring(tile:x()) .. "," .. tostring(tile:y()) .. "]"
end

return spell
