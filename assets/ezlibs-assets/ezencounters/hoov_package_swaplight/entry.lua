local package_id = "hoov.package.swaplight"
local character_id = "hoov.enemy.swaplight"

function package_requires_scripts()
  Engine.define_character(character_id, _modpath.."swaplight")
  --Engine.requires_character("com.keristero.mob.Mettaur")
end

function package_init(package)
  package:declare_package_id(package_id)
  package:set_name("Swaplight")
  package:set_description("Support Virus Inbound")
  -- package:set_speed(999)
  -- package:set_attack(999)
  -- package:set_health(9999)
  package:set_preview_texture_path(_modpath.."preview.png")
end

function package_build(mob)
  mob
    :create_spawner(character_id, Rank.V1)
    :spawn_at(6, 2)

  --mob
    --:create_spawner("com.keristero.mob.Mettaur", Rank.V2)
    --:spawn_at(5, 2)

  --mob
    --:create_spawner("com.keristero.mob.Mettaur", Rank.V1)
    --:spawn_at(4, 2)
  mob:get_field():tile_at(1, 2):set_state(TileState.DirectionUp)
  mob:get_field():tile_at(3, 1):set_state(TileState.DirectionRight)
  mob:get_field():tile_at(3, 3):set_state(TileState.DirectionLeft)
  mob:get_field():tile_at(2, 1):set_state(TileState.Grass)
  mob:get_field():tile_at(2, 3):set_state(TileState.Poison)
  
end
