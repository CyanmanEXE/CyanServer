local shared_package_init = include("../Boomer/character.lua")
function package_init(character)
    local character_info = {
        name = "Doomer",
        hp = 180,
        damage = 90,
        palette = _folderpath .. "palette.png",
        height = 44,
        frames_between_actions = 78,
        boomer_speed = 5,
        move_speed = 30,
        panelgrabs = 2,
    }

    shared_package_init(character, character_info)
end
