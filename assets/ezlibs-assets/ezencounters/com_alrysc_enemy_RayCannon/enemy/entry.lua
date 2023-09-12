local texture = nil
local shell_texture = nil
local shot_texture = nil
local bomber_texture = nil

local SEARCH_SFX = nil
local LOCK_ON_SFX = nil

local EXPLOSION_SFX = nil

local CANNON_SFX = nil

--[[
    The lock on cursor needs to be manually updated by the enemy. Yeah, when it's stunned, the cursor stays put.
    Delete cursor on delete
]]

function package_init(self)
    texture = Engine.load_texture(_folderpath.."raycannon.png")
    shell_texture = Engine.load_texture(_folderpath.."shell.png")
    shot_texture = Engine.load_texture(_folderpath.."shot.png")
    bomber_texture = Engine.load_texture(_folderpath.."bomber.png")

    local anim = nil

  --  alert = Engine.load_texture(_folderpath.."overlay_fx07_animations.png")
    --hit_effects_texture = Engine.load_texture(_folderpath.."hit_effects.png")
    
    
	self:set_element(Element.None)
    self:set_texture(texture, true)
    self:set_height(60)
    self:share_tile(false)
    self:set_explosion_behavior(8, 6, false)


    anim = self:get_animation()
    anim:load(_folderpath.."raycannon.animation")

    HIT_SFX = Engine.load_audio(_folderpath.."hit.ogg")

    CANNON_SFX = Engine.load_audio(_folderpath.."cannon.ogg")
    LOCK_ON_SFX = Engine.load_audio(_folderpath.."lockon.ogg")
    SEARCH_SFX = Engine.load_audio(_folderpath.."search.ogg")

    init_enemy(self)

end

function init_enemy(self)
	local version = self:get_rank() + 1
    self.damage = 15 + 15 * ((version - 1) * 2)
    self.palette = version
    self.max_health = 60 * version
    self.speed = 9 - math.min(version * 2, 8)

    self.name = "RayCann"..version

    if version == 0 then
        self.name = "RayCann".."SP"
        self.damage = 100
        self.max_health = 1000
        self.speed = 2
    elseif version == 1 then 
        self.name = "RayCann"
    
    elseif version > 3 then 
        local suffix = version - 3
        self.name = "RayCannEX"
        if suffix > 1 then 
            self.name = self.name..suffix
        end

        self.speed = 2
        self.palette = 4
    end

    self:set_name(self.name)

    self.on_spawn_func = function()
        self:set_name(self.name)

    end

    self:set_health(self.max_health)

    -- Setting names here is just convenience if I want to print the state I'm in later
    self.states = {
        neutral = {name = "NEUTRAL", func = neutral},
        search = {name = "SEARCH", func = search},
        attack = {name = "ATTACK", func = attack},
    }
    
    local s = self.states
    
    self.defense1 = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense1)
    
    self.anim = self:get_animation()
    self.idle_frames = 60
    self.idle_count = 0 -- Will count up to idle frames, loop back to 0
    self.target_tile = nil
    self.lockon = false

    self.current_target_frame = -1 -- Apparently the very first search lasts an extra frame
    self.current_target_index = 1
    self.target_anim_frames = {
        self.speed-1,
        self.speed, 
        self.speed, 
        1
    }

    self.attack_frame = 0
    self.attack_index = 1
    self.attack_anim = {
        self.speed,
        self.speed,
        self.speed,
        self.speed
    }

    self.targets = {}


    self.state = self.states.neutral


    self.anim:set_state("NEUTRAL_"..self.palette)
    self.anim:set_playback(Playback.Loop)    


    self.delete_func = function(self)
        if self.targets[1] then 
            for i=1, #self.targets
            do
                local target = self.targets[i]
                target:hide()
                target:delete()
                self.targets[i] = nil
                self.target_tile = nil
                self.lockon = false
            end
        end

        self.update_func = function(self)

        end

    end


    self:register_status_callback(Hit.Root, function() self.rooted = 120 end)

    -- Bring it back next build. For now, relying on the stun callback
    --[[
    self.on_countered = function(self)
        print("Countered")
        self:toggle_counter(false)
        self.hit_func(self)

    end
    --]]

    self.can_move_to_func = function(tile)
        if tile:is_edge() or not tile:is_walkable() then
            return false
        end

        if(tile:is_reserved({})) then
            return false
        end

        if (tile:get_team() ~= self:get_team()) then
            return false
        end

        return not check_obstacles(tile, self) --and not check_characters(tile, self)
    end

    self.rooted = 0
    self.update_func = function(self)
      --  print("     ", self.state.name, self.moving_to_enemy_tile)
        if self.rooted > 0  then self.rooted = self.rooted - 1 end
        self.state.func(self)
     --   check_collision(self)
    end
    
