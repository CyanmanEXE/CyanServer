local package_id = "com.HNST_SGNL.DarkMech"
local character_id = "com.HNST_SGNL.enemy."

function package_requires_scripts()
    Engine.define_character(character_id .. "DarkMech", _modpath.."DarkMech")
end

function package_init(package)
    package:declare_package_id(package_id)
    package:set_name("DarkMech")
    package:set_description("DARK MECH STUNS AND SLASHES")
    package:set_speed(1)
    package:set_attack(110)
    package:set_health(180)
    package:set_preview_texture_path(_modpath.."preview.png")
end

function package_build(mob)
    local texture = _modpath .. "bg.png"
    local animation = _modpath .. "bg.animation"
    mob:set_background(texture, animation, 0, 0)
    
    local field = mob:get_field()
    field:tile_at(1, 3):set_state(TileState.Cracked)
    field:tile_at(3, 1):set_state(TileState.Volcano)
    field:tile_at(4, 3):set_state(TileState.Volcano)
    field:tile_at(6, 1):set_state(TileState.Cracked)

    local spawner1 = mob:create_spawner(character_id .. "DarkMech",Rank.V1)
    -- local spawner2 = mob:create_spawner(character_id .. "DarkMech",Rank.V2)
    -- local spawner3 = mob:create_spawner(character_id .. "DarkMech",Rank.V3)
    -- local spawner4 = mob:create_spawner(character_id .. "DarkMech",Rank.SP)
    -- local spawner5 = mob:create_spawner(character_id .. "DarkMech",Rank.Rare1)
    -- local spawner6 = mob:create_spawner(character_id .. "DarkMech",Rank.Rare2)
    spawner1:spawn_at(6,1)
    spawner1:spawn_at(5,2)
end
