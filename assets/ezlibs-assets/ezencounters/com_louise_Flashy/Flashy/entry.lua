local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Flashy",
        hp = 100,
        damage = 60,
        height = 44,
        move_speed = 85,
        element = Element.Elec,
        palette = _folderpath .. "V1.png",
        type = 1
    }
    if character:get_rank() == Rank.V2 then
        character_info.hp = 180
        character_info.damage = 100
        character_info.palette = _folderpath .. "V2.png"
        character_info.move_speed = 74
        character_info.type = 2
    end
    if character:get_rank() == Rank.V3 then
        character_info.hp = 250
        character_info.damage = 140
        character_info.palette = _folderpath .. "V3.png"
        character_info.move_speed = 64
    end
    if character:get_rank() == Rank.Rare1 then
        character_info.hp = 180
        character_info.damage = 120
        character_info.palette = _folderpath .. "Rare1.png"
        character_info.move_speed = 42
    end
    if character:get_rank() == Rank.Rare2 then
        character_info.hp = 280
        character_info.damage = 180
        character_info.palette = _folderpath .. "Rare2.png"
        character_info.move_speed = 34
    end
    if character:get_rank() == Rank.SP then
        character_info.hp = 290
        character_info.damage = 190
        character_info.palette = _folderpath .. "SP.png"
        character_info.move_speed = 54
    end
    if character:get_rank() == Rank.NM then
        character_info.hp = 500
        character_info.damage = 250
        character_info.palette = _folderpath .. "NM.png"
        character_info.move_speed = 44
    end
    shared_package_init(character, character_info)
end
