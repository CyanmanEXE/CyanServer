local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Skarab",
        hp = 120,
        damage = 40,
        height = 44,
        move_speed = 100,
        bone_speed = 55,
        bone_delay = 22,
        element = Element.None,
        palette = _folderpath .. "V1.png",
        frames_between_actions = 120,
    }

    if character:get_rank() == Rank.SP then
        character_info.move_speed = 70
        character_info.damage = 160
        character_info.palette = _folderpath .. "SP.png"
        character_info.hp = 300
        character_info.bone_delay = 12
        character_info.bone_speed = 32
    end

    if character:get_rank() == Rank.Rare1 then
        character_info.move_speed = 80
        character_info.damage = 120
        character_info.palette = _folderpath .. "Rare1.png"
        character_info.hp = 140
        character_info.bone_delay = 18
        character_info.bone_speed = 40
    end

    if character:get_rank() == Rank.Rare2 then
        character_info.damage = 180
        character_info.move_speed = 60
        character_info.palette = _folderpath .. "Rare2.png"
        character_info.hp = 340
        character_info.bone_delay = 16
        character_info.bone_speed = 26
    end
    if character:get_rank() == Rank.NM then
        character_info.damage = 230
        character_info.palette = _folderpath .. "NM.png"
        character_info.hp = 500
        character_info.move_speed = 30
        character_info.bone_delay = 0
        character_info.bone_speed = 15
    end

    shared_package_init(character, character_info)
end
