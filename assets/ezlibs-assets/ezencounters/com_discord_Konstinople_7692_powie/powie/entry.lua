local shared_entry = include("../shared/shared_entry.lua")

function package_init(character)
  shared_entry(character)
  character:set_name("Powie")

  if character:get_rank() == Rank.EX then
    character:set_palette(Engine.load_texture(_modpath.."powieEX.palette.png"))
    character:set_health(100)
    character._damage = 40
    character._shock_shape = "column"
  else
    character:set_palette(Engine.load_texture(_modpath.."powie.palette.png"))
    character:set_health(60)
    character._damage = 20
  end
end
