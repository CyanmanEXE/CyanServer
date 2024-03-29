local debug = false

local attachment_texture = Engine.load_texture(_folderpath .. "attachment.png")
local attachment_animation_path = _folderpath .. "attachment.animation"
local explosion_texture = Engine.load_texture(_folderpath .. "explosion.png")
local explosion_sfx = Engine.load_audio(_folderpath .. "explosion.ogg")
local explosion_animation_path = _folderpath .. "explosion.animation"
local throw_sfx = Engine.load_audio(_folderpath .. "toss_item.ogg")

function debug_print(text)
    if debug then
        print("[ball] " .. text)
    end
end

local chip = {
    name = "Ball",
    damage = 140,
    element = Element.Break,
    description = "Breaks 3rd panel ahead",
    codes = { "C", "T", "Z", "B", "V", "*" }
}

chip.card_create_action = function(user, props, target_tile_in)
    local action = Battle.CardAction.new(user, "PLAYER_THROW")
    action:set_lockout(make_animation_lockout())
    local override_frames = { { 1, 0.064 }, { 2, 0.064 }, { 3, 0.064 }, { 4, 0.064 }, { 5, 0.064 } }
    local frame_data = make_frame_data(override_frames)
    action:override_animation_frames(frame_data)

    local hit_props = HitProps.new(
        props.damage,
        Hit.Impact | Hit.Flinch | Hit.Flash,
        props.element,
        user:get_context(),
        Drag.None
    )

    action.execute_func = function(self, user)
        --local props = self:copy_metadata()
        local attachment = self:add_attachment("HAND")
        local attachment_sprite = attachment:sprite()
        attachment_sprite:set_texture(attachment_texture)
        attachment_sprite:set_layer(-2)

        local attachment_animation = attachment:get_animation()
        attachment_animation:load(attachment_animation_path)
        attachment_animation:set_state("DEFAULT")

        user:toggle_counter(true)
        self:add_anim_action(3, function()
            attachment_sprite:hide()
            --self.remove_attachment(attachment)
            local tiles_ahead = 3
            local frames_in_air = 40
            local toss_height = 70
            local facing = user:get_facing()
            local target_tile = target_tile_in
            if not target_tile then
                return
            end
            action.on_landing = function()
                if target_tile:is_walkable() then
                    hit_explosion(user, target_tile, hit_props, explosion_texture, explosion_animation_path,
                        explosion_sfx)
                end
            end
            toss_spell(user, toss_height, attachment_texture, attachment_animation_path, target_tile, frames_in_air,
                action.on_landing)
        end)
        self:add_anim_action(4, function()
            user:toggle_counter(false)
        end)


        Engine.play_audio(throw_sfx, AudioPriority.Highest)
    end
    return action
end

function toss_spell(tosser, toss_height, texture, animation_path, target_tile, frames_in_air, arrival_callback)
    local starting_height = -110
    local start_tile = tosser:get_current_tile()
    local field = tosser:get_field()
    local spell = Battle.Spell.new(tosser:get_team())
    local spell_animation = spell:get_animation()
    spell_animation:load(animation_path)
    spell_animation:set_state("DEFAULT")
    if tosser:get_height() > 1 then
        starting_height = -(tosser:get_height() * 2)
    end

    spell.jump_started = false
    spell.starting_y_offset = starting_height
    spell.starting_x_offset = 10
    if tosser:get_facing() == Direction.Left then
        spell.starting_x_offset = -10
    end
    spell.y_offset = spell.starting_y_offset
    spell.x_offset = spell.starting_x_offset
    local sprite = spell:sprite()
    sprite:set_texture(texture)
    spell:set_offset(spell.x_offset, spell.y_offset)

    spell.update_func = function(self)
        if not spell.jump_started then
            self:jump(target_tile, toss_height, frames(frames_in_air), frames(frames_in_air), ActionOrder.Voluntary)
            self.jump_started = true
        end
        if self.y_offset < 0 then
            self.y_offset = self.y_offset + math.abs(self.starting_y_offset / frames_in_air)
            self.x_offset = self.x_offset - math.abs(self.starting_x_offset / frames_in_air)
            self:set_offset(self.x_offset, self.y_offset)
        else
            arrival_callback()
            self:delete()
        end
    end
    spell.can_move_to_func = function(tile)
        return true
    end
    field:spawn(spell, start_tile)
end

function hit_explosion(user, target_tile, props, texture, anim_path, explosion_sound)
    local field = user:get_field()
    local spell = Battle.Spell.new(user:get_team())

    local spell_animation = spell:get_animation()
    spell_animation:load(anim_path)
    spell_animation:set_state("DEFAULT")
    local sprite = spell:sprite()
    sprite:set_texture(texture)
    spell_animation:refresh(sprite)

    spell_animation:on_complete(function()
        spell:erase()
    end)

    spell:set_hit_props(props)
    spell.has_attacked = false
    spell.update_func = function(self)
        if not spell.has_attacked then
            Engine.play_audio(explosion_sound, AudioPriority.Highest)
            spell:get_current_tile():attack_entities(self)
            spell:get_current_tile():set_state(TileState.Cracked)
            spell.has_attacked = true
        end
    end
    field:spawn(spell, target_tile)



end

return chip
