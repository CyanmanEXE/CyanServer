local package_id = "com.louise.Quaker"
local character_id = "com.louise.enemy."

function package_requires_scripts()
  Engine.define_character(character_id .. "Quaker", _modpath .. "Quaker")
  -- Engine.define_character(character_id .. "Shaker", _modpath .. "Shaker")
  -- Engine.define_character(character_id .. "Breaker", _modpath .. "Breaker")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Quaker")
  package:set_description("Bn6 Quaker")
  package:set_speed(1)
  package:set_attack(60)
  package:set_health(80)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)
  local spawner = mob:create_spawner(character_id .. "Quaker", Rank.V1)
  spawner:spawn_at(4, 1)
  local spawner = mob:create_spawner(character_id .. "Quaker", Rank.V2)
  spawner:spawn_at(4, 3)
  local spawner = mob:create_spawner(character_id .. "Quaker", Rank.V3)
  spawner:spawn_at(6, 1)
  -- local spawner = mob:create_spawner(character_id .. "Quaker", Rank.SP)
  -- spawner:spawn_at(4, 1)
  -- local spawner = mob:create_spawner(character_id .. "Quaker", Rank.SP)
  -- spawner:spawn_at(4, 3)
  -- local spawner = mob:create_spawner(character_id .. "Quaker", Rank.NM)
  -- spawner:spawn_at(6, 2)
end
