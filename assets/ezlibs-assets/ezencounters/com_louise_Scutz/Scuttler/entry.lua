local shared_package_init = include("../Scutz/character.lua")
function package_init(character)
    local character_info = {
        name = "Scuttler",
        hp = 300,
        damage = 200,
        height = 44,
        move_speed = 30,
        element = Element.Elec,
        palette = _folderpath .. "elec.png",
    }
    shared_package_init(character, character_info)
end
