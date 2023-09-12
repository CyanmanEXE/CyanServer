local shared_package_init = include("../Scutz/character.lua")
function package_init(character)
    local character_info = {
        name = "Scuttzer",
        hp = 300,
        damage = 200,
        height = 44,
        move_speed = 30,
        element = Element.Wood,
        palette = _folderpath .. "wood.png",
    }
    shared_package_init(character, character_info)
end
