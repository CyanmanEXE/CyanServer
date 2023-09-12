local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Scutz",
        hp = 300,
        damage = 200,
        height = 44,
        move_speed = 30,
        element = Element.Fire,
        palette = _folderpath .. "fire.png",
    }
    shared_package_init(character, character_info)
end