end

function start_neutral(self)
    self:toggle_counter(false)
    self.anim:set_state("NEUTRAL_"..self.palette)
    self.anim:refresh(self:sprite())

    self.state = self.states.neutral
end

function neutral(self)
    self.idle_count = self.idle_count + 1
    if self.idle_count > self.idle_frames then 
        self.state = self.states.search
        self.idle_count = 0

        self.target_tile = self:get_tile(self:get_facing(), 1)
    end

end

local function update_target_frame(self)

    if self.current_target_frame == self.target_anim_frames[self.current_target_index] then 
        self.current_target_frame = 0


        self.current_target_index = self.current_target_index + 1
        if self.current_target_index == 5 then 
            Engine.play_audio(SEARCH_SFX, AudioPriority.Low)
        else
            for i=1, #self.targets
            do
                local target = self.targets[i]
                target:get_animation():set_state("TARGET_"..self.current_target_index)
                target:get_animation():refresh(target:sprite())
                
            end
        end

        if self.current_target_index == 5 then
            -- move
            self.current_target_index = 1

            local first = true
            for i=1, #self.targets 
            do
                local target = self.targets[i]
                if not self.lockon then 
                    target.should_move = false

                    local t = target:get_tile(target:get_facing(), 1)
                    if t and not t:is_edge() then 
                        target:get_current_tile():remove_entity_by_id(target:get_id())
                        t:add_entity(target)
                        self.target_tile = t -- Don't worry about the fact that this will put target_tile as the last target's tile in version 0

                        -- This could be above if I don't do else. But I don't want to sometimes change state twice in one frame
                            -- Which would happen if we get lockon
                        target:get_animation():set_state("TARGET_"..self.current_target_index)
                        target:get_animation():refresh(target:sprite())
                    else
                        target:delete()
                        self.targets[i] = nil
                        self.target_tile = nil
                        self.state = self.states.neutral
                    end
                    
                    -- move, maybe update? Not sure if I should, especially if I change animation state for locked on
                        -- That also happens here

                    -- This will set state for action, and also change anim state
                else 
                    if first then 
                        Engine.play_audio(LOCK_ON_SFX, AudioPriority.Low)
                        start_attack(self)
                    end
                    
                    target:get_animation():set_state("TARGET_LOCK")
                    target:get_animation():refresh(target:sprite())
                end

                first = false
            end
        end
    end

    self.current_target_frame = self.current_target_frame + 1
end

function init_target(target)
    target.should_move = false
    local an = target:get_animation()
    an:set_state("TARGET_1")
    
end

