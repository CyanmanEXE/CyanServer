local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Boomer",
        hp = 70,
        damage = 30,
        palette = _folderpath .. "V1.png",
        height = 44,
        frames_between_actions = 78,
        boomer_speed = 8,
        move_speed = 90,
        panelgrabs = 0,
    }
    if character:get_rank() == Rank.Rare1 then
        character_info.hp = 220
        character_info.damage = 130
        character_info.palette = _folderpath .. "Rare1.png"
        character_info.boomer_speed = 5
        character_info.move_speed = 30
        character_info.panelgrabs = 2
    end
    if character:get_rank() == Rank.Rare2 then
        character_info.hp = 350
        character_info.damage = 170
        character_info.palette = _folderpath .. "Rare2.png"
        character_info.boomer_speed = 6
        character_info.move_speed = 20
        character_info.panelgrabs = 2
    end
    if character:get_rank() == Rank.SP then
        character_info.hp = 320
        character_info.damage = 150
        character_info.palette = _folderpath .. "SP.png"
        character_info.boomer_speed = 5
        character_info.move_speed = 20
        character_info.panelgrabs = 2
    end
    if character:get_rank() == Rank.NM then
        character_info.hp = 500
        character_info.damage = 190
        character_info.palette = _folderpath .. "NM.png"
        character_info.boomer_speed = 3
        character_info.move_speed = 10
        character_info.panelgrabs = 4
    end
    shared_package_init(character, character_info)
end
