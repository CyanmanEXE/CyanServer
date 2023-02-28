---@class FxHelper
fx_helper = {}


--- create fx effect.
---comment
---@param field A field to spawn the effect on
---@param tile Tile tile to spawn effect on
---@param fx_texture any Texture fx effect. (Engine.load_texture)
---@param fx_anim_path any The animation file path
---@param fx_anim_state any The fx animation to play
---@param sfx any Audio # Audio object to play
---@return any returns the fx fx
function fx_helper.create_hit_effect(field, tile, fx_texture, fx_anim_path, fx_anim_state, sfx)
    local fxeffect = fx_helper.create_basic_effect(field, tile, fx_texture, fx_anim_path, fx_anim_state, sfx)
    Engine.play_audio(sfx, AudioPriority.Highest)
    return fxeffect
end

--- create a self deleting basic effect.
---comment
---@param field A field to spawn the effect on
---@param tile Tile tile to spawn effect on
---@param hit_texture any Texture hit effect. (Engine.load_texture)
---@param hit_anim_path any The animation file path
---@param hit_anim_state any The hit animation to play
---@return any returns the hit fx
function fx_helper.create_basic_effect(field, tile, hit_texture, hit_anim_path, hit_anim_state)
    local fx = Battle.Artifact.new()
    fx:set_texture(hit_texture, true)
    local fx_sprite = fx:sprite()
    fx_sprite:set_layer(-3)
    local fx_anim = fx:get_animation()
    fx_anim:load(hit_anim_path)
    fx_anim:set_state(hit_anim_state)
    fx_anim:refresh(fx_sprite)
    fx_anim:on_complete(function()
        fx:erase()
    end)
    field:spawn(fx, tile)
    return fx
end

return fx_helper
