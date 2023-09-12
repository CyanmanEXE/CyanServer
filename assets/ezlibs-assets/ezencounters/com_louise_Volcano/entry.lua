local package_id = "com.louise.Volcano"
local character_id = "com.louise.enemy."

-- To spawn this enemy use
-- com.louise.enemy.Volcano

function package_requires_scripts()
  Engine.define_character(character_id .. "Volcano", _modpath .. "Volcano")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Volcano")
  package:set_description("Shoots out fireballs at an arc and heals on lava!")
  package:set_speed(1)
  package:set_attack(40)
  package:set_health(130)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)

  local spawner = mob:create_spawner(character_id .. "Volcano", Rank.Rare2)
  spawner:spawn_at(4, 1)

  local spawner = mob:create_spawner(character_id .. "Volcano", Rank.V3)
  spawner:spawn_at(5, 2)

  local spawner = mob:create_spawner(character_id .. "Volcano", Rank.SP)
  spawner:spawn_at(6, 3)
end
