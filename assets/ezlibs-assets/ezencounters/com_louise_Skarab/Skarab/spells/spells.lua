local AUDIO_DAMAGE = Engine.load_audio(_folderpath .. "hitsound.ogg")
local AUDIO_THROW = Engine.load_audio(_folderpath .. "throw.ogg")

local bone_texture = Engine.load_texture(_folderpath .. "bone.png")
local bone_anim = _folderpath .. "bone.animation"

local teleport_texture = Engine.load_texture(_folderpath .. "../lib/teleport.png")
local teleport_anim = _folderpath .. "../lib/teleport.animation"


---@class SpellsLib
local spells_lib = {}

---@type BattleHelpers
local battle_helpers = include("../lib/battle_helpers.lua")


function spells_lib.spawn_bone(owner, tile, damage)

    local team = owner:get_team()
    local max_steps = 8

    ---@type Entity
    local spell = Battle.Spell.new(team)
    spell:set_facing(owner:get_facing())
    spell:set_hit_props(HitProps.new(
        damage,
        Hit.Impact | Hit.Flinch | Hit.Flash,
        Element.None,
        owner:get_id(),
        Drag.new())
    )

    local sprite = spell:sprite()
    sprite:set_texture(bone_texture, true)
    sprite:set_layer(-999999)

    spell.animation = spell:get_animation()
    spell.animation:load(bone_anim)
    spell.animation:set_state("0")
    spell.animation:set_playback(Playback.Loop)
    spell.animation:refresh(sprite)
    spell:set_palette(owner:get_current_palette())

    spell:set_shadow(Shadow.Small)
    spell:show_shadow(true)

    local pause_frames = owner.bonepauseframes
    local slide_frames = owner.boneslideframes
    spell.collision_func = function()
        spell.spawn_teleport_dust()
        spell:erase()
        owner.can_attack = true
    end

    spell.spawn_teleport_dust = function()
        battle_helpers.spawn_visual_artifact(spell:get_field(), spell:get_current_tile(),
            teleport_texture, teleport_anim,
            "SMALL_TELEPORT_TO",
            0, 0)
    end

    spell.attack_func = function()
        Engine.play_audio(AUDIO_DAMAGE, AudioPriority.Highest)
    end

    spell.can_move_to_func = function()
        return true
    end
    spell.tile = tile

    spell.update_func = function(self)
        if (not spell:is_sliding()) then
            next_dir = battle_helpers.getDirTowardsTarget(spell)
            spell.tile = spell.tile:get_tile(next_dir, 1)
            if (spell.tile == nil) then
                spell:erase()
                owner.can_attack = true
                return
            end

            spell:slide(spell.tile, frames(slide_frames), frames(pause_frames), ActionOrder.Immediate)
        else

        end
        spell:get_tile():attack_entities(spell)
    end
    Engine.play_audio(AUDIO_THROW, AudioPriority.Highest)
    owner:get_field():spawn(spell, tile)
    return spell
end

return spells_lib