function search(self)
    if not self.targets[1] then 
        self.current_target_frame = 0
        self.current_target_index = 1
        self.target_tile = self:get_tile(self:get_facing(), 1)
        if self.palette > 0 then 
            self.targets[1] = graphic_init("artifact", 0, 0, texture, "raycannon.animation", -99, "TARGET_1", self, self:get_facing())
            local an = self.targets[1]:get_animation()
          
            an:refresh(self.targets[1]:sprite())

      
            self:get_field():spawn(self.targets[1], self.target_tile)
        else -- Version 0 check
            local field = self:get_field()
            local off = {
                1, 
                0, 
                -1
            }
            for i=1, 3
            do
                local t = field:tile_at(self.target_tile:x(), self.target_tile:y() + off[i])
                if t and not t:is_edge() then 
                    table.insert(self.targets, graphic_init("artifact", 0, 0, texture, "raycannon.animation", -99, "TARGET_1", self, self:get_facing()))
                    local an = self.targets[#self.targets]:get_animation()
                    
                    an:refresh(self.targets[#self.targets]:sprite())

                
                    field:spawn(self.targets[#self.targets], t)
                end
            end
        end
        
        
    end
    if self.palette > 0 then 
        local enemies = self.target_tile:find_characters(function(c) return c:get_team() ~= self:get_team() end)
        if #enemies > 0 then 
            self.lockon = true
        else
            local obstacles = self.target_tile:find_obstacles(function(c) return c:get_team() ~= self:get_team() end)
            if #obstacles > 0 then 
                self.lockon = true
            end
        end
        
    else -- This is the version 0 check, which will only check that X is the same.
        local enemies = self:get_field():find_characters(function(c)
            return c:get_team() ~= self:get_team() and c:get_current_tile():x() == self.target_tile:x()
        end)
        if #enemies > 0 then 
            self.lockon = true
        else
            local obstacles = self:get_field():find_obstacles(function(c)
                return c:get_team() ~= self:get_team() and c:get_current_tile():x() == self.target_tile:x()
            end)
            if #obstacles > 0 then 
                self.lockon = true
            end
        end
    end

    update_target_frame(self)

end

function start_attack(self)
    self:toggle_counter(true)
    self.state = self.states.attack
    self.anim:set_state("ATTACK_"..self.attack_index.."_"..self.palette)
    create_cannon_effect(self)
end

function finish_attack(self)
    self.attack_index = 1
    self.attack_frame = 0

    -- Shanghai uses the same counter for idle time, and also counting which animation frame it's on for attacking and searching
        -- So when it comes off the attack, it's already on frame 4. 4 plays twice, actually, so one more after that
    self.idle_count = 5


    self:sprite():remove_node(self.cannon_effect)
    self.cannon_effect = nil
    self.cannon_effect_anim = nil

    self.anim:refresh(self:sprite())

    for i=1, #self.targets
    do
        local target = self.targets[i]
        target:hide()
        target:delete()
        self.targets[i] = nil
        self.target_tile = nil
        self.lockon = false
    end

    start_neutral(self)

end

function attack(self)
    self.attack_frame = self.attack_frame + 1
    if self.attack_frame >= self.speed then 
        self.attack_index = self.attack_index + 1
        if self.attack_index > 4 then 
            finish_attack(self)
        
        else
            self.attack_frame = 0
            self.anim:set_state("ATTACK_"..self.attack_index.."_"..self.palette)
            self.anim:refresh(self:sprite())

            if self.attack_index == 2 then
                for i=1, #self.targets
                do
                    cannon_attack(self, self.targets[i]:get_current_tile())
                end
            end
        end


    end

    if self.attack_index == 1 and self.attack_frame == self.speed - 1 then 
        -- ONB graphic is being a frame late, so I'm spawning it a frame early
        -- Lowest speed this virus gets is 2, so it works out for everything I hope
        create_big_shell_handler(self)
    end

    if self.cannon_effect_anim then 
        self.cannon_effect_anim:update(1/60, self.cannon_effect)
    end

end

function create_cannon_effect(self)
    local node = self:create_node()
    local node_anim = Engine.Animation.new(_folderpath.."shot.animation")

    node:set_texture(shot_texture)
    node:set_layer(-1)
    node_anim:set_state("CANNON_SHOT")
    node:set_offset(22, -38)

    -- Update right now because we won't end up updating this frame otherwise
    --node_anim:update(1/60, node)
    

    node_anim:refresh(node)

    self.cannon_effect = node
    self.cannon_effect_anim = node_anim
end

function cannon_attack(self, tile)
    Engine.play_audio(CANNON_SFX, AudioPriority.Low)
    self:shake_camera(20, 0.084) -- I'm using 20 to be same as Shanghai 5 power shake
    local field = self:get_field()
    local explosion = graphic_init("artifact", 0, 0, bomber_texture, "bomber.animation", -100, "EXPLOSION_1", self, self:get_facing(), true)

    local spell = Battle.Spell.new(self:get_team())
    spell.lifetime = 3

    spell:set_hit_props(
		HitProps.new(
			self.damage,
			Hit.Impact | Hit.Flinch | Hit.Flash,
			Element.None,
			self:get_id(),
			Drag.None
		)
	)

    spell.update_func = function(self)
        self:get_current_tile():attack_entities(self)
        self:get_current_tile():highlight(Highlight.Solid)
        self.lifetime = self.lifetime - 1
        if self.lifetime == 0 then 
            self:delete()
        end
    end

    spell.attack_func = function()
        Engine.play_audio(HIT_SFX, AudioPriority.Low)
    end

    field:spawn(explosion, tile)
    field:spawn(spell, tile)


end

function create_big_shell_handler(self)
    local artifact = Battle.Artifact.new()
    artifact:set_facing(self:get_facing())
    local shell_anim = _folderpath.."shell.animation"
    local texture = shell_texture
    local shells = {}
    local layer = 0
    artifact:sprite():set_layer(-1)

    local function bound_update(shell)     
        shell[3] = shell[3] - shell.moveX
        shell[4] = shell[4] - shell.moveY
        shell.plusY = shell.plusY + shell.speed
        shell.speed = shell.speed - shell.plusing
     

        -- Position direct is set here. pX, pY are positionDirect
    end
    local function create_shell(parent, start_pos, pX, pY, pZ, time, count, graphics, state)
        layer = layer - 1
        
        local n = parent:create_node()
        n:set_texture(texture)
        n:set_layer(layer)
        local anim = Engine.Animation.new(shell_anim)
       -- anim:load(path)
        anim:set_state(state)
        n:set_offset(pX, pY)

        anim:refresh(n)


        local t = {n, anim, pX, pY, pZ, time, count, 0}

        t.end_pos = {
            x = (start_pos.x - (4 + 8 * count)),
            y = start_pos.y + pZ
        }
        t.moveX = (pX - t.end_pos.x) / time
        t.moveY = (pY - t.end_pos.y) / time

        t.speed = 6
        t.plusY = 0.0
        t.plusing = t.speed / (time /2)
        
        table.insert(graphics, t)
    end

    local function reinit_shell(shell, start_pos, pX, pY, pZ, time, count, spin)
       -- shell[1]:set_offset(start_pos.x, start_pos.x)


        shell.end_pos = {
            x = (start_pos.x - (4 + 8 * count)),
            y = start_pos.y + pZ
        }
        shell.moveX = (pX - shell.end_pos.x) / time
        shell.moveY = (pY - shell.end_pos.y) / time

        shell.speed = 6
        shell.plusY = 0.0
        shell.plusing = shell.speed / (time /2)
        shell[8] = 0
        shell[6] = time
        shell[7] = count
    end

    local function update_shell(shell)
        local spin = shell[5]

        shell[2]:set_state("shell"..shell[5])
        shell[2]:refresh(shell[1])
        spin = spin + 1
        if spin > 9 then 
            spin = 0 
        end


        bound_update(shell)
        -- Bound update updates pX, pY, which is positionDirect
        -- When we render, we use an extra offset from positionDirect

        shell[1]:set_offset(shell[3], shell[4] - shell.plusY/2)

        shell[5] = spin

        local frame = shell[8]
        frame = frame + 1

        if frame > shell[6] then 
            if shell[7] > 0 then 
       --         print("Well, a new one should have been made. Count is ", count, " so this is sending in ", count-1)
                reinit_shell(shell, shell[1]:get_offset(), shell[3], shell[4], 0, math.floor(shell[6]/2), shell[7]-1, shell[5])
            else
                artifact:hide()
                artifact:delete()
                
            end

            return
        end

        shell[8] = frame

        
    end

    artifact.update_func = function(self)
        for i=1, #shells
        do
            update_shell(shells[i])
        end

        if #shells == 0 then 
            self:delete()
        end
    end
   -- (parent, start_pos, pX, pY, pZ, time, count, spin, graphics, state)

    local start_pos = {
        x = -16,
        y = -16
    }

    create_shell(artifact, start_pos, -16, -16, 32, (40 + math.random(0, 20)), 2, shells, "shell"..0)
    artifact:get_animation():refresh(artifact:sprite())

    self:get_field():spawn(artifact, self:get_current_tile())
end

function check_obstacles(tile, self)
    local ob = tile:find_obstacles(function(o)
        return o:get_health() > 0 and o:get_id() ~= self:get_id()
    end)

    return #ob > 0 
end


function check_characters(tile, self)
    local characters = tile:find_characters(function(c)
        return c:get_id() ~= self:get_id() and c:get_team() ~= self:get_team()
    end)

    return #characters > 0

end

function graphic_init(type, x, y, texture, animation, layer, state, user, facing, delete_on_complete, flip)
    flip = flip or false
    delete_on_complete = delete_on_complete or false
    facing = facing or nil
    
    local graphic = nil
    if type == "artifact" then 
        graphic = Battle.Artifact.new()

    elseif type == "spell" then 
        graphic = Battle.Spell.new(user:get_team())
    
    elseif type == "obstacle" then 
        graphic = Battle.Obstacle.new(user:get_team())

    end

    graphic:sprite():set_layer(layer)
    graphic:never_flip(flip)
    graphic:set_texture(texture, true)
    if facing then 
        graphic:set_facing(facing)
    end
    
    if user:get_facing() == Direction.Left then 
        x = x * -1
    end
    graphic:set_offset(x, y)
    local anim = graphic:get_animation()
    anim:load(_folderpath..animation)

    anim:set_state(state)
    anim:refresh(graphic:sprite())

    if delete_on_complete then 
        anim:on_complete(function()
            graphic:delete()
        end)
    end

    return graphic
end