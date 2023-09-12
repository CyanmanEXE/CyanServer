nonce = function() end

local TEXTURE = Engine.load_texture(_folderpath .. "poof.png")
local AUDIO = Engine.load_audio(_folderpath .. "break.ogg")

local chip = {}

chip.card_create_action = function(actor, props)
	print("in create_card_action()!")
	local props = Battle.CardProperties.new()
	props.damage = 0
	props.shortname = "Geddon!"
	props.time_freeze = true
	local action = Battle.CardAction.new(actor, "SPAWN")
	action:set_lockout(make_sequence_lockout())
	local field = actor:get_field()
	local tile_array = {}
	local cooldown = 0
	action:set_metadata(props)
	action.execute_func = function(self, user)
		print("in custom card action execute_func()!")
		for i = 0, 6, 1 do
			for j = 0, 6, 1 do
				local tile = field:tile_at(i, j)
				if tile and not tile:is_edge() and tile:get_state() ~= TileState.Broken then
					table.insert(tile_array, tile)
				end
			end
		end
		local step1 = Battle.Step.new()
		step1.update_func = function(self, dt)
			for k = 0, #tile_array, 1 do
				if cooldown <= 0 then
					if #tile_array > 0 then
						local index = math.random(1, #tile_array)
						local tile2 = tile_array[index]
						if tile2:get_state() ~= TileState.Broken then
							local fx = Battle.Artifact.new()
							fx:set_texture(TEXTURE, true)
							fx:get_animation():load(_modpath .. "poof.animation")
							fx:get_animation():set_state("DEFAULT")
							fx:get_animation():refresh(fx:sprite())
							fx:get_animation():on_complete(function()
								fx:erase()
							end)
							local query = function(ent)
								if Battle.Character.from(ent) ~= nil or Battle.Obstacle.from(ent) ~= nil then
									return true
								end
							end
							if #tile2:find_entities(query) > 0 and tile2:get_state() ~= TileState.Normal then
								field:spawn(fx, tile2)
								tile2:set_state(TileState.Cracked)
								Engine.play_audio(AUDIO, AudioPriority.Low)
							elseif #tile2:find_entities(query) == 0 and tile2:get_state() ~= TileState.Broken then
								field:spawn(fx, tile2)
								tile2:set_state(TileState.Cracked)
								Engine.play_audio(AUDIO, AudioPriority.Low)
							end
							table.remove(tile_array, index)
						else
							table.remove(tile_array, index)
							k = k - 1
						end
						cooldown = 0.75
					else
						self:complete_step()
					end
				else
					cooldown = cooldown - dt
				end
			end
		end
		self:add_step(step1)
	end
	return action
end

return chip
