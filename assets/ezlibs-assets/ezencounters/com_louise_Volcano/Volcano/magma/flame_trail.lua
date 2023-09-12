local texture = Engine.load_texture(_folderpath.."firering.png")
local animPath = _folderpath.."firering.animation"
local flameDuration = 90;

flame_trail= {}

function flame_trail.create_flame_trail(user, damage, tile)
    local spell = Battle.Spell.new(user:get_team())
    spell:set_hit_props(
        HitProps.new(
            damage, 
            Hit.Flinch, 
            Element.Fire, 
            user:get_id(), 
            Drag.None
        )
    )
    local sprite = spell:sprite()
    spell.duration = 0
    sprite:set_texture(texture)
    local anim = spell:get_animation()
    anim:load(animPath)
    anim:set_state("IDLE")
    anim:set_playback(Playback.Loop)
    anim:refresh(sprite)

    spell.update_func = function(self, dt)
        if(self.duration > flameDuration)then
            spell:erase()
        end
            self:get_current_tile():attack_entities(self)
        
        spell.duration = spell.duration + 1
    end

    spell.attack_func = function(self, other) 
        spell:erase()
    end
    spell.delete_func = function(self)
        spell:erase()
    end
    spell.battle_end_func = function(self)
		spell:erase()
	end
    user:get_field():spawn(spell, tile)
end

return flame_trail