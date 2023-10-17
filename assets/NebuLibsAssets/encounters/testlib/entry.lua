local KillerEye="com.louise.enemy.KillerEye"--V1SPR1R2
local HauntedCandle="com.louise.enemy.HauntedCandle"--V1V2V3SPR1R2
local Cactikil="com.discord.Konstinople#7692.enemy.cactikil"
local Ratty="com.Dawn.BN3.Enemy.Ratty"--V1V2V3SP
local Volgear="com.louise.char.Volgear"--V1,V2,V3,SP
local Powie="com.discord.Konstinople#7692.enemy.powie"
local Spikey="com.Dawn.char.Spikey"
local Canodumb="com.discord.Konstinople#7692.enemy.canodumb"

function package_requires_scripts()
    Engine.requires_character(HauntedCandle)
    Engine.requires_character(KillerEye)
    Engine.requires_character(Ratty)
    Engine.requires_character(Cactikil)
    Engine.requires_character(Powie)
    Engine.requires_character(Volgear)
    Engine.requires_character(Canodumb)
    Engine.requires_character(Spikey)
end

function package_init(package) 
    package:declare_package_id("com.Dawn.encounter.Town4.liberations")
end

function package_build(mob, data)
    print("Loading Town 4 Liberation Encounter")
    print("Terrain = " .. data.terrain)

    if data.terrain == "advantage" then
        mob:enable_freedom_mission(3, false)

        for i = 1, 3 do
            local tile = mob:get_field():tile_at(4, i)
            tile:set_team(Team.Red, false)
            tile:set_facing(Direction.Right)
        end

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 1)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(Spikey, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(5, 3)
        elseif choice == 3 then
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(Canodumb, Rank.V2):spawn_at(6, 2)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 3)
        elseif choice == 4 then
            mob:create_spawner(Volgear, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 2)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(6, 3)
        elseif choice == 5 then
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 1)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(5, 3)
        elseif choice == 6 then
            mob:create_spawner(KillerEye, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 2)
            mob:create_spawner(KillerEye, Rank.V1):spawn_at(5, 3)
        elseif choice == 7 then
            mob:create_spawner(Canodumb, Rank.V2):spawn_at(6, 1)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(6, 3)
        elseif choice == 8 then
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 1)
            mob:create_spawner(KillerEye, Rank.V2):spawn_at(5, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 3)
        end
    elseif data.terrain == "disadvantage" then
        mob:enable_freedom_mission(3, false)

        for i = 1, 3 do
            local tile = mob:get_field():tile_at(3, i)
            tile:set_team(Team.Blue, false)
            tile:set_facing(Direction.Left)
        end

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 1)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(Spikey, Rank.V1):spawn_at(3, 1)
            mob:create_spawner(Powie, Rank.EX):spawn_at(3, 3)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(5, 2)
        elseif choice == 3 then
            mob:create_spawner(Volgear, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(Canodumb, Rank.V2):spawn_at(6, 2)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 3)
        elseif choice == 4 then
            mob:create_spawner(Volgear, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 2)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(6, 3)
        elseif choice == 5 then
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 1)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(5, 3)
        elseif choice == 6 then
            mob:create_spawner(KillerEye, Rank.V1):spawn_at(3, 1)
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 2)
            mob:create_spawner(KillerEye, Rank.V1):spawn_at(4, 3)
        elseif choice == 7 then
            mob:create_spawner(Canodumb, Rank.V2):spawn_at(6, 1)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(6, 3)
        elseif choice == 8 then
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 1)
            mob:create_spawner(KillerEye, Rank.V2):spawn_at(5, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 3)
        end
    elseif data.terrain == "surrounded" then
        mob:enable_freedom_mission(3, true)
        mob:spawn_player(1, 3, 2)

        -- set behind tiles to blue
        for y = 1, 3 do
            for x = 1, 2 do
                local tile = mob:get_field():tile_at(x, y)
                tile:set_team(Team.Blue, false)
            end
        end

        -- set some tiles to red to give the player room
        for i = 1, 3 do
            local tile = mob:get_field():tile_at(4, i)
            tile:set_team(Team.Red, false)
            tile:set_facing(Direction.Right)
        end

        -- set spawn position?

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(Powie, Rank.EX):spawn_at(1, 1)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(Powie, Rank.EX):spawn_at(1, 3)
            mob:create_spawner(KillerEye, Rank.V1):spawn_at(5, 3)
        elseif choice == 2 then
            mob:create_spawner(Spikey, Rank.V1):spawn_at(1, 1)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(1, 3)
            mob:create_spawner(HauntedCandle, Rank.V1):spawn_at(6, 3)
        elseif choice == 3 then
            mob:create_spawner(Volgear, Rank.V1):spawn_at(1, 1)
            mob:create_spawner(Canodumb, Rank.V2):spawn_at(6, 2)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(2, 3)
        elseif choice == 4 then
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(1, 2)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(2, 3)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(HauntedCandle, Rank.V1):spawn_at(6, 2)
        elseif choice == 5 then
            mob:create_spawner(Spikey, Rank.V1):spawn_at(2, 1)
            mob:create_spawner(Powie, Rank.EX):spawn_at(1, 3)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(6, 3)
        elseif choice == 6 then
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(6, 1)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(2, 2)
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(1, 3)
        elseif choice == 7 then
            mob:create_spawner(Canodumb, Rank.V2):spawn_at(1, 1)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(6, 3)
        elseif choice == 8 then
            mob:create_spawner(Volgear, Rank.V1):spawn_at(1, 3)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(2, 1)
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 2)
            mob:create_spawner(KillerEye, Rank.V1):spawn_at(6, 3)
        end
    else
        mob:enable_freedom_mission(3, false)

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(Powie, Rank.EX):spawn_at(4, 1)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(HauntedCandle, Rank.V1):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(Spikey, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(5, 3)
        elseif choice == 3 then
            mob:create_spawner(Volgear, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(Canodumb, Rank.V2):spawn_at(6, 2)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 3)
        elseif choice == 4 then
            mob:create_spawner(Volgear, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 2)
            mob:create_spawner(Ratty, Rank.V1):spawn_at(6, 3)
        elseif choice == 5 then
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 1)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(5, 3)
        elseif choice == 6 then
            mob:create_spawner(KillerEye, Rank.V1):spawn_at(5, 1)
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 2)
            mob:create_spawner(KillerEye, Rank.V1):spawn_at(4, 3)
        elseif choice == 7 then
            mob:create_spawner(Canodumb, Rank.V2):spawn_at(6, 1)
            mob:create_spawner(Volgear, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(Spikey, Rank.V1):spawn_at(6, 3)
        elseif choice == 8 then
            mob:create_spawner(Cactikil, Rank.EX):spawn_at(5, 1)
            mob:create_spawner(KillerEye, Rank.V2):spawn_at(5, 2)
            mob:create_spawner(Powie, Rank.EX):spawn_at(6, 3)
        end
    end
end
