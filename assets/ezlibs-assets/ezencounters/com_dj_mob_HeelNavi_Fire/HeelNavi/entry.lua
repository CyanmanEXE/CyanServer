local shared_package_init = include("../shared/character.lua")

function package_init(character)
    local character_info = {
        name = "Burglar",
        hp = 300,
        damage = 20,
        height = 50,
        cascade_frame = 26,
        move_speed = 48,
        sword_dmg = 20,
        ball_dmg = 30,
        bomb_dmg = 20
    }
    if character:get_rank() == Rank.V2 then
        character_info.hp = 1000
        character_info.move_speed = 40
        character_info.sword_dmg = 200
        character_info.ball_dmg = 150
        character_info.bomb_dmg = 300
    elseif character:get_rank() == Rank.V3 then
        character_info.hp = 1100
        character_info.move_speed = 42
        character_info.sword_dmg = 100
        character_info.ball_dmg = 120
        character_info.bomb_dmg = 100
    elseif character:get_rank() == Rank.SP then
        character_info.hp = 1400
        character_info.move_speed = 38
        character_info.sword_dmg = 200
        character_info.ball_dmg = 200
        character_info.bomb_dmg = 150
    end
    shared_package_init(character, character_info)
end
