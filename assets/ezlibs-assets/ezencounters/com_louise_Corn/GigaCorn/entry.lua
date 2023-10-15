local shared_package_init = include("../BombCorn/character.lua")
local character_id = "com.louise.enemy."
function package_init(character)
    local character_info = {
        name="GigaCorn",
        hp=240,
        damage=100,
        palette=_folderpath.."palette.png",
        height=44,
        cornshots = 3,
        move_speed = 16
    }

    shared_package_init(character,character_info)
end
