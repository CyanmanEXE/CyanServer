local shared_package_init = include("../Skarab/character.lua")
function package_init(character)
    local character_info = {
        name = "Skelly",
        hp = 270,
        damage = 150,
        height = 44,
        move_speed = 80,
        bone_speed = 33,
        bone_delay = 12,
        element = Element.None,
        palette = _folderpath .. "V3.png",
        frames_between_actions = 80,
    }
    shared_package_init(character, character_info)
end
