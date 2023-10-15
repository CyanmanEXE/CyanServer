local package_id = "com.louise.Corn"
local character_id = "com.louise.enemy.Corn."

function package_requires_scripts()
  Engine.define_character(character_id .. "BombCorn", _modpath.."BombCorn")
  Engine.define_character(character_id .. "MegaCorn", _modpath.."MegaCorn")
  Engine.define_character(character_id .. "GigaCorn", _modpath.."GigaCorn")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Corn")
  package:set_description("Time for some popcorn")
  package:set_speed(1)
  package:set_attack(30)
  package:set_health(140)
  package:set_preview_texture_path(_modpath.."preview.png")
end

function package_build(mob)
local spawner = mob:create_spawner(character_id .. "BombCorn",Rank.V1)
spawner:spawn_at(5, 1)
local spawner = mob:create_spawner(character_id .. "MegaCorn",Rank.V1)
spawner:spawn_at(6, 2)
local spawner = mob:create_spawner(character_id .. "GigaCorn",Rank.V1)
spawner:spawn_at(4, 3)

-- local spawner = mob:create_spawner(character_id .. "BombCorn",Rank.SP)
-- spawner:spawn_at(5, 2)
-- local spawner = mob:create_spawner(character_id .. "BombCorn",Rank.Rare1)
-- spawner:spawn_at(4, 3)
-- local spawner = mob:create_spawner(character_id .. "BombCorn",Rank.Rare2)
-- spawner:spawn_at(6, 1)
end
