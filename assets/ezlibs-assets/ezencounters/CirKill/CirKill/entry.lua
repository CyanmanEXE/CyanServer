local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "CirKill",
        hp = 110,
        damage = 20,
        palette = _folderpath .. "V1.png",
        height = 44,
        element = Element.None,
        move_speed = 20,
        bullet_speed = 18,
    }
    if character:get_rank() == Rank.Rare1 then
        character_info.hp = 100
        character_info.damage = 60
        character_info.move_speed = 14
        bullet_speed = 16
        character_info.palette = _folderpath .. "Rare1.png"
    end
    if character:get_rank() == Rank.Rare2 then
        character_info.hp = 200
        character_info.damage = 120
        character_info.move_speed = 12
        character_info.bullet_speed = 12
        character_info.palette = _folderpath .. "Rare2.png"
    end
    if character:get_rank() == Rank.SP then
        character_info.hp = 220
        character_info.damage = 150
        character_info.move_speed = 14
        character_info.bullet_speed = 12
        character_info.palette = _folderpath .. "SP.png"
    end
    if character:get_rank() == Rank.NM then
        character_info.hp = 500
        character_info.damage = 200
        character_info.move_speed = 8
        character_info.bullet_speed = 6
        character_info.palette = _folderpath .. "NM.png"
    end
    shared_package_init(character, character_info)
end
