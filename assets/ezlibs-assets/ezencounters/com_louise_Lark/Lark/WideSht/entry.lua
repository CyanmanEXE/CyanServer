local SHOT_TEXTURE = Engine.load_texture(_folderpath .. "wideshot.png")
local AUDIO = Engine.load_audio(_folderpath .. "sfx.ogg")


local chip = {}

function package_init(package)
	package:declare_package_id("com.mars.card.wideshot")
	package:set_icon_texture(Engine.load_texture(_folderpath .. "icon.png"))
	package:set_preview_texture(Engine.load_texture(_folderpath .. "preview.png"))
	package:set_codes({ '*' })

	local props = package:get_card_props()
	props.shortname = "WideShot"
	props.damage = 100
	props.time_freeze = false
	props.element = Element.Aqua
	props.description = "Fire 3sq Shotgun blast!"
	props.long_description = "WideShot with fixed behavior. BN6 version"
	props.limit = 3
end

chip.card_create_action = function(user, props)
	local shot = create_wideshot(user, props)
	local tile = user:get_tile(user:get_facing(), 1)
	user:get_field():spawn(shot, tile)
end


function create_wideshot(user, props)
	local spell = Battle.Spell.new(user:get_team())
	spell:set_facing(user:get_facing())
	spell:set_name("WideSht")
	spell:set_hit_props(
		HitProps.new(
			props.damage,
			Hit.Impact | Hit.Flinch | Hit.Flash,
			props.element,
			user:get_context(),
			Drag.None
		)
	)
	local attacking = false
	local anim = spell:get_animation()
	spell:set_texture(SHOT_TEXTURE, true)
	anim:load(_folderpath .. "wideshot.animation")
	anim:set_state("STARTUP")
	anim:on_complete(function()
		anim:set_state("DEFAULT")
		anim:set_playback(Playback.Loop)
		attacking = true
	end)

	spell.update_func = function(self, dt)
		if not attacking then return end

		self:get_tile():get_tile(Direction.Up, 1):attack_entities(self)
		self:get_tile():attack_entities(self)
		self:get_tile():get_tile(Direction.Down, 1):attack_entities(self)

		if self:is_sliding() == false then
			if self:get_current_tile():is_edge() then
				self:delete()
			end
			local dest = self:get_tile(spell:get_facing(), 1)
			local ref = self
			self:slide(dest, frames(props.speed), frames(0), ActionOrder.Voluntary, nil)
		end
	end
	spell.collision_func = function(self, other)
		self:delete()
	end
	spell.delete_func = function(self)
		self:erase()
	end
	spell.can_move_to_func = function(tile)
		return true
	end

	Engine.play_audio(AUDIO, AudioPriority.Low)

	return spell
end

return chip
