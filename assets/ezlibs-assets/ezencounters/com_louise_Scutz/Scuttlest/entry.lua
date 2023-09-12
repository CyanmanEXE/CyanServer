local shared_package_init = include("../Scutz/character.lua")
function package_init(character)
    local character_info = {
        name = "Scuttlest",
        hp = 300,
        damage = 200,
        height = 44,
        move_speed = 30,
        element = Element.None,
        palette = _folderpath .. "V1.png",
    }

    if character:get_rank() == Rank.SP then
        character_info.damage = 300
        character_info.hp = 400
        character_info.move_speed = 20
        character_info.palette = _folderpath .. "SP.png"
    end
    shared_package_init(character, character_info)
end
