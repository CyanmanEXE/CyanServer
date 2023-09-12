local package_id = "com.louise.Flashy"
local character_id = "com.louise.enemy."

-- To spawn this enemy use
-- com.louise.enemy.Remobilly

function package_requires_scripts()
  Engine.define_character(character_id .. "Flashy", _modpath .. "Flashy")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Flashy")
  package:set_description("An angry lightbulb")
  package:set_speed(1)
  package:set_attack(30)
  package:set_health(80)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)

  local spawner = mob:create_spawner(character_id .. "Flashy", Rank.V1)
  spawner:spawn_at(4, 1)

  local spawner = mob:create_spawner(character_id .. "Flashy", Rank.V2)
  spawner:spawn_at(5, 2)

  local spawner = mob:create_spawner(character_id .. "Flashy", Rank.V3)
  spawner:spawn_at(6, 3)
end
