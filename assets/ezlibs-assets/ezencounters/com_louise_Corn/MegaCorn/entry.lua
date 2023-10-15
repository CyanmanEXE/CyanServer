local shared_package_init = include("../BombCorn/character.lua")
function package_init(character)
    local character_info = {
        name="MegaCorn",
        hp=180,
        damage=60,
        palette=_folderpath.."palette.png",
        height=44,
        cornshots = 3,
        move_speed = 16
    }

    shared_package_init(character,character_info)
end
