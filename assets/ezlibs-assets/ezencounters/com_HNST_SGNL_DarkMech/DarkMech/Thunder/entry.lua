local TEXTURE = Engine.load_texture(_folderpath.."thunder.png")
local ANIMATION_PATH = _folderpath.."thunder.animation"
local PALETTE_PATH = _folderpath.."palette.png"
local HIT_TEXTURE = Engine.load_texture(_folderpath.."hit.png")
local HIT_ANIMATION_PATH = _folderpath.."hit.animation"
local VERTICAL_OFFSET = -60

local chip = {}

local function execute(actor, props)
	local spell = Battle.Spell.new(actor:get_team())
	-- remember position of actor at time of spawning attack, 
	-- to prevent the actor from being able to influence the ball afterwards
	local direction = actor:get_facing()
    local team = actor:get_team()
	spell:set_texture(TEXTURE, true)
    spell:set_palette(Engine.load_texture(PALETTE_PATH))
	-- spell:highlight_tile(Highlight.Solid)

	local anim = spell:get_animation()
	anim:load(ANIMATION_PATH)
	anim:set_state("DEFAULT")
	anim:set_playback(Playback.Loop)

	spell:set_offset(-4, VERTICAL_OFFSET)

	Engine.play_audio(AudioType.Thunder, AudioPriority.High)

	spell:set_hit_props(
		HitProps.new(
			10,
			Hit.Flinch | Hit.Stun | Hit.Impact,
			Element.Elec,
			actor:get_context(),
			Drag.None
		)
	)

	-- the weak Thunder lasts for 300 frames
	local timeout = 300
	local elapsed = 0
	local target = nil
    local slide_speed = actor.thunder_speed


	local field = actor:get_field()
	spell.update_func = function(_, dt)
		if elapsed > timeout then
			spell:erase()
		end
		elapsed = elapsed + 1

		local tile = spell:get_current_tile()

		-- delete when going off field
		if tile:is_edge() then
			spell:erase()
		end

		-- If sliding is flagged to false, we know we've ended a move
		if not spell:is_sliding() then
			-- If there are no targets, aimlessly move right or left
			-- (save_direction gets determined once at spawn time)
            local nearest_characters = field:find_nearest_characters(spell, function(character)
                return character:get_team() ~= team
            end)

            -- We only change direction ONCE up or down.
            if (direction == Direction.Left or direction == Direction.Right) and #nearest_characters > 0 then
                target = nearest_characters[math.random(1, #nearest_characters)]
				local target_tile = target:get_current_tile()

				if target_tile and (direction == Direction.Left and target_tile:x() >= tile:x())
                    or (direction == Direction.Right and target_tile:x() <= tile:x()) then
					if target_tile:y() < tile:y() then
						direction = Direction.Up
					else
						direction = Direction.Down
					end
				end
			end
			-- Always slide to the tile we're moving to
			local next_tile = spell:get_tile(direction, 1)
            if (direction == Direction.Left or direction == Direction.Right) then
                spell:slide(next_tile, frames(slide_speed), frames(0), ActionOrder.Voluntary, nil)
            else
                spell:slide(next_tile, frames(math.ceil(slide_speed * 0.6)), frames(0), ActionOrder.Voluntary, nil)
            end
		end
		-- Always affect the tile we're occupying
		tile:attack_entities(spell)
	end

	spell.collision_func = function(self, other)
        if not other:is_passthrough() then spell:erase() end
	end
    
    spell.battle_end_func = function(self)
        spell:erase()
    end

	spell.attack_func = function()
		local artifact = Battle.Artifact.new()
        local offset = spell:get_tile_offset()
		artifact:sprite():set_layer(-1)
		artifact:set_texture(HIT_TEXTURE, true)
		artifact:set_offset(offset.x, VERTICAL_OFFSET)
		artifact:get_animation():load(HIT_ANIMATION_PATH)
		artifact:get_animation():set_state("DEFAULT")
		artifact:get_animation():on_complete(function()
			artifact:erase()
		end)

		local tile = spell:get_current_tile()
		field:spawn(artifact, tile:x(), tile:y())

		Engine.play_audio(AudioType.Hurt, AudioPriority.Highest)
	end

	spell.can_move_to_func = function() return true end

	local spawn_tile = actor:get_tile(actor:get_facing(), 1)
	field:spawn(spell, spawn_tile:x(), spawn_tile:y())
end

chip.card_create_action = function(actor, props)
    execute(actor, props)
end

return chip
