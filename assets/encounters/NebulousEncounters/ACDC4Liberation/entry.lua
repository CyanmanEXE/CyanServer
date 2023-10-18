local cactikil_id = "com.discord.Konstinople#7692.enemy.cactikil" -- v1, EX
local cactroll_id = "com.discord.Konstinople#7692.enemy.cactroll" -- v1, EX
local cacter_id = "com.discord.Konstinople#7692.enemy.cacter" -- v1, EX
local powie_id = "com.discord.Konstinople#7692.enemy.powie" -- v1, EX
local powie2_id = "com.discord.Konstinople#7692.enemy.powie2" -- v1, EX
local powie3_id = "com.discord.Konstinople#7692.enemy.powie3"
local mettaur_id = "com.keristero.char.Mettaur" -- v1
local champy_id = "com.keristero.char.Champy" -- v1, v2
local chimpy_id = "com.keristero.char.Chimpy" -- v1
local chumpy_id = "com.keristero.char.Chumpy" -- v1
local canguard_id = "com.discord.Konstinople#7692.enemy.canodumb" -- v1, v1, v3, SP
local bunny_id = "com.louise.enemy.MegaBunny"--V1
local bladia_id = "com.EXE5.Bladia.Enemy6" --V1
local metrid_id = "com.EXE3.Metrid.Enemy" --SP4
local cirkill_id = "com.louise.enemy.CirSmash" --v1
local joker_id = "com.louise.enemy.JokerEye" --v1
local burner_id = "com.louise.enemy.OldBurner" --v1
local sniper_id = "com.keristero.char.Sniper" --v1
local box_id = "com.louise.enemy.WindBox" --NM
local fishy_id = "com.louise.enemy.Fishy" --SP4
local rak_id = "com.louise.enemy.Cragger" --NM
local scuttlest_id = "com.louise.enemy.Scuttlest"-- v1, NM
local pirana_id = "com.louise.enemy.Piranha" --v1
local volcano_id = "com.louise.enemy.Volcano" --NM
local tark_id = "com.louise.enemy.Tark" --v1
local shrimp_id = "com.louise.enemy.Shrimpy" --v3
local swordy_id = "com.louise.enemy.Swordy"--V1,V2,V3,SP,NM
local boomer_id = "com.louise.enemy.Gloomer"--1
local skell_id = "com.louise.enemy.Skelly"--1

function package_requires_scripts()
    Engine.requires_character(cactikil_id)
    Engine.requires_character(cactroll_id)
    Engine.requires_character(cacter_id)
    Engine.requires_character(powie_id)
    Engine.requires_character(powie2_id)
    Engine.requires_character(powie3_id)
    Engine.requires_character(mettaur_id)
    Engine.requires_character(champy_id)
    Engine.requires_character(chimpy_id)
    Engine.requires_character(chumpy_id)
    Engine.requires_character(canguard_id)
    Engine.requires_character(bunny_id)
    Engine.requires_character(bladia_id)
    Engine.requires_character(metrid_id)
    Engine.requires_character(cirkill_id)
    Engine.requires_character(joker_id)
    Engine.requires_character(burner_id)
    Engine.requires_character(sniper_id)
    Engine.requires_character(box_id)
    Engine.requires_character(fishy_id)
    Engine.requires_character(rak_id)
    Engine.requires_character(scuttlest_id)
    Engine.requires_character(pirana_id)
    Engine.requires_character(volcano_id)
    Engine.requires_character(tark_id)
    Engine.requires_character(shrimp_id)
    Engine.requires_character(swordy_id)
    Engine.requires_character(boomer_id)
    Engine.requires_character(skell_id)

end

function package_init(package) 
    package:declare_package_id("com.discord.Konstinople#7692.encounter.acdc3.liberations")
end

