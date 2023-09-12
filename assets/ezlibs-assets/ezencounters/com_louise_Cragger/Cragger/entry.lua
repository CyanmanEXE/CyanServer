local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Cragger",
        hp = 120,
        damage = 50,
        height = 44,
        move_speed = 120,
        element = Element.None,
        palette = _folderpath .. "V1.png",
    }
    if character:get_rank() == Rank.V2 then
        character_info.hp = 160
        character_info.damage = 120
        character_info.palette = _folderpath .. "V2.png"
        character_info.move_speed = 110
    end
    if character:get_rank() == Rank.V3 then
        character_info.hp = 200
        character_info.damage = 200
        character_info.palette = _folderpath .. "V3.png"
        character_info.move_speed = 100
    end
    if character:get_rank() == Rank.Rare1 then
        character_info.hp = 200
        character_info.damage = 200
        character_info.palette = _folderpath .. "Rare1.png"
        character_info.move_speed = 110
    end
    if character:get_rank() == Rank.Rare2 then
        character_info.hp = 240
        character_info.damage = 220
        character_info.palette = _folderpath .. "Rare2.png"
        character_info.move_speed = 100
    end
    if character:get_rank() == Rank.SP then
        character_info.hp = 240
        character_info.damage = 220
        character_info.palette = _folderpath .. "SP.png"
        character_info.move_speed = 90
    end
    if character:get_rank() == Rank.NM then
        character_info.hp = 600
        character_info.damage = 400
        character_info.palette = _folderpath .. "NM.png"
        character_info.move_speed = 80
    end
    shared_package_init(character, character_info)
end
