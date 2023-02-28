local shared_package_init = include("./character.lua")
local character_id = "com.louise.enemy."
function package_init(character)
    local character_info = {
        name = "Piranha",
        hp = 70,
        damage = 20,
        palette = _folderpath .. "V1.png",
        height = 44,
        frames_between_actions = 40,
        cursor_speed = 26
    }
    if character:get_rank() == Rank.V2 then
        character_info.damage =200
        character_info.palette = _folderpath .. "V2.png"
        character_info.hp = 200
        character_info.cursor_speed = 35
    end
    if character:get_rank() == Rank.V3 then
        character_info.damage = 60
        character_info.palette = _folderpath .. "V3.png"
        character_info.hp = 150
        character_info.cursor_speed = 22
    end
    if character:get_rank() == Rank.SP then
        character_info.damage = 200
        character_info.palette = _folderpath .. "SP.png"
        character_info.hp = 200
        character_info.cursor_speed = 22
    end
    if character:get_rank() == Rank.Rare1 then
        character_info.damage = 60
        character_info.palette = _folderpath .. "Rare1.png"
        character_info.hp = 150
        character_info.cursor_speed = 22
    end
    if character:get_rank() == Rank.Rare2 then
        character_info.damage = 80
        character_info.palette = _folderpath .. "Rare2.png"
        character_info.hp = 180
        character_info.cursor_speed = 22
    end
    if character:get_rank() == Rank.NM then
        character_info.damage = 180
        character_info.palette = _folderpath .. "NM.png"
        character_info.hp = 300
        character_info.frames_between_actions = 40
        character_info.has_areagrab = true
        character_info.cursor_speed = 20
    end
    shared_package_init(character, character_info)
end
