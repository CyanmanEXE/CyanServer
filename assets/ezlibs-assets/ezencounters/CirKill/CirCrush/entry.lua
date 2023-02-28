local shared_package_init = include("../CirKill/character.lua")
function package_init(character)
    local character_info = {
        name = "CirCrush",
        hp = 180,
        damage = 90,
        palette = _folderpath .. "V2.png",
        height = 44,
        element = Element.None,
        move_speed = 18,
        bullet_speed = 18
    }
    shared_package_init(character, character_info)
end
