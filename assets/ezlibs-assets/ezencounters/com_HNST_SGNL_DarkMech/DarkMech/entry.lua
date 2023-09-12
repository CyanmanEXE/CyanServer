local shared_package_init = include("./character.lua")
function package_init(character)
    local character_info = {
        name = "DarkMech",
        hp = 180,
        damage = 100,
        palette = _folderpath .. "V1.png",
        height = 90,
        frames_between_actions = 34,
        stun_time = 90,
        thunder_speed = 30, --vertical speed 19
    }
    if character:get_rank() == Rank.V2 then
        character_info.name = "ElecMech"
        character_info.hp = 240
        character_info.damage = 120
        character_info.palette = _folderpath .. "V2.png"
        character_info.frames_between_actions = 28
        character_info.thunder_speed = 28 --vertical speed 18
    elseif character:get_rank() == Rank.V3 then
        character_info.name = "DoomMech"
        character_info.hp = 270
        character_info.damage = 150
        character_info.palette = _folderpath .. "V3.png"
        character_info.frames_between_actions = 22
        character_info.thunder_speed = 28 --vertical speed 18
    elseif character:get_rank() == Rank.SP then
        character_info.name = "DrkMech"
        character_info.hp = 300
        character_info.damage = 180
        character_info.palette = _folderpath .. "SP.png"
        character_info.frames_between_actions = 22
        character_info.thunder_speed = 26 --vertical speed 16?
    elseif character:get_rank() == Rank.Rare1 then
        character_info.name = "RarDkMec"
        character_info.hp = 240
        character_info.damage = 140
        character_info.palette = _folderpath .. "Rare1.png"
        character_info.frames_between_actions = 28
        character_info.stun_time = 120
        character_info.thunder_speed = 25 --vertical speed 15
    elseif character:get_rank() == Rank.Rare2 then
        character_info.name = "RarDkMc2"
        character_info.hp = 300
        character_info.damage = 200
        character_info.palette = _folderpath .. "Rare2.png"
        character_info.frames_between_actions = 16
        character_info.stun_time = 150
        character_info.thunder_speed = 20 --vertical speed 12
    -- elseif character:get_rank() == Rank.NM then
        -- character_info.name = "DARKMECH"
        -- character_info.hp = 360
        -- character_info.damage = 400
        -- character_info.palette = _folderpath .. "V2.png"
        -- character_info.frames_between_actions = 28
    end
    shared_package_init(character, character_info)
end