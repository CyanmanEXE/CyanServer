local shared_package_init = include("../Boomer/character.lua")
function package_init(character)
    local character_info = {
        name = "Gloomer",
        hp = 200,
        damage = 90,
        palette = _folderpath .. "palette.png",
        height = 44,
        frames_between_actions = 78,
        boomer_speed = 7,
        move_speed = 50,
        panelgrabs = 1,
    }

    shared_package_init(character, character_info)
end
