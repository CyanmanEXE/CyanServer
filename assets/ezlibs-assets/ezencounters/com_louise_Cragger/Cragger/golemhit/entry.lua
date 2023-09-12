--- Setup Textures, Animations and Sounds
--- modpath refers to the root folder of the chip.
local GOLEMPUNCH_SFX = Engine.load_audio(_folderpath .. "golempunch.ogg")
local GOLEM_IMPACT_TEXTURE = Engine.load_texture(_folderpath .. "shockwave.png")
local GOLEM_IMPACT_ANIM = _folderpath .. "shockwave.animation"

local GOLEMIMPACT_SFX = Engine.load_audio(_folderpath .. "golemimpact.ogg")

local GOLEMHIT_TEXTURE = Engine.load_texture(_folderpath .. "../arm.png")
local GOLEMHIT_ANIM = _folderpath .. "../arm.animation"

---@type BattleHelpers
local battleHelpers = include("../lib/battle_helpers.lua")

local chip = {}

chip.card_create_action = function(user, props)
    user.animation:set_state("PREPARE_ATTACK")
    user.arm_anim:set_state("PREPARE_ATTACK")
    local tile = get_target(user)
    local warning_tiles = { tile:get_tile(Direction.Up, 1), tile, tile:get_tile(Direction.Down, 1) }
    local warning = battleHelpers.create_warning_component(user, warning_tiles)

    user.animation:on_complete(function()
        user.animation:set_state("ATTACK")
        user.arm_anim:set_state("ATTACK")
        user.animation:on_frame(1, function()
            user:toggle_counter(true)
        end)
        user.animation:on_frame(4, function()
            user:toggle_counter(false)
            local direction = user:get_facing()
            Engine.play_audio(GOLEMPUNCH_SFX, AudioPriority.High)
            warning:eject()
            create_golem_hand(user, tile, props.damage)
        end)
    end)

end

function get_target(user)
    return battleHelpers.find_target(user):get_tile()
end

function setup_sprite(spell, texture, animpath)
    local sprite = spell:sprite()
    sprite:set_texture(texture)
    sprite:set_layer(-3)
    -- Setup animation of the spell
    local anim = spell:get_animation()
    anim:load(animpath)
    anim:refresh(sprite)
end

---@param user Entity The user summoning a golemHit
---@param tile Tile The tile to summon the golemHit on
---@param damage number The amount of damage the golemHit will do
---@param speed number The number of frames it takes the golemHit to travel 1 tile.
---@param direction any The direction the
function create_golem_hand(user, tile, damage)
    -- Creates a new spell that belongs to the user's team.
    local spell = Battle.Spell.new(user:get_team())
    -- Setup sprite of the spell
    spell:set_hit_props(
        HitProps.new(
            damage,
            Hit.Impact | Hit.Flash | Hit.Flinch | Hit.Drag | Hit.Breaking,
            Element.Break,
            user:get_context(),
            Drag.new()
        )
    )

    setup_sprite(spell, GOLEMHIT_TEXTURE, GOLEMHIT_ANIM)
    spell:set_palette(user:get_current_palette())
    local anim = spell:get_animation()
    anim:set_state("ATTACK_SPELL")

    anim:on_frame(7, function()
        if (tile:is_walkable()) then
            spell:shake_camera(8, 0.5)
            Engine.play_audio(GOLEMIMPACT_SFX, AudioPriority.Highest)
            create_golem_impact(damage, user, spell:get_tile():get_tile(Direction.Up, 1), true)
            create_golem_impact(damage, user, spell:get_tile():get_tile(Direction.Down, 1), true)
            create_golem_impact(damage, user, spell:get_tile(), true)
        else
            tile:attack_entities(spell)
        end
    end)
    anim:on_complete(function()
        user.idle()
        user.set_current_action(user.action_move)
        spell:erase()
    end)
    spell:set_facing(user:get_facing())

    spell.delete_func = function(self)
        spell:erase()
    end
    spell.battle_end_func = function(self)
        spell:erase()
    end

    --- Function that decides whether or not this spell is allowed
    --- to move to a certain tile. This is automatically called for
    --- functions such as slide and teleport.
    --- In this case since it always returns true, it can move over
    --- any tile.
    spell.can_move_to_func = function(tile)
        return true
    end
    user:get_field():spawn(spell, tile)
    return spell
end

function create_golem_impact(damage, user, tile, doDamage)
    local spell = Battle.Spell.new(user:get_team())
    --Set the hit properties of this spell.
    spell:set_hit_props(
        HitProps.new(
            damage,
            Hit.Impact | Hit.Flash | Hit.Flinch | Hit.Drag | Hit.Breaking,
            Element.Break,
            user:get_context(),
            Drag.new()
        )
    )

    setup_sprite(spell, GOLEM_IMPACT_TEXTURE, GOLEM_IMPACT_ANIM)
    local anim = spell:get_animation()
    anim:set_state("1")
    anim:on_complete(function()
        spell:erase()
    end)
    local do_once = doDamage
    user:get_field():spawn(spell, tile)
    spell.update_func = function()
        if (do_once) then
            ---@type Tile

            tile:attack_entities(spell)
            if (tile:get_state() == TileState.Cracked) then
                tile:set_state(TileState.Broken)
            else
                tile:set_state(TileState.Cracked)
            end
            do_once = false
        end
    end
end

--- create hit effect.
---@param field any #A field to spawn the effect on
---@param tile Tile tile to spawn effect on
---@param hit_texture any Texture hit effect. (Engine.load_texture)
---@param hit_anim_path any The animation file path
---@param hit_anim_state any The hit animation to play
---@param sfx any Audio # Audio object to play
---@return any returns the hit fx
function create_hit_effect(field, tile, hit_texture, hit_anim_path, hit_anim_state, sfx)
    -- Create artifact, artifacts do not have hitboxes and are used mostly for special effects
    local hitfx = Battle.Artifact.new()
    hitfx:set_texture(hit_texture, true)
    -- This will randomize the position of the effect a bit.
    hitfx:set_offset(math.random(-25, 25), math.random(-25, 25))
    local hitfx_sprite = hitfx:sprite()
    hitfx_sprite:set_layer(-3)
    local hitfx_anim = hitfx:get_animation()
    hitfx_anim:load(hit_anim_path)
    hitfx_anim:set_state(hit_anim_state)
    hitfx_anim:refresh(hitfx_sprite)
    hitfx_anim:on_frame(1, function()
        Engine.play_audio(sfx, AudioPriority.Highest)
    end)
    hitfx_anim:on_complete(function()
        hitfx:erase()
    end)
    field:spawn(hitfx, tile)
    return hitfx
end

return chip
