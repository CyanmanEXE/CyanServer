local package_id = "com.louise.Skarab"
local character_id = "com.louise.enemy."

-- To spawn this enemy use
-- com.louise.enemy.Scutz

function package_requires_scripts()
  Engine.define_character(character_id .. "Skarab", _modpath .. "Skarab")
  Engine.define_character(character_id .. "Skarry", _modpath .. "Skarry")
  Engine.define_character(character_id .. "Skelly", _modpath .. "Skelly")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Skarab")
  package:set_description("Skeletons.")
  package:set_speed(1)
  package:set_attack(40)
  package:set_health(120)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)

  local spawner = mob:create_spawner(character_id .. "Skarab", Rank.V1)
  spawner:spawn_at(4, 1)
  local spawner = mob:create_spawner(character_id .. "Skarab", Rank.Rare2)
  spawner:spawn_at(6, 3)
  local spawner = mob:create_spawner(character_id .. "Skarab", Rank.SP)
  spawner:spawn_at(6, 1)

end
