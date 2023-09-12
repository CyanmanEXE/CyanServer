local shared_package_init = include("../Lark/character.lua")
function package_init(character)
    local character_info = {
        name = "Bark",
        hp = 180,
        damage = 80,
        palette = _folderpath .. "V2.png",
        height = 44,
        frames_between_actions = 32,
        move_speed = 64,
        widespeed = 14,
    }

    shared_package_init(character, character_info)
end
