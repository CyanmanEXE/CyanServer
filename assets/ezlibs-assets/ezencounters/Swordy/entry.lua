local package_id = "com.louise.Swordy"
local character_id = "com.louise.enemy."

-- To spawn this enemy use
-- com.louise.enemy.Swordy

function package_requires_scripts()
  Engine.define_character(character_id .. "Swordy", _modpath .. "Swordy")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Swordy")
  package:set_description("*Swordy Swordy*")
  package:set_speed(1)
  package:set_attack(50)
  package:set_health(80)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)

  local spawner = mob:create_spawner(character_id .. "Swordy", Rank.V3)
  spawner:spawn_at(5, 1)

  local spawner = mob:create_spawner(character_id .. "Swordy", Rank.V3)
  spawner:spawn_at(5, 3)

  local spawner = mob:create_spawner(character_id .. "Swordy", Rank.SP)
  spawner:spawn_at(6, 2)
end
