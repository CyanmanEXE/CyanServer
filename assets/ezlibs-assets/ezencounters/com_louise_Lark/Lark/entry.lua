local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Lark",
        hp = 100,
        damage = 30,
        palette = _folderpath .. "V1.png",
        height = 44,
        frames_between_actions = 32,
        move_speed = 84,
        cracks_panels = false,
        widespeed = 16,
    }
    if character:get_rank() == Rank.Rare1 then
        character_info.hp = 180
        character_info.damage = 120
        character_info.palette = _folderpath .. "Rare1.png"
        character_info.move_speed = 42
        character_info.widespeed = 12
    end
    if character:get_rank() == Rank.Rare2 then
        character_info.hp = 270
        character_info.damage = 220
        character_info.palette = _folderpath .. "Rare2.png"
        character_info.move_speed = 34
        character_info.widespeed = 8
    end
    if character:get_rank() == Rank.SP then
        character_info.hp = 250
        character_info.damage = 200
        character_info.palette = _folderpath .. "SP.png"
        character_info.move_speed = 38
        character_info.widespeed = 10
    end
    if character:get_rank() == Rank.NM then
        character_info.hp = 500
        character_info.damage = 250
        character_info.palette = _folderpath .. "NM.png"
        character_info.move_speed = 10
        character_info.widespeed = 6
    end
    shared_package_init(character, character_info)
end
