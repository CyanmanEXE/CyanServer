
function package_init(self)
    local rank = self:get_rank()
   

    self.attacking = false
    self.done_attacking = false
    self.attack_end = 4
    self.moving = false
    self.move_start = 4
    self.current_loop = 0 
    self.has_looped = false
    self.fire_texture = Engine.load_texture(_modpath.."fire1.png")
    self.fire_animation = _modpath.."fire1.animation"
    self.move_texture = Engine.load_texture(_modpath.."move.png")
    self.move_animation = _modpath.."move.animation"


    self.fire_sound = Engine.load_audio(_modpath.."fire.ogg") 
    self.hit_sound = Engine.load_audio(_modpath.."damageenemy.ogg")

    self.fire_count = 0
    self.first_fire = false
    self.second_fire = false
    self.third_fire = false

    self.first_count = 0
    self.second_count = 0
    self.third_count = 0

    self.second_box = nil
    self.third_box = nil

    self.is_counterable = false
    self.counter_time = 0
    self.countered = false



    self.defense1 = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense1)

    self.defense2 = Battle.DefenseRule.new(9000, DefenseOrder.Always)
	self.defense2.filter_statuses_func = function(statuses)
        statuses.flags = statuses.flags & ~Hit.Drag

		return statuses
	end
	self:add_defense_rule(self.defense2)


    self:set_texture(Engine.load_texture(_modpath.."juraigon.png"))
    local anim = self:get_animation()
    

 
    if rank == Rank.V1 then 
        anim:load(_modpath.."juraigon.animation")
        self:set_name("Juragon")

        self:set_health(400)
        self.damage = 80
        self.moveLoop = 2
        self.nspeed = 8




    elseif rank == Rank.V2 then
        --blue
        anim:load(_modpath.."juraigon2.animation")
        self:set_name("Juragon2")

        self:set_health(600)
        self.damage = 120
        self.moveLoop = 2
        self.nspeed = 7

    elseif rank == Rank.V3 then
        --gray
        anim:load(_modpath.."juraigon3.animation")
        self:set_name("Juragon3")

        self:set_health(1000)
        self.damage = 180
        self.moveLoop = 2
        self.nspeed = 6

        -- gold next
        
    end

    anim:set_state("START")
    anim:refresh(self:sprite())

    local function create_extra_box(player, spawn_tile, facing)
        local extra_box = Battle.Character.new(player:get_team(), Rank.V1) -- I think making a character needs a rank; doesn't do anything hopefully
        extra_box:share_tile(false)
        extra_box:set_health(1)
        extra_box:set_float_shoe(true)
       
        extra_box.delete_func = function(self)
            self:erase()
        end

        extra_box.can_move_to_func = function()
            return true
        end

        extra_box.was_hit = false

        -- This is how I'll pass the spell from the defense rule to the component for spawning
        extra_box.spell_attack = nil

        -- Scene lifetime so that it'll trigger during time freeze
        local extra_box_component = Battle.Component.new(extra_box, Lifetimes.Scene)

        extra_box_component.update_func = function()

            -- The get_current_tile check may be bad if the player's hitbox is toggled off
                -- Everything else will probably be fine; may want to check later
                    -- The and check is probably unecessary, since I don't call this unless there is a spell attack to spawn
            if extra_box.was_hit and extra_box.spell_attack then 
                player:get_field():spawn(extra_box.spell_attack, player:get_current_tile())

                extra_box.was_hit = false
                extra_box.spell_attack = nil
            end

            if player:will_erase_eof() then
                extra_box:toggle_hitbox(false)
                extra_box:delete()
            end

            
        end

    
        extra_box.update_func = function(self)
            local target_tile = player:get_current_tile():get_tile(facing, 1)

            -- I want to check the tile behind the player, since that's where I want this to be
                -- If it isn't there at any point in time, I want it to move there
            if self:get_current_tile() ~= target_tile then 
                self:teleport(target_tile, ActionOrder.Immediate, nil)
            end
        
        end

        local extra_box_defense = Battle.DefenseRule.new(1, DefenseOrder.Always)


        extra_box_defense.can_block_func = function(judge, attacker, defender)
            
            local attacker_hit_props = attacker:copy_hit_props()
            --judge:block_impact()
            judge:block_damage()

            extra_box.spell_attack = Battle.Spell.new(attacker:get_team()) -- Team might not matter here, as in, maybe I can do get_opposing_team or whatever it was
            
            extra_box.spell_attack.update_func = function(self)
                self:get_current_tile():attack_entities(self)
                self:delete()
                -- I want it to delete right away so I don't have it lingering in the case the player is somehow able to dodge it
            end

            extra_box.spell_attack:set_hit_props(attacker_hit_props)
            extra_box.was_hit = true
            -- Defense rule should finish processing before the scene lifetime component comes in, but I'll put this toggle down here anyway

        end
        

        extra_box:add_defense_rule(extra_box_defense)
        extra_box:register_component(extra_box_component)

        player:get_field():spawn(extra_box, spawn_tile)

        return extra_box
    end


    self.battle_start_func = function()
        self.second_box = create_extra_box(self, self:get_current_tile():get_tile(self:get_facing_away(), 1), self:get_facing_away())
        self.third_box = create_extra_box(self, self:get_current_tile():get_tile(self:get_facing(), 1), self:get_facing())
        self.third_box:toggle_hitbox(false)
        self.third_box:share_tile(true)

        self.second_box_id = self.second_box:get_id()
        self.third_box_id = self.third_box:get_id()

        anim:set_state("IDLE")
        anim:refresh(self:sprite())
        anim:set_playback(Playback.Loop)
        anim:on_complete(function()
            if not self.has_looped then 
                self.current_loop = self.current_loop+1
            end
            self.has_looped = true
        
            anim:on_frame(1, function()
                self.has_looped = false
            end)
        end)
    end

    self._query = function(e)
        if e and not e:is_deleted() then
            local bool = Battle.Obstacle.from(e) ~= nil or (Battle.Character.from(e) ~= nil and e:get_id() ~= self.second_box_id and e:get_id() ~= self.third_box_id) or Battle.Player.from(e) ~= nil
            return bool
        end
        return false
    end

    self.can_move_to_func = function(tile)
        return tile and self:is_team(tile:get_team()) and tile:is_walkable() and not tile:is_edge() and #tile:find_entities(self._query) == 0
    end

    

    local function find_valid_move_location(self)
        local target_tile
        local field = self:get_field()
    
        local tiles = field:find_tiles(function(tile)
            return self.can_move_to_func(tile)
        end)
      
        if #tiles >= 1 then
            target_tile = tiles[math.random(#tiles)]
        else
            target_tile = self:get_tile()
        end
    
        return target_tile

    end



    local function create_spell(user, curX, curY, X, Y)
        if user:get_facing() == Direction.Left then 
            X = X * -1
        end

        local tile = user:get_field():tile_at(curX+X, curY+Y)

        if tile and (tile:x() > 0 and tile:x() < 7) and (tile:y() < 4 and tile:y() > 0) then 
            local hasHit = false
            local spell = Battle.Spell.new(user:get_team())
            local offsetY = 20
            local offsetX = -12

            if user:get_facing() == Direction.Left then 
                offsetX = offsetX * -1
            end

            spell:sprite():set_layer(-1)
            spell:set_facing(user:get_facing())
            spell:set_texture(user.fire_texture, true)
            spell:set_offset(offsetX, offsetY)
            spell:get_animation():load(user.fire_animation)
            spell:get_animation():set_state("FIRE"..user.fire_count)
    
            spell:get_animation():refresh(spell:sprite())
    
            spell:get_animation():on_complete(function()
                spell:get_animation():set_state("FADE")

                spell:get_animation():on_complete(function()
                    spell:erase()
                    
                end)
            end)

            local counter = 0

            spell:highlight_tile(Highlight.Solid)

            spell:set_hit_props(
                HitProps.new(
                self.damage,
                Hit.Flinch | Hit.Flash | Hit.Impact,
                Element.Fire,
                user:get_context(),
                Drag.None
                )
            )

            
            spell.can_move_to_func = function()
                return true
            end

            spell.update_func = function(self)
                if counter > 176 then  -- 5/6 over?
                  --  self:erase()
                  spell:highlight_tile(Highlight.None)
                else 
                    counter = counter + 1
                
                    if not hasHit then
                        spell:get_current_tile():attack_entities(self)
                    end
                end

            end


            spell.attack_func = function()
                Engine.play_audio(Engine.load_audio(_modpath.."damageenemy.ogg"), AudioPriority.Low)
                hasHit = true
            end

            user:get_field():spawn(spell, tile)

        end
    end


    self.update_func = function(self, dt)

        if self.current_loop >= self.moveLoop and not self.attacking then 
            self.attacking = true
            self.current_loop = 0
            anim:set_state("ATTACK_START")
            anim:refresh(self:sprite())
            self.is_counterable = true
            anim:on_complete(function()
                self.third_box:toggle_hitbox(true)
                self.third_box:share_tile(false)

                anim:set_state("ATTACK_LOOP")
                anim:refresh(self:sprite())
                anim:set_playback(Playback.Loop)
                anim:on_complete(function()
                    if not self.has_looped then 
                        self.current_loop = self.current_loop+1
                    end
                    self.has_looped = true
                
                    anim:on_frame(1, function()
                        self.has_looped = false
                    end)

                    if self.current_loop > 28 then 
                        anim:set_playback(Playback.Once)
                        self.done_attacking = true
                        
                    end
                end)
            end)
            
        end

        if self.done_attacking then 
            self.attack_end = self.attack_end - 1
            if self.attack_end == 0 then 
                self.has_looped = false
                self.current_loop = 0
                self.attacking = false
                self.fire_count = 0
                self.first_fire = false
                self.second_fire = false
                self.third_fire = false

                self.first_count = 0
                self.second_count = 0
                self.third_count = 0

                self.attack_end = 4

                self.moving = true
                self.done_attacking = false

                
            end
        end


        -- I think my flames animate for 3f longer
        if self.attacking then 
            if self.current_loop == 2 and self.fire_count == 0 then 

                self.first_count = self.first_count+1
                if self.first_count == 4 then 
                    self.fire_count = self.fire_count+1

                    local currentX = self:get_current_tile():x()
                    local currentY = self:get_current_tile():y()

                    Engine.play_audio(self.fire_sound, AudioPriority.Low)
                    create_spell(self, currentX, currentY, 2, 0)
                end
            end

            if self.current_loop == 4 and self.fire_count == 1 then 
                -- 1f too early, but can't do anything about it
                if self.second_fire then return end

                self.fire_count = self.fire_count+1


                local currentX = self:get_current_tile():x()
                local currentY = self:get_current_tile():y()
            
                create_spell(self, currentX, currentY, 3, 0)
                create_spell(self, currentX, currentY, 3, 1)
                create_spell(self, currentX, currentY, 3, -1)
                self.second_fire = true

            end

            if self.current_loop == 5 and self.fire_count == 2 then 
                self.third_count = self.third_count+1
                if self.third_count == 4 then

                    self.fire_count = self.fire_count+1

                    local currentX = self:get_current_tile():x()
                    local currentY = self:get_current_tile():y()
                
                    create_spell(self, currentX, currentY, 4, 0)
                    create_spell(self, currentX, currentY, 4, 1)
                    create_spell(self, currentX, currentY, 4, -1)
                    self.third_fire = true
                end
            end
        end


        if self.moving then 
            self.move_start = self.move_start - 1
            if self.move_start == 0 then 
                self.third_box:toggle_hitbox(false)
                self.third_box:share_tile(true)
                local target_tile = find_valid_move_location(self)
                if target_tile ~= self:get_current_tile() then 
                    local spell = Battle.Spell.new(self:get_team())
                    local offsetY = 0

                    spell:sprite():set_layer(-1)
                    spell:set_facing(self:get_facing())
                    spell:set_texture(self.move_texture, true)
                    spell:set_offset(0, offsetY)
                    spell:get_animation():load(self.move_animation)
                    spell:get_animation():set_state("DEFAULT")
            
                    spell:get_animation():refresh(spell:sprite())
            
                    spell:get_animation():on_complete(function()
                        spell:delete()
                    end)

                    self:get_field():spawn(spell, self:get_current_tile())
                    self:teleport(target_tile, ActionOrder.Voluntary)
                    
                end

                anim:set_state("IDLE")
                anim:refresh(self:sprite())
                anim:set_playback(Playback.Loop)
                anim:on_complete(function()
                    if not self.has_looped then 
                        self.current_loop = self.current_loop+1
                    end
                    self.has_looped = true
                
                    anim:on_frame(1, function()
                        self.has_looped = false
                    end)
                end)

                self.moving = false
                self.move_start = 4
            end
        end
        
        if self.is_counterable then 
            self.counter_time = self.counter_time + 1
            if self.counter_time == 2 then 
                self:toggle_counter(true)
            end
            if self.counter_time == 18 then 
               self:toggle_counter(false)
               self.is_counterable = false
               self.counter_time = 0
            end 
        end
    end


    self.on_counter = function()
        print("countered")
        self.countered = true
        

    end

    -- Just set counterable to false?
end