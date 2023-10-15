local EnemySelection = require("scripts/ezlibs-custom/nebulous-liberations/liberations/enemy_selection")
local EnemyHelpers = require("scripts/ezlibs-custom/nebulous-liberations/liberations/enemy_helpers")
local Preloader = require("scripts/ezlibs-custom/nebulous-liberations/liberations/preloader")
local Direction = require("scripts/libs/direction")

local ShadeMan = {}

function ShadeMan:new(instance, position, direction)
  local shademan = {
    instance = instance,
    id = nil,
    health = 600,
    max_health = 600,
    x = math.floor(position.x),
    y = math.floor(position.y),
    z = math.floor(position.z),
    mug = {
      texture_path = "/server/assets/NebuLibsAssets/mugs/shademan.png",
      animation_path = "/server/assets/NebuLibsAssets/mugs/shademan.animation",
    },
    encounter = "/server/assets/encounters/dependencies/com_Dawn_Shademan.zip",
    selection = EnemySelection:new(instance),
    is_engaged = false
  }

  setmetatable(shademan, self)
  self.__index = self

  local shape = {
    {1}
  }

  shademan.selection:set_shape(shape, 0, -1)
  shademan:spawn(direction)

  return shademan
end

function ShadeMan:spawn(direction)
  self.id = Net.create_bot({
    texture_path = "/server/assets/NebuLibsAssets/bots/shademan.png",
    animation_path = "/server/assets/NebuLibsAssets/bots/shademan.animation",
    area_id = self.instance.area_id,
    direction = direction,
    warp_in = false,
    x = self.x + .5,
    y = self.y + .5,
    z = self.z
  })
  Net.set_bot_minimap_color(self.id, EnemyHelpers.boss_minimap_color)
end

function ShadeMan:get_death_message()
  return "Grr! I can't\nbelieve I've been\ndisgraced again...!\nGyaaaahh!!"
end

function ShadeMan:do_first_encounter_banter(player_id)
  local co = coroutine.create(function()
    Async.await(Async.message_player(player_id, "Your deletion will be delicious!", self.mug.texture_path, self.mug.animation_path))
    self.is_engaged = true
  end)
  return Async.promisify(co)
end

function ShadeMan:take_turn()
  local co = coroutine.create(function()
    if self.instance.phase == 1 then
      for _, player in ipairs(self.instance.players) do
        player:message(
          "Heh heh...let's party!",
          self.mug.texture_path,
          self.mug.animation_path
        )
      end

      -- Allow time for the players to read this message
      Async.await(Async.sleep(3))
    end
    
    local player = EnemyHelpers.find_closest_player_session(self.instance, self)
    if not player then return end --No player. Don't bother.
    local distance = EnemyHelpers.chebyshev_tile_distance(self, player.player.x, player.player.y)
    if distance > 10 then return end --Player too far. Don't bother.
    self.selection:move(player.player, Direction.None)
    --Message all players.
    for _, players in ipairs(self.instance.players) do
      Async.message_player(players.id,
        "Don't underestimate\nthe Darkloids!",
        self.mug.texture_path,
        self.mug.animation_path
      )
    end
    Async.await(Async.sleep(0.7))
    local warp_back_pos = {x=self.x, y=self.y, z=self.z}
    local warp_back_direction = self.direction
    local targetx = player.player.x
    local targety = player.player.y - 1
    local target_direction = Direction.diagonal_from_offset(
      player.player.x - (targetx + .5),
      player.player.y - (targety + .5)
    )
    Async.await(EnemyHelpers.move(self.instance, self, targetx, targety, player.player.z, target_direction))
    self.selection:indicate()
    EnemyHelpers.play_attack_animation(self)
    player:hurt(60)
    Async.await(Async.sleep(.7))
    Async.await(EnemyHelpers.move(self.instance, self, warp_back_pos.x, warp_back_pos.y, warp_back_pos.z, warp_back_direction))
    self.selection:remove_indicators()
  end)

  return Async.promisify(co)
end

return ShadeMan