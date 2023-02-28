local shared_package_init = include("./character.lua")
local character_id = "com.louise.enemy."
function package_init(character)
    local character_info = {
        name = "Quaker",
        hp = 80,
        damage = 20,
        palette = _folderpath .. "V1.png",
        height = 44,
        frames_between_actions = 78,
        shockwave_anim = "shockwave.animation",
        cascade_frame = 5
    }
    if character:get_rank() == Rank.V2 then
        character_info.damage = 30
        character_info.palette = _folderpath .. "../Shaker/palette.png"
        character_info.hp = 110
        character_info.cascade_frame = 3
    end
    if character:get_rank() == Rank.V3 then
        character_info.damage = 100
        character_info.palette = _folderpath .. "../Breaker/palette.png"
        character_info.hp = 200
        character_info.cascade_frame = 3
    end
    if character:get_rank() == Rank.SP then
        character_info.damage = 150
        character_info.palette = _folderpath .. "SP.png"
        character_info.hp = 230
        character_info.cascade_frame = 3
    end
    if character:get_rank() == Rank.NM then
        character_info.damage = 190
        character_info.palette = _folderpath .. "NM.png"
        character_info.hp = 450
        character_info.frames_between_actions = 10
        character_info.cascade_frame = 2
    end
    shared_package_init(character, character_info)
end
