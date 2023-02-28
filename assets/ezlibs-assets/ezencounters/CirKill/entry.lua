--ID of the package
local package_id = "com.louise.CirKill"
-- prefix of the character id
local character_id = "com.louise.enemy."

function package_requires_scripts()
  --Define characters here.
  Engine.define_character(character_id .. "CirKill", _modpath .. "CirKill")
  Engine.define_character(character_id .. "CirCrush", _modpath .. "CirCrush")
  Engine.define_character(character_id .. "CirSmash", _modpath .. "CirSmash")
end

--package init.
function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("CirKill")
  package:set_description("Your nightmares took physical form")
  package:set_speed(1)
  package:set_attack(0)
  package:set_health(0)
  package:set_preview_texture_path(_modpath .. "preview.png")
end

-- setup the test package
function package_build(mob)
  local spawner = mob:create_spawner(character_id .. "CirKill", Rank.V1)
  spawner:spawn_at(4, 1)

  local spawner = mob:create_spawner(character_id .. "CirKill", Rank.V1)
  spawner:spawn_at(5, 3)

  local spawner = mob:create_spawner(character_id .. "CirKill", Rank.Rare1)
  spawner:spawn_at(6, 1)
end
