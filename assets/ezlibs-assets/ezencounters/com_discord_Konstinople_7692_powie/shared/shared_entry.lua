local idle
local powies = {}

local JUMP_HEIGHT = 120
local DROP_ELEVATION = 120


local function run_post_movement(character, fn)
  local component = Battle.Component.new(character, Lifetimes.Local)

  component.update_func = function()
    if not character:is_moving() then
      component:eject()
      fn()
    end
  end

  character:register_component(component)
end

local function reserve_tile_for_return(character)
  local artifact = Battle.Artifact.new()
  local return_tile = character:get_tile()
  local last_tile = return_tile
  local made_reservation = false

  artifact.update_func = function()
    if character:is_deleted() then
      artifact:erase()
      return
    end

    if not made_reservation then
      return_tile:reserve_entity_by_id(artifact:get_id())
    end

    local current_tile = character:get_tile()

    if last_tile ~= return_tile and current_tile == return_tile then
      -- returned to the tile!
      artifact:erase()
    end

    last_tile = current_tile
  end

  character:get_field():spawn(artifact, return_tile)
  character._reserver = artifact:get_id()
end

local function create_hitprops(character)
  return HitProps.new(
    character._damage,
    Hit.Impact | Hit.Flinch | Hit.Flash | Hit.Breaking,
    Element.Break,
    character:get_context(),
    Drag.None
  )
end

local function create_hitbody_spell(character)
  local spell = Battle.Spell.new(character:get_team())

  spell:set_hit_props(create_hitprops(character))

  spell.update_func = function()
    if character:is_deleted() then
      spell:erase()
    end

    spell:get_tile():attack_entities(spell)
  end

  character:get_field():spawn(spell, character:get_tile())

  return spell
end

local function create_after_shock(character, x_offset, y_offset)
  local field = character:get_field()
  local start_tile = character:get_tile()

  local tile = field:tile_at(start_tile:x() + x_offset, start_tile:y() + y_offset)

  if not tile then
    return
  end

  local explosion = Battle.Explosion.new(1, 1)
  field:spawn(explosion, tile)

  local spell = Battle.Spell.new(character:get_team())
  spell:set_hit_props(create_hitprops(character))

  spell.update_func = function()
    tile:attack_entities(spell)
    spell:erase()
  end

  field:spawn(spell, tile)
end

local function create_after_shocks(character)
  if character._shock_shape == "column" then
    create_after_shock(character, 0, -1)
    create_after_shock(character, 0, 1)
  elseif character._shock_shape == "cross" then
    create_after_shock(character, 0, -1)
    create_after_shock(character, 0, 1)
    create_after_shock(character, -1, 0)
    create_after_shock(character, 1, 0)
  end
end

local function create_ominous_shadow(character)
  local shadow = Battle.Artifact.new()
  shadow:sprite():set_layer(1)
  shadow:set_texture(character:get_texture())

  local animation = shadow:get_animation()
  animation:copy_from(character:get_animation())
  animation:set_state("BIG_SHADOW")

  shadow.update_func = function()
    if character:is_deleted() or shadow:get_tile() ~= character:get_tile() then
      shadow:erase()
    end
  end

  character:get_field():spawn(shadow, character:get_tile())

  return shadow
end

local function complete_attack(character, hitbody_spell, return_tile, landing_tile)
  character._target_tile = nil
  character:teleport(return_tile, ActionOrder.Voluntary, function()
    run_post_movement(character, function()
      if landing_tile then
        landing_tile:set_state(TileState.Cracked)
      end

      character:show_shadow(true)
      character:share_tile(false)
      hitbody_spell:erase()
    end)

    local anim = character:get_animation()
    anim:set_state("LAND")

    anim:on_complete(function()
      idle(character)
    end)
  end)
end

local function land(character, return_tile, hitbody_spell)
  local ticks = 0

  local landing_tile = character:get_tile()

  if not landing_tile:is_walkable() then
    complete_attack(character, hitbody_spell, return_tile)
    return
  end

  Engine.play_audio(character._thud_sfx, AudioPriority.High)
  create_after_shocks(character)
  character:toggle_hitbox(true)
  character:shake_camera(8.0, 1.0)

  character.update_func = function()
    ticks = ticks + 1

    if ticks < 40 then
      return
    end

    complete_attack(character, hitbody_spell, return_tile, landing_tile)
    character.update_func = function() end
  end
end

local function drop(character, return_tile)
  local ticks = 0

  local elevations = {
    DROP_ELEVATION,
    DROP_ELEVATION - DROP_ELEVATION * 1 / 5,
    DROP_ELEVATION - DROP_ELEVATION * 2 / 5,
    DROP_ELEVATION - DROP_ELEVATION * 3 / 5,
    DROP_ELEVATION - DROP_ELEVATION * 4 / 5,
    DROP_ELEVATION - DROP_ELEVATION * 4 / 5,
    0
  }

  local hitbody_spell = create_hitbody_spell(character)

  character.update_func = function()
    ticks = ticks + 1
    local elevation = elevations[ticks]

    if elevation < 0 then
      elevation = 0
    end

    character:set_offset(0, -elevation)

    if elevation == 0 then
      land(character, return_tile, hitbody_spell)
    end
  end
