local chip = {}

local BARRIER_TEXTURE = Engine.load_texture(_folderpath .. "barrier.png")
local BARRIER_ANIMATION_PATH = _folderpath .. "barrier.animation"



chip.card_create_action = function(user)
	return create_barrier(user)
end

function create_barrier(user)
	local offsetY = -2 * (user:get_height() - 43)
	if offsetY > 0 then offsetY = 0 end
	local fading = false
	local isWind = false
	local barrier = user:create_node()
	local barrierRef = {}
	barrierRef.remove_barrier = false
	remove_barrier = false
	local HP = 100
	barrier:set_layer(3)
	barrier:set_texture(BARRIER_TEXTURE, true)
	local barrier_animation = Engine.Animation.new(BARRIER_ANIMATION_PATH)
	barrier_animation:set_state("BARRIER_IDLE")
	barrier_animation:refresh(barrier)
	if offsetY < 0 then
		barrier:set_offset(0, offsetY + (user:get_height() - barrier_animation:point("origin").y))
	end
	barrier_animation:set_playback(Playback.Loop)


	local barrier_defense_rule = Battle.DefenseRule.new(2, DefenseOrder.Always) -- Keristero's Guard is 0
	barrier_defense_rule.can_block_func = function(judge, attacker, defender)
		local attacker_hit_props = attacker:copy_hit_props()
		if attacker_hit_props.damage >= HP then
			HP = HP - attacker_hit_props.damage
		end
		judge:block_damage()
		if attacker_hit_props.element == Element.Wind then
			isWind = true
		end
	end

	local aura_animate_component = Battle.Component.new(user, Lifetimes.Scene)

	aura_animate_component.update_func = function(self, dt)
		barrier_animation:update(dt, barrier)
	end

	local aura_fade_countdown = 3000
	local aura_fade_component = Battle.Component.new(user, Lifetimes.Battlestep)
	aura_fade_component.update_func = function(self, dt)
		if aura_fade_countdown <= 0 then
			destroy_aura = true
		else
			aura_fade_countdown = aura_fade_countdown - 1
		end
	end

	local aura_destroy_component = Battle.Component.new(user, Lifetimes.Scene)
	local destroy_aura = false
	aura_destroy_component.update_func = function(self, dt)
		if isWind and not fading then
			remove_barrier = true
		end

		if destroy_aura and not fading then
			remove_barrier = true
		end

		if HP <= 0 and not fading then
			remove_barrier = true
		end

		if barrier_defense_rule:is_replaced() then
			remove_barrier = true
		end

		if (remove_barrier or barrierRef.remove_barrier) and not fading then
			fading = true
			user:remove_defense_rule(barrier_defense_rule)
			user.aura_on = false

			barrier_animation:set_state("BARRIER_FADE")
			barrier_animation:refresh(barrier)
			barrier_animation:set_playback(Playback.Once)

			barrier_animation:on_complete(function()
				user:sprite():remove_node(barrier)
				aura_fade_component:eject()
				aura_animate_component:eject()
				aura_destroy_component:eject()
			end)

			if isWind then
				local initialX = barrier:get_offset().x
				local initialY = barrier:get_offset().y
				local facing_check = 1
				if user:get_facing() == Direction.Left then
					facing_check = -1
				end

				barrier_animation:on_frame(1, function()
					barrier:set_offset(facing_check * (-25 - initialX), -20 + initialY)
				end)

				barrier_animation:on_frame(2, function()
					barrier:set_offset(facing_check * (-50 - initialX), -40 + initialY)
				end)

				barrier_animation:on_frame(3, function()
					barrier:set_offset(facing_check * (-75 - initialX), -60 + initialY)
				end)
			end
		end
	end

	user:add_defense_rule(barrier_defense_rule)
	user:register_component(aura_fade_component)
	user:register_component(aura_destroy_component)
	user:register_component(aura_animate_component)
	return barrierRef
end

return chip
