local package_id = "com.louise.Dominerd"
local character_id = "com.louise.enemy."

-- To spawn this enemy use
-- com.louise.enemy.Dominerd

function package_requires_scripts()
  Engine.define_character(character_id .. "Dominerd", _modpath .. "Dominerd")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Dominerd")
  package:set_description("Watch your step")
  package:set_speed(1)
  package:set_attack(50)
  package:set_health(100)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)

  local spawner = mob:create_spawner(character_id .. "Dominerd", Rank.V1)
  spawner:spawn_at(5, 1)

  local spawner = mob:create_spawner(character_id .. "Dominerd", Rank.V3)
  spawner:spawn_at(5, 3)

  local spawner = mob:create_spawner(character_id .. "Dominerd", Rank.SP)
  spawner:spawn_at(6, 2)
end
