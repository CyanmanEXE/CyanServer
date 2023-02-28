local DAMAGE = 100
local SLASH_TEXTURE = Engine.load_texture(_folderpath .. "spell_sword_slashes.png")
local BLADE_TEXTURE = Engine.load_texture(_folderpath .. "spell_sword_blades.png")
local AUDIO = Engine.load_audio(_folderpath .. "sfx.ogg")
local chip = {}

chip.card_create_action = function(actor, props)
	print("in create_card_action()!")
	local action = Battle.CardAction.new(actor, "PLAYER_SWORD")
	action:set_lockout(make_animation_lockout())
	action.execute_func = function(self, user)
		self:add_anim_action(2,
			function()
				local hilt = self:add_attachment("HILT")
				local hilt_sprite = hilt:sprite()
				hilt_sprite:set_texture(actor:get_texture())
				hilt_sprite:set_layer(-2)
				hilt_sprite:enable_parent_shader(true)

				local hilt_anim = hilt:get_animation()
				hilt_anim:copy_from(actor:get_animation())
				hilt_anim:set_state("HILT")

				local blade = hilt:add_attachment("ENDPOINT")
				local blade_sprite = blade:sprite()
				blade_sprite:set_texture(BLADE_TEXTURE)
				blade_sprite:set_layer(-1)

				local blade_anim = blade:get_animation()
				blade_anim:load(_folderpath .. "spell_sword_blades.animation")
				blade_anim:set_state("DEFAULT")
			end
		)

		self:add_anim_action(3,
			function()
				local sword = create_slash(user, props)
				local tile = user:get_tile(user:get_facing(), 1)
				actor:get_field():spawn(sword, tile)
				local fx = Battle.Artifact.new()
				fx:set_facing(sword:get_facing())
				local anim = fx:get_animation()
				fx:set_texture(SLASH_TEXTURE, true)
				anim:load(_folderpath .. "spell_sword_slashes.animation")
				anim:set_state("BIG")
				anim:on_complete(
					function()
						fx:erase()
						sword:erase()
					end
				)
				actor:get_field():spawn(fx, tile)
			end
		)
	end
	return action
end

function create_slash(user, props)
	local spell = Battle.Spell.new(user:get_team())
	spell:set_facing(user:get_facing())
	spell:highlight_tile(Highlight.Flash)
	spell:set_hit_props(
		HitProps.new(
			props.damage,
			Hit.Impact | Hit.Flinch | Hit.Flash,
			props.element,
			user:get_context(),
			Drag.None
		)
	)

	spell.update_func = function(self, dt)
		if not self:get_tile():get_tile(user:get_facing(), 1):is_edge() then
			self:get_tile():get_tile(user:get_facing(), 1):highlight(Highlight.Flash)
			self:get_tile():get_tile(user:get_facing(), 1):attack_entities(self)
		end
		if not self:get_tile():get_tile(user:get_facing(), 2):is_edge() then
			self:get_tile():get_tile(user:get_facing(), 2):highlight(Highlight.Flash)
			self:get_tile():get_tile(user:get_facing(), 2):attack_entities(self)
		end
		self:get_tile():attack_entities(self)
	end

	spell.can_move_to_func = function(tile)
		return true
	end

	Engine.play_audio(AUDIO, AudioPriority.Low)

	return spell
end

return chip
