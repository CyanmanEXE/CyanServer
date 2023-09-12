local package_id = "com.alrysc.enemy.RayCannon"
local character_id = "com.alrysc.enemy.RayCannon_enemy"

function package_requires_scripts()
    Engine.define_character(character_id, _modpath.."enemy")
end

function package_init(package) 
    package:declare_package_id(package_id)
    package:set_name("RayCannon")
    package:set_description("The cannons are clanking happily today.")
    package:set_speed(1)
    package:set_attack(15)
    package:set_health(60)
    package:set_preview_texture_path(_modpath.."preview.png")
end

function package_build(mob) 

    --[[
        This mob has a special version if you pass -1. 
        Remember Rank is an enum. Rank.V1 == 0.
    ]]

    mob:create_spawner(character_id, 0):spawn_at(6, 1)
    mob:create_spawner(character_id, 1):spawn_at(5, 2)
    mob:create_spawner(character_id, 2):spawn_at(4, 3)

   -- mob:create_spawner(character_id, -1):spawn_at(6, 2)
    --mob:create_spawner(character_id, 3):spawn_at(6, 3)
   -- mob:create_spawner(character_id, 4):spawn_at(5, 3)

end