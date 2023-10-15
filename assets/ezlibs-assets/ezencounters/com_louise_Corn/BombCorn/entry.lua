local shared_package_init = include("./character.lua")
local character_id = "com.louise.enemy."
function package_init(character)
    local character_info = {
        name="BombCorn",
        hp=150,
        damage=50,
        palette=_folderpath.."V1.png",
        height=44,
        cornshots = 2,
        move_speed = 16
    }
    if character:get_rank() == Rank.SP then
        character_info.damage = 120
        character_info.palette=_folderpath.."SP.png"
        character_info.hp = 270
        character_info.cornshots = 3
    elseif character:get_rank() == Rank.Rare1 then
        character_info.damage = 70
        character_info.palette=_folderpath.."R1.png"
        character_info.hp = 180
        character_info.name="RareCorn"
        character_info.cornshots = 3
    elseif character:get_rank() == Rank.Rare2 then
        character_info.damage = 130
        character_info.palette=_folderpath.."R2.png"
        character_info.hp = 270
        character_info.name="RareCorn"
        character_info.cornshots = 3
        character_info.has_areagrab=true
    end
    shared_package_init(character,character_info)
end
