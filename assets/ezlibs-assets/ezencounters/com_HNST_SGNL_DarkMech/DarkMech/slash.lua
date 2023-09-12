local TEXTURE_SLASH = Engine.load_texture(_modpath .. "slash.png")
local ANIMPATH_SLASH = _modpath .. "slash.animation"

local spell = {}

function spawn_wide_hitbox(field, spell, desired_tile, elem_name)
    local hitbox = Battle.Spell.new(spell:get_team())
    hitbox:set_hit_props(spell:copy_hit_props())
    hitbox.attack_func = function(self, other)
        spell.target_hit = true
        Engine.play_audio(AudioType.Hurt, AudioPriority.Highest)
    end
    field:spawn(hitbox, desired_tile)
    return hitbox
end

spell.create_slash = function(user, damage)
    local field = user:get_field()
    Engine.play_audio(AudioType.SwordSwing, AudioPriority.High)
    local spell = Battle.Spell.new(user:get_team())
    local direction = user:get_facing()

    local spell_animation = spell:get_animation()
    spell.frames = 0
    spell:set_facing(direction)
    spell:set_hit_props(
        HitProps.new(
            damage,
            Hit.Impact | Hit.Flash | Hit.Flinch,
            Element.Sword,
            user:get_id(),
            Drag.None
        )
    )
    spell.target_hit = false
    spell:set_facing(user:get_facing())
    spell_animation:load(ANIMPATH_SLASH)
    spell_animation:set_state("WIDE")
    spell:set_texture(TEXTURE_SLASH)
    spell_animation:refresh(spell:sprite())
    spell:sprite():set_layer(-1)
    spell_animation:on_complete(function()
        spell:erase()
    end)
    -- spell:set_palette(user:get_current_palette())
    local startTile = user:get_tile(user:get_facing(), 1)
    field:spawn(spell, startTile)

    spell.update_func = function(self, dt)
        spell.frames = spell.frames + 1
        self:get_current_tile():attack_entities(self)
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
        Engine.play_audio(AudioType.Hurt, AudioPriority.Highest)
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
