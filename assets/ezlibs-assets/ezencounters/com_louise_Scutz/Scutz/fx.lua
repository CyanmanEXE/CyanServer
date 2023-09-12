---@class FxHelper
fx_helper = {}


--- create hit effect.
---comment
---@param field A field to spawn the effect on
---@param tile Tile tile to spawn effect on
---@param hit_texture any Texture hit effect. (Engine.load_texture)
---@param hit_anim_path any The animation file path
---@param hit_anim_state any The hit animation to play
---@param sfx any Audio # Audio object to play
---@return any returns the hit fx
function fx_helper.create_hit_effect(field, tile, hit_texture, hit_anim_path, hit_anim_state, sfx)
    local hitfx = Battle.Artifact.new()
    hitfx:set_texture(hit_texture, true)
    hitfx:set_offset(math.random(-40, 40), math.random(-30, 30))
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

return fx_helper
