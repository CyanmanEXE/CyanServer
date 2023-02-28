local shared_package_init = include("../shared/entry.lua")

function package_init(character)
    local character_info = {
        name="VolGear",
        hp=80,
        damage=20,
        palette=_folderpath.."battle_v1.palette.png",
        height=20,
        cascade_frame = 26,
        flame_animation="flame.animation",
        move_delay = 48,
        can_guard = true
    }
    if character:get_rank() == Rank.V2 then
        character_info.damage = 100
        character_info.palette=_folderpath.."battle_v2.palette.png"
        character_info.hp = 100
        character_info.cascade_frame = 24
        character_info.move_delay = 42
    elseif character:get_rank() == Rank.V3 then
        character_info.damage = 100
        character_info.palette=_folderpath.."battle_v3.palette.png"
        character_info.hp = 160
        character_info.cascade_frame = 22
        character_info.move_delay = 34
    elseif character:get_rank() == Rank.SP then
        character_info.damage = 150
        character_info.palette=_folderpath.."battle_vsp.palette.png"
        character_info.hp = 200
        character_info.cascade_frame = 20
        character_info.move_delay = 48
    end
    shared_package_init(character,character_info)
end
