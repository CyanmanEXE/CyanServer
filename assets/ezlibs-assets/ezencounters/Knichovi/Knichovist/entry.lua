local shared_package_init = include("../Knichovi/character.lua")
local character_id = "com.DawnAndCyan.enemy."
function package_init(character)
    local character_info = {
        name = "Knichovist",
        hp = 250,
        damage = 120,
        height = 29,
        slide_frame = 12,
        texture = _folderpath.."Knichovist.png",
        aggro_cooldown = 30
    }
    shared_package_init(character, character_info)
end
