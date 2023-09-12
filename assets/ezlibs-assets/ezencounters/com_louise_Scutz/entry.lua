local package_id = "com.louise.Scutz"
local character_id = "com.louise.enemy."

-- To spawn this enemy use
-- com.louise.enemy.Scutz

function package_requires_scripts()
  Engine.define_character(character_id .. "Scutz", _modpath .. "Scutz")
  Engine.define_character(character_id .. "Scuttle", _modpath .. "Scuttle")
  Engine.define_character(character_id .. "Scuttler", _modpath .. "Scuttler")
  Engine.define_character(character_id .. "Scuttzer", _modpath .. "Scuttzer")
  Engine.define_character(character_id .. "Scuttlest", _modpath .. "Scuttlest")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Scutz")
  package:set_description("Life virus minions")
  package:set_speed(1)
  package:set_attack(200)
  package:set_health(300)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)

  local spawner = mob:create_spawner(character_id .. "Scuttle", Rank.V1)
  spawner:spawn_at(4, 1)
  -- local spawner = mob:create_spawner(character_id .. "Scutz", Rank.V1)
  -- spawner:spawn_at(6, 3)
  -- local spawner = mob:create_spawner(character_id .. "Scuttler", Rank.V1)
  -- spawner:spawn_at(6, 1)
  local spawner = mob:create_spawner(character_id .. "Scuttzer", Rank.V1)
  spawner:spawn_at(6, 3)
  -- local spawner = mob:create_spawner(character_id .. "Scuttlest", Rank.V1)
  -- spawner:spawn_at(4, 2)
  local spawner = mob:create_spawner(character_id .. "Scuttlest", Rank.SP)
  spawner:spawn_at(6, 1)

end
