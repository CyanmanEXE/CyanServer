local package_id = "com.louise.Cragger"
local character_id = "com.louise.enemy."

-- To spawn this enemy use
-- com.louise.enemy.Cragger

function package_requires_scripts()
  Engine.define_character(character_id .. "Cragger", _modpath .. "Cragger")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Cragger")
  package:set_description("What goes around comes around")
  package:set_speed(1)
  package:set_attack(30)
  package:set_health(120)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)

  local spawner = mob:create_spawner(character_id .. "Cragger", Rank.V1)
  spawner:spawn_at(6, 1)
  local spawner = mob:create_spawner(character_id .. "Cragger", Rank.V2)
  spawner:spawn_at(6, 3)
  local spawner = mob:create_spawner(character_id .. "Cragger", Rank.SP)
  spawner:spawn_at(5, 2)

end
