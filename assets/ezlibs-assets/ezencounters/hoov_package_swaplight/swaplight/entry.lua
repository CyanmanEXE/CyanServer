local noop = function () end
local animation_path = _modpath.."SwapLght.animation"

audio = Engine.load_audio(_modpath.."timebomb.OGG")
effectaudio = Engine.load_audio(_modpath.."panel_change.OGG") --give this thing float shoes so maybe poison can't kill it as easy?

local idle_update
local switch_timer = 0
local lightstate = true
local anim

idle_update = function(virus, dt)

  local team = virus:get_team()
  
  local field = virus:get_field()
  switch_timer = switch_timer + 1
  if switch_timer % 42 == 0 then
    Engine.play_audio(audio, AudioPriority.Low)
  end
  if switch_timer == 250 then --$start
    print("statechange")
  if lightstate == true then
    --virus.state = "RED"
    anim:set_state("RED")
    anim:set_playback(Playback.Loop)
    lightstate = false

  else
    --virus.state = "BLUE"
    anim:set_state("BLUE")
    anim:set_playback(Playback.Loop)
    lightstate = true

  end
  tileswap (field)
  Engine.play_audio(effectaudio, AudioPriority.Low)

  switch_timer = 0
  
  end --$end
--Function that toggles the light state every 1400
end

function tileswap (myfield)
  for xpos = 1, 6, 1 do
    for ypos = 1, 3, 1 do
        local tile = myfield:tile_at(xpos, ypos)
        if tile:get_state() == TileState.Grass then
          tile:set_state(TileState.Poison)

        elseif tile:get_state() == TileState.Poison then
          tile:set_state(TileState.Grass)

        elseif tile:get_state() == TileState.DirectionDown then
          tile:set_state(TileState.DirectionUp)

        elseif tile:get_state() == TileState.DirectionUp then
          tile:set_state(TileState.DirectionDown)
        
        elseif tile:get_state() == TileState.DirectionLeft then
          tile:set_state(TileState.DirectionRight)

        elseif tile:get_state() == TileState.DirectionRight then
          tile:set_state(TileState.DirectionLeft)

        end

    end
  end


end


function package_init(virus)
  virus.state = "BLUE"
  virus:set_name("SwapLght")
  virus:set_height(44)
  virus:set_health(500)
  virus:set_texture(Engine.load_texture(_modpath.."SwapLght.png"))

 
  anim = virus:get_animation()
  anim:load(animation_path)
  anim:set_state(virus.state)
  anim:set_playback(Playback.Loop)
  virus:set_float_shoe(true)
  virus.update_func = idle_update
  virusdefense = Battle.DefenseVirusBody.new()
  virus:add_defense_rule(virusdefense)

end