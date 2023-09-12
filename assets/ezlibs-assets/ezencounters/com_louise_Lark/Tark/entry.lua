local shared_package_init = include("../Lark/character.lua")
function package_init(character)
    local character_info = {
        name = "Tark",
        hp = 180,
        damage = 180,
        palette = _folderpath .. "V3.png",
        height = 44,
        frames_between_actions = 32,
        widespeed = 12,
        move_speed = 54,
    }

    shared_package_init(character, character_info)
end
