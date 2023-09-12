local package_id = "com.alrysc.enemy.juraigon"
local character_id = "com.alrysc.enemy.juraigonVirus"

function package_requires_scripts()
    Engine.define_character(character_id, _modpath.."virus")
end

function package_init(package) 
    package:declare_package_id(package_id)
    package:set_name("Juragon")
    package:set_description("Juragon1-3 from Shanghai.EXE!")
    package:set_speed(1)
    package:set_attack(80)
    package:set_health(400)
    package:set_preview_texture_path(_modpath.."preview.png")
end

function package_build(mob)
    mob:create_spawner(character_id, Rank.V1):spawn_at(5, 2)
    mob:create_spawner(character_id, Rank.V2):spawn_at(4, 1)
    mob:create_spawner(character_id, Rank.V3):spawn_at(4, 3)


 --   mob:create_spawner(character_id, Rank.V1):spawn_at(6, 3)

   -- mob:create_spawner(character_id, Rank.V2):spawn_at(4, 3)
  --  mob:create_spawner(character_id, Rank.V3):spawn_at(6, 1)
--    mob:create_spawner(character_id, Rank.SP):spawn_at(6, 3)
    -- mob:create_spawner(character_id, Rank.NM):spawn_at(5, 2)
end