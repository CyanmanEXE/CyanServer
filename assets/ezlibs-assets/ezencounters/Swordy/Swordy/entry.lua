local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Swordy",
        hp = 90,
        damage = 30,
        height = 44,
        move_speed = 52,
        element = Element.None,
        palette = _folderpath .. "V1.png"
    }

    if character:get_rank() == Rank.V2 then
        character_info.move_speed = 42
        character_info.damage = 60
        character_info.element = Element.Fire
        character_info.palette = _folderpath .. "V2.png"
        character_info.hp = 140
    end

    if character:get_rank() == Rank.V3 then
        character_info.move_speed = 32
        character_info.damage = 100
        character_info.element = Element.Aqua
        character_info.palette = _folderpath .. "V3.png"
        character_info.hp = 220
    end

    if character:get_rank() == Rank.SP then
        character_info.damage = 200
        character_info.move_speed = 16
        character_info.element = Element.None
        character_info.palette = _folderpath .. "SP.png"
        character_info.hp = 320
    end
    if character:get_rank() == Rank.NM then
        character_info.damage = 280
        character_info.element = Element.None
        character_info.palette = _folderpath .. "NM.png"
        character_info.hp = 500
        character_info.move_speed = 10
    end

    shared_package_init(character, character_info)
end
