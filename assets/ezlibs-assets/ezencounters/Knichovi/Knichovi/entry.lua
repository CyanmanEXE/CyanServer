local shared_package_init = include("./character.lua")
local character_id = "com.DawnAndCyan.enemy."
function package_init(character)
    local character_info = {
        name = "Knichovi",
        hp = 150,
        damage = 60,
        height = 29,
        slide_frame = 18,
        texture = _folderpath.."Knichovi.png",
        aggro_cooldown = 30
    }
    if character:get_rank() == Rank.V2 then
        character_info.damage = 90
        character_info.hp = 200
        character_info.slide_frame = 15
        character_info.texture = _folderpath.."Knichovir.png"
        character_info.aggro_cooldown = 30
    end
    if character:get_rank() == Rank.V3 then
        character_info.damage = 120
        character_info.hp = 250
        character_info.slide_frame = 12
        character_info.texture = _folderpath.."Knichovist.png"
        character_info.aggro_cooldown = 30
    end
    shared_package_init(character, character_info)
end
