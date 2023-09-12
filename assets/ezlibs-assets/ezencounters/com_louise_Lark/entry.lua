local package_id = "com.louise.Lark"
local character_id = "com.louise.enemy."

-- To spawn this enemy use
-- com.louise.enemy.Lark

function package_requires_scripts()
  Engine.define_character(character_id .. "Lark", _modpath .. "Lark")
  Engine.define_character(character_id .. "Bark", _modpath .. "Bark")
  Engine.define_character(character_id .. "Tark", _modpath .. "Tark")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Lark")
  package:set_description("A weird fish")
  package:set_speed(1)
  package:set_attack(20)
  package:set_health(80)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

function package_build(mob)

  local spawner = mob:create_spawner(character_id .. "Lark", Rank.SP)
  spawner:spawn_at(4, 1)
  local spawner = mob:create_spawner(character_id .. "Bark", Rank.V1)
  spawner:spawn_at(5, 2)
  local spawner = mob:create_spawner(character_id .. "Tark", Rank.V1)
  spawner:spawn_at(6, 3)

end