end

local function attack(character, target)
  character._target_id = target:get_id()
  character._jumps = 0

  character:toggle_counter(true)

  local anim = character:get_animation()
  anim:set_state("LAND")
  anim:set_playback(Playback.Once)

  anim:on_complete(function()
    local return_tile = character:get_tile()
    local target_tile = target:get_tile()

    reserve_tile_for_return(character)
    character._target_tile = target_tile

    character:teleport(target_tile, ActionOrder.Immediate, function()
      run_post_movement(character, function()
        character:share_tile(true)
        character:toggle_hitbox(false)
        character:toggle_counter(false)
        character:show_shadow(false)
      end)

      character:set_offset(0, -DROP_ELEVATION)

      anim:set_state("ATTACK")
      anim:set_playback(Playback.Once)

      anim:on_frame(2, function()
        create_ominous_shadow(character)
      end)

      anim:on_complete(function()
        drop(character, return_tile)
      end)
    end)
  end)
end

local function find_target(character)
  local enemies = character:get_field():find_nearest_characters(character, function(c)
    return c:get_team() ~= character:get_team()
  end)

  for _, enemy in ipairs(enemies) do
    local skip = false

    for _,  powie in ipairs(powies) do
      if powie._target_id == enemy:get_id() then
        skip = true
        break
      end
    end

    if not skip then
      return enemy
    end
  end

  return nil
end

local function attempt_attack(character)
  local target = find_target(character)

  if target then
    attack(character, target)
  else
    idle(character)
  end
end

local function find_valid_jump_location(character)
  local field = character:get_field()

  local tiles = field:find_tiles(function(tile)
    return character.can_move_to_func(tile)
  end)

  local target_tile = tiles[math.random(#tiles)]
  local start_tile = character:get_tile()

  if #tiles > 1 then
    while target_tile == start_tile do
      -- pick another, don't try to jump on the same tile if it's not necessary
      target_tile = tiles[math.random(#tiles)]
    end
  end

  return target_tile
end

local function jump(character)
  character._jumps = character._jumps + 1

  local anim = character:get_animation()
  anim:set_state("LAND")
  anim:set_playback(Playback.Reverse)

  anim:on_complete(function()
    anim:set_state("JUMP")
    anim:set_playback(Playback.Once)

    local target_tile = find_valid_jump_location(character)
    character:toggle_hitbox(false)

    character.update_func = function()
      character:set_facing(character:get_tile():get_facing())
    end

    character:jump(target_tile, JUMP_HEIGHT, frames(40), frames(0), ActionOrder.Voluntary, function()
      run_post_movement(character, function()
        character:toggle_hitbox(true)
        character.update_func = function() end

        if character._jumps > 1 or math.random(20) == 1 then
          attempt_attack(character)
        else
          idle(character)
        end
      end)
    end)
  end)
end

idle = function(character)
  local anim = character:get_animation()
  anim:set_state("IDLE")
  anim:set_playback(Playback.Loop)
  character._target_id = nil

  local wait_time = 0

  -- wait 2s then jump
  character.update_func = function ()
    wait_time = wait_time + 1

    if wait_time < 120 then
      return
    end

    character.update_func = function() end

    jump(character)
  end
end

local function shared_package_init(character)
  character:set_texture(Engine.load_texture(_modpath.."../shared/battle.greyscaled.png"))
  character:set_animation(_modpath.."../shared/battle.animation")
  character:set_shadow(Engine.load_texture(_modpath.."../shared/small_shadow.png"))
  character:show_shadow(true)
  -- character:set_float_shoe(true) -- hack! https://discord.com/channels/455429604455219211/820777515995234314/921740913980616804

  character:add_defense_rule(Battle.DefenseVirusBody.new())

  character._reserver = -1
  character._damage = 20
  character._shock_shape = nil -- "column" | "cross" | nil
  character._target_id = nil
  character._target_tile = nil
  character._jumps = 0
  character._thud_sfx = Engine.load_audio(_modpath.."../shared/thud_compressed.ogg") -- not the right audio, but close
  powies[#powies+1] = character

  local function drop_from_powie_list()
    for index, powie in ipairs(powies) do
      if powie:get_id() == character:get_id() then
        table.remove(powies, index)
        break
      end
    end
  end

  character.delete_func = drop_from_powie_list
  character.battle_end_func = drop_from_powie_list

  character.can_move_to_func = function(tile)
    if character._target_tile then
      return character._target_tile:x() == tile:x() and character._target_tile:y() == tile:y()
    end

    if not tile:is_walkable() or tile:get_team() ~= character:get_team() or tile:is_reserved({ character:get_id(), character._reserver }) then
      return false
    end

    local has_character = false

    tile:find_entities(function(c)
      if (Battle.Character.from(c) and c:get_id() ~= character:get_id()) or Battle.Obstacle.from(c) then
        has_character = true
      end
      return false
    end)

    return not has_character
  end

  idle(character)
end

return shared_package_init