function package_build(mob, data)
    print("Loading ACDC3 Liberation Encounter")
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
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(6, 1)--??? box didnt spawn
            mob:create_spawner(bunny_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(box_id, Rank.NM):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(sniper_id, Rank.V1):spawn_at(5, 1)--!
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 3 then
            mob:create_spawner(cirkill_id, Rank.V1):spawn_at(5, 1)--!!
            mob:create_spawner(joker_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(cirkill_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 4 then
            mob:create_spawner(bunny_id, Rank.V1):spawn_at(6, 1)--!
            mob:create_spawner(bladia_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(joker_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 5 then
            mob:create_spawner(metrid_id, Rank.SP):spawn_at(5, 1)--!
            mob:create_spawner(scuttlest_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(metrid_id, Rank.SP):spawn_at(5, 3)
        elseif choice == 6 then
            mob:create_spawner(box_id, Rank.NM):spawn_at(5, 1)--!!
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(bladia_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 7 then
            mob:create_spawner(scuttlest_id, Rank.NM):spawn_at(6, 1)--!
            mob:create_spawner(bunny_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 8 then
            mob:create_spawner(joker_id, Rank.V1):spawn_at(6, 1) --!
            mob:create_spawner(swordy_id, Rank.V3):spawn_at(5, 2)
            mob:create_spawner(burner_id, Rank.V1):spawn_at(6, 3)
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
            mob:create_spawner(fishy_id, Rank.SP):spawn_at(6, 1)
            mob:create_spawner(bunny_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(3, 3)
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(5, 2)
        elseif choice == 3 then
            mob:create_spawner(cirkill_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(tark_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(scuttlest_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 4 then
            mob:create_spawner(fishy_id, Rank.V3):spawn_at(6, 1)--??? rak didnt spawn
            mob:create_spawner(boomer_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(rak_id, Rank.NM):spawn_at(6, 3)
        elseif choice == 5 then
            mob:create_spawner(skell_id, Rank.V1):spawn_at(4, 1)--!
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 6 then
            mob:create_spawner(tark_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(tark_id, Rank.V1):spawn_at(3, 3)
        elseif choice == 7 then
            mob:create_spawner(tark_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(fishy_id, Rank.SP):spawn_at(4, 2)
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 8 then
            mob:create_spawner(rak_id, Rank.V1):spawn_at(5, 1)--!
            mob:create_spawner(rak_id, Rank.V3):spawn_at(4, 2)
            mob:create_spawner(shrimp_id, Rank.V3):spawn_at(3, 3)
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
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(1, 1)--!
            mob:create_spawner(scuttlest_id, Rank.V3):spawn_at(5, 2)
            mob:create_spawner(fishy_id, Rank.NM):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(joker_id, Rank.V1):spawn_at(6, 1)--!
            mob:create_spawner(fishy_id, Rank.SP):spawn_at(5, 2)
            mob:create_spawner(mettaur_id, Rank.V3):spawn_at(1, 3)
        elseif choice == 3 then
            mob:create_spawner(joker_id, Rank.V1):spawn_at(2, 1)--!
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(tark_id, Rank.V1):spawn_at(1, 3)
        elseif choice == 4 then
            mob:create_spawner(pirana_id, Rank.V3):spawn_at(1, 1)
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(1, 3)
        elseif choice == 5 then
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(2, 1)--!
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(1, 3)
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 6 then
            mob:create_spawner(tark_id, Rank.V1):spawn_at(6, 1)--!
            mob:create_spawner(volcano_id, Rank.NM):spawn_at(2, 2)
            mob:create_spawner(pirana_id, Rank.V3):spawn_at(1, 3)
        elseif choice == 7 then
            mob:create_spawner(volcano_id, Rank.V1):spawn_at(1, 1) --!
            mob:create_spawner(rak_id, Rank.V3):spawn_at(5, 2)
            mob:create_spawner(pirana_id, Rank.V3):spawn_at(6, 3)
        elseif choice == 8 then
            mob:create_spawner(scuttlest_id, Rank.V1):spawn_at(6, 1)--??? after makiing the NM v1 they all now spawned
            mob:create_spawner(scuttlest_id, Rank.NM):spawn_at(5, 2)
            mob:create_spawner(scuttlest_id, Rank.V1):spawn_at(1, 3)
        end
    else
        mob:enable_freedom_mission(3, false)

        local choice = math.random(8)
        if choice == 1 then
            mob:create_spawner(box_id, Rank.V3):spawn_at(6, 1)--??? only box spawsn
            mob:create_spawner(volcano_id, Rank.NM):spawn_at(5, 2)
            mob:create_spawner(joker_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 2 then
            mob:create_spawner(joker_id, Rank.V1):spawn_at(4, 1)
            mob:create_spawner(metrid_id, Rank.SP):spawn_at(5, 2)
            mob:create_spawner(sniper_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 3 then
            mob:create_spawner(fishy_id, Rank.NM):spawn_at(5, 1)
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(cirkill_id, Rank.V1):spawn_at(4, 3)
        elseif choice == 4 then
            mob:create_spawner(cirkill_id, Rank.V1):spawn_at(5, 1)--!
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(6, 2)
            mob:create_spawner(powie3_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 5 then
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(5, 1)--??? only chum spawn
            mob:create_spawner(metrid_id, Rank.SP):spawn_at(4, 3)
            mob:create_spawner(burner_id, Rank.V1):spawn_at(6, 3)
        elseif choice == 6 then
            mob:create_spawner(metrid_id, Rank.SP):spawn_at(6, 1)
            mob:create_spawner(joker_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(swordy_id, Rank.SP):spawn_at(4, 3)
        elseif choice == 7 then
            mob:create_spawner(tark_id, Rank.V1):spawn_at(6, 1)
            mob:create_spawner(volcano_id, Rank.NM):spawn_at(4, 2)
            mob:create_spawner(chumpy_id, Rank.V1):spawn_at(5, 3)
        elseif choice == 8 then
            mob:create_spawner(volcano_id, Rank.NM):spawn_at(6, 1)
            mob:create_spawner(burner_id, Rank.V1):spawn_at(5, 2)
            mob:create_spawner(joker_id, Rank.V1):spawn_at(6, 3)
        end
    end
end
