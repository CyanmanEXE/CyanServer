local shared_package_init = include("../Skarab/character.lua")
function package_init(character)
    local character_info = {
        name = "Skarry",
        hp = 180,
        damage = 90,
        height = 44,
        move_speed = 90,
        bone_speed = 44,
        bone_delay = 17,
        element = Element.None,
        palette = _folderpath .. "V2.png",
        frames_between_actions = 100,
    }
    shared_package_init(character, character_info)
end
