local package_id = "com.DawnAndCyan.Knichovi"
local character_id = "com.DawnAndCyan.enemy."

function package_requires_scripts()
  Engine.define_character(character_id .. "Knichovi", _modpath .. "Knichovi")
  Engine.define_character(character_id .. "Knichovir", _modpath .. "Knichovir")
  Engine.define_character(character_id .. "Knichovist", _modpath .. "Knichovist")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Knichovi")
  package:set_description("Something's fishy...")
  package:set_speed(1)
  package:set_attack(60)
  package:set_health(150)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)
  local spawner = mob:create_spawner(character_id .. "Knichovi", Rank.V1)
  spawner:spawn_at(4, 1)
  spawner = mob:create_spawner(character_id .. "Knichovir", Rank.V1)
  spawner:spawn_at(5, 2)
  spawner = mob:create_spawner(character_id .. "Knichovist", Rank.V1)
  spawner:spawn_at(6, 3)
end
