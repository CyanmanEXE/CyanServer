local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Dominerd",
        hp = 100,
        damage = 50,
        height = 44,
        move_speed = 60,
        element = Element.None,
        palette = _folderpath .. "V1.png",
        geddon_countdown = -1
    }

    if character:get_rank() == Rank.V2 then
        character_info.move_speed = 45
        character_info.damage = 100
        character_info.palette = _folderpath .. "V2.png"
        character_info.hp = 170
        character_info.geddon_countdown = 400
    end

    if character:get_rank() == Rank.V3 then
        character_info.move_speed = 30
        character_info.damage = 150
        character_info.palette = _folderpath .. "V3.png"
        character_info.hp = 220
        character_info.has_geddon = true
        character_info.geddon_countdown = 300
    end

    if character:get_rank() == Rank.SP then
        character_info.damage = 200
        character_info.move_speed = 20
        character_info.palette = _folderpath .. "SP.png"
        character_info.hp = 300
        character_info.geddon_countdown = 200
    end
    if character:get_rank() == Rank.NM then
        character_info.damage = 300
        character_info.palette = _folderpath .. "NM.png"
        character_info.hp = 500
        character_info.move_speed = 15
        character_info.geddon_countdown = 100
    end

    shared_package_init(character, character_info)
end
