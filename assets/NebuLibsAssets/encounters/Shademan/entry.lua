local package_id = "com.Dawn.Shademan"
local character_id = "com.Dawn.Enemy.Shademan"

function package_requires_scripts()
    Engine.define_character(character_id, _modpath.."virus")
end

function package_init(package) 
    package:declare_package_id(package_id)
    package:set_name("Shademan")
    package:set_description("Don't underestimate the Darkloids!")
    package:set_speed(1)
    package:set_attack(40)
    package:set_health(600)
    package:set_preview_texture_path(_modpath.."preview.png")
end

function package_build(mob, data)
    
    
    mob:stream_music(_modpath.."song.mid", 0, 0)
    mob:enable_freedom_mission(3, false)
    local rank = Rank.SP
    if data.rank then
        rank = data.rank
        print(rank)
    end
    mob:create_spawner(character_id, rank):spawn_at(5, 2):mutate(function(character)
        if data.health then
            character:set_health(data.health)
        end
    end)
end