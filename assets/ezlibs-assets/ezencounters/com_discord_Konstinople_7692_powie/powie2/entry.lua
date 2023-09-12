local shared_entry = include("../shared/shared_entry.lua")

function package_init(character)
  shared_entry(character)
  character:set_name("Powie2")
  character._shock_shape = "column"

  if character:get_rank() == Rank.EX then
    character:set_palette(Engine.load_texture(_modpath.."powie2EX.palette.png"))
    character:set_health(180)
    character._damage = 110
  else
    character:set_palette(Engine.load_texture(_modpath.."powie2.palette.png"))
    character:set_health(140)
    character._damage = 70
  end
end
