chip = {}

chip.card_create_action = function(actor, props)
    if (actor:get_health() == actor:get_max_health()) then return end

    local recov = create_recov("DEFAULT", actor)
    actor:get_field():spawn(recov, actor:get_current_tile())
    actor:set_health(actor:get_health() + 1000)

end

function create_recov(animation_state, user)
    local spell = Battle.Spell.new(Team.Other)

    spell:set_texture(Engine.load_texture(_modpath .. "spell_heal.png"), true)
    spell:set_facing(user:get_facing())
    spell:set_hit_props(
        HitProps.new(
            0,
            Hit.None,
            Element.None,
            user:get_context(),
            Drag.None
        )
    )
    spell:sprite():set_layer(-1)
    local anim = spell:get_animation()
    anim:load(_modpath .. "spell_heal.animation")
    anim:set_state(animation_state)
    spell:get_animation():on_complete(
        function()
            spell:erase()
        end
    )

    spell.delete_func = function(self)
        self:erase()
    end

    spell.can_move_to_func = function(tile)
        return true
    end

    Engine.play_audio(Engine.load_audio(_modpath .. "sfx.ogg"), AudioPriority.High)

    return spell
end

return chip
