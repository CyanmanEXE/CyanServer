local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "Volcano",
        hp = 80,
        damage = 40,
        palette = _folderpath .. "V1.png",
        height = 44,
        frames_between_actions = 14,
        move_speed = 25,
        start_direction = Direction.Down,
        fireballs = 1
    }
    if character:get_rank() == Rank.V2 then
        character_info.hp = 140
        character_info.damage = 80
        character_info.palette = _folderpath .. "V2.png"
        character_info.move_speed = 22
        character_info.start_direction = Direction.Left
        character_info.fireballs = 1
    end
    if character:get_rank() == Rank.V3 then
        character_info.hp = 240
        character_info.damage = 120
        character_info.palette = _folderpath .. "V3.png"
        character_info.move_speed = 16
        character_info.fireballs = 2
    end
    if character:get_rank() == Rank.Rare1 then
        character_info.hp = 220
        character_info.damage = 130
        character_info.palette = _folderpath .. "Rare1.png"
        character_info.move_speed = 18
        character_info.panelgrabs = 1
        character_info.fireballs = 2
    end
    if character:get_rank() == Rank.Rare2 then
        character_info.hp = 350
        character_info.damage = 170
        character_info.start_direction = Direction.Left
        character_info.palette = _folderpath .. "Rare2.png"
        character_info.move_speed = 10
        character_info.fireballs = 3
    end
    if character:get_rank() == Rank.SP then
        character_info.hp = 290
        character_info.damage = 200
        character_info.palette = _folderpath .. "SP.png"
        character_info.move_speed = 14
        character_info.start_direction = Direction.Left
        character_info.fireballs = 2
    end
    if character:get_rank() == Rank.NM then
        character_info.hp = 500
        character_info.damage = 300
        character_info.palette = _folderpath .. "NM.png"
        character_info.move_speed = 8
        character_info.fireballs = 4
    end
    shared_package_init(character, character_info)
end
