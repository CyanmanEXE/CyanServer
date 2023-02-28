local package_prefix = "louise"
local package_name = "HeelNavi"

--Everything under this comment is standard and does not need to be edited
local character_package_prefix = "com." .. package_prefix .. ".enemy."
local mob_package_id = "com." .. package_prefix .. ".mob." .. package_name

function define_package(name)
    local id = character_package_prefix .. name
    Engine.define_character(id, _modpath .. name)
end

function get_package(name)
    return character_package_prefix .. name
end

function package_requires_scripts()
    define_package("HeelNavi")
    Engine.define_character("included.Volgear", _modpath .. "allies/Volgear/Volgear")
    Engine.define_character("included.Boomer", _modpath .. "allies/Boomer/Boomer")
    Engine.define_character("included.Gloomer", _modpath .. "allies/Boomer/Gloomer")
    Engine.define_character("included.Doomer", _modpath .. "allies/Boomer/Doomer")
    Engine.define_character("included.Piranha", _modpath .. "allies/Piranha/Piranha")
end

function package_init(package)
    print('package init for ' .. mob_package_id)
    package:declare_package_id(mob_package_id)
    package:set_name(package_name)
    package:set_description("BN4 " .. package_name)
    package:set_preview_texture_path(_modpath .. "preview.png")

end

function package_build(mob)
    --can setup backgrounds, music, and field here
   
    mob:stream_music(_modpath.."bn4boss.mid", 0, 0)

    local test_spawner = mob:create_spawner(get_package("HeelNavi"), Rank.V2)
    test_spawner:spawn_at(6, 3)
end
