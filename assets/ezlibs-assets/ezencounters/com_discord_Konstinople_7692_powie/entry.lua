local powie_id = "com.discord.Konstinople#7692.enemy.powie"
local powie2_id = "com.discord.Konstinople#7692.enemy.powie2"
local powie3_id = "com.discord.Konstinople#7692.enemy.powie3"

function package_requires_scripts()
  Engine.define_character(powie_id, _modpath.."powie")
  Engine.define_character(powie2_id, _modpath.."powie2")
  Engine.define_character(powie3_id, _modpath.."powie3")
end

function package_init(package)
  package:declare_package_id("com.discord.Konstinople#7692.powie")
  package:set_name("Powie")
  package:set_description(
    "Powie, known as \"Poward\" in Japan, also known as Flappy")
  -- package:set_speed(999)
  -- package:set_attack(999)
  -- package:set_health(9999)
  package:set_preview_texture_path(_modpath.."preview.png")
end

function package_build(mob)
  mob:spawn_player(1, 3, 2)

  mob
    :create_spawner(powie_id, Rank.V1)
    :spawn_at(4, 3)
  mob
    :create_spawner(powie_id, Rank.EX)
    :spawn_at(6, 1)

  for x = 4, 6 do
    for y = 1, 3 do
      -- mob:get_field():tile_at(x, y):set_state(TileState.DirectionLeft)
    end
  end

  -- mob
  --   :create_spawner(powie_id, Rank.V1)
  --   :spawn_at(5, 2)
  -- mob
  --   :create_spawner(powie_id, Rank.EX)
  --   :spawn_at(6, 2)

  -- mob
  --   :create_spawner(powie2_id, Rank.V1)
  --   :spawn_at(5, 1)
  -- mob
  --   :create_spawner(powie2_id, Rank.EX)
  --   :spawn_at(6, 1)

  -- mob
  --   :create_spawner(powie3_id, Rank.V1)
  --   :spawn_at(5, 3)
  -- mob
  --   :create_spawner(powie3_id, Rank.EX)
  --   :spawn_at(6, 3)
end
