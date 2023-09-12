local shared_package_init = include("../Scutz/character.lua")
function package_init(character)
    local character_info = {
        name = "Scuttle",
        hp = 300,
        damage = 200,
        height = 44,
        move_speed = 30,
        element = Element.Aqua,
        palette = _folderpath .. "aqua.png",
    }
    shared_package_init(character, character_info)
end
