local panelgrab_chip = {}

local AUDIO = Engine.load_audio(_folderpath .. "sfx.ogg")
local FINISH_AUDIO = Engine.load_audio(_folderpath .. "finish_sfx.ogg")
local TEXTURE = Engine.load_texture(_folderpath .. "grab.png")
local FRAME1 = { 1, 1.3 }
local LONG_FRAME = make_frame_data({ FRAME1 })

function panelgrab_chip.card_create_action(actor)
	print("in create_card_action()!")
	local props = Battle.CardProperties.new()
	props.damage = 0
	props.shortname = "PanelGrab"
	props.time_freeze = true
	local action = Battle.CardAction.new(actor, "PLAYER_IDLE")
	action:override_animation_frames(LONG_FRAME)
	action:set_metadata(props)
	action:set_lockout(make_animation_lockout())
	action.execute_func = function(self, user)
		print("in custom card action execute_func()!")
		local tile = nil
		tile = user:get_tile()
		local dir = user:get_facing()
		local tile_to_grab = nil
		local count = 1
		local max = 6
		local tile_front = nil
		local check1 = false
		local check_front = false
		local check_up = false
		local check_down = false

		for i = count, max, 1 do

			tile_front = tile:get_tile(dir, i)

			check_front = tile_front and user:get_team() ~= tile_front:get_team() and not tile_front:is_edge() and
				tile_front:get_team() ~= Team.Other and user:is_team(tile_front:get_tile(Direction.reverse(dir), 1):get_team())

			if check_front then
				tile_to_grab = tile_front
				break
			end
			print("tile at (" .. tile_front:x() .. "x, " .. tile_front:y() .. "y) has been skipped")
		end

		if tile_to_grab and not check1 then
			Engine.play_audio(AUDIO, AudioPriority.Low)
			local fx = MakeTileSplash(user)
			user:get_field():spawn(fx, tile_to_grab)
			check1 = true
		end
		if tile_to_grab and check1 then
			Engine.play_audio(FINISH_AUDIO, AudioPriority.Low)
		end
	end
	return action
end

function MakeTileSplash(user)
	local artifact = Battle.Artifact.new()
	artifact:sprite():set_texture(TEXTURE, true)
	local anim = artifact:get_animation()
	anim:load(_folderpath .. "areagrab.animation")
	anim:set_state("FALL")
	anim:refresh(artifact:sprite())
	artifact:set_offset(0.0, -296.0)
	artifact:sprite():set_layer(-1)
	local doOnce = false
	artifact.update_func = function(self, dt)
		if self:get_offset().y >= -16 then
			if not doOnce then
				self:set_offset(0.0, 0.0)
				self:get_animation():set_state("EXPAND")
				self:get_current_tile():set_team(user:get_team(), false)
				local hitbox = Battle.Hitbox.new(user:get_team())
				local props = HitProps.new(
					10,
					Hit.Impact,
					Element.None,
					user:get_id(),
					Drag.None
				)
				hitbox:set_hit_props(props)
				user:get_field():spawn(hitbox, self:get_current_tile())
				doOnce = true
			end
			self:get_animation():on_complete(
				function()
					self:delete()
				end
			)
		else
			self:set_offset(0.0, self:get_offset().y + 16.0)
		end
	end
	artifact.delete_func = function(self)
		self:erase()
	end
	return artifact
end

return panelgrab_chip
