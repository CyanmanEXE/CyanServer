local shared_package_init = include("../CirKill/character.lua")
function package_init(character)
    local character_info = {
        name = "CirSmash",
        hp = 260,
        damage = 180,
        palette = _folderpath .. "V3.png",
        height = 44,
        element = Element.None,
        move_speed = 18,
        bullet_speed = 16
    }

    shared_package_init(character, character_info)
end
