local shared_package_init = include("../Knichovi/character.lua")
local character_id = "com.DawnAndCyan.enemy."
function package_init(character)
    local character_info = {
        name = "Knichovir",
        hp = 200,
        damage = 90,
        height = 29,
        slide_frame = 15,
        texture = _folderpath.."Knichovir.png",
        aggro_cooldown = 30
    }
    shared_package_init(character, character_info)
end
