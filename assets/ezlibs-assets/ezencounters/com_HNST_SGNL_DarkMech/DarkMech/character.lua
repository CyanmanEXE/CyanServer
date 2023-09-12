-- Includes
local battle_helpers = include("battle_helpers.lua")
local thunder = include("Thunder/entry.lua")
local slash_spell = include("slash.lua")

-- Animations and Textures
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_ANIMATION_ARM = _folderpath .. "battle_arm.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.png")
local TELEPORT_TEXTURE = Engine.load_texture(_folderpath .. "teleport.png")
local TELEPORT_ANIM = _folderpath .. "teleport.animation"
local LOCKON_TEXTURE = Engine.load_texture(_folderpath .. "lockon.png")
local LOCKON_ANIM = _folderpath .. "lockon.animation"
local LOCKON_SOUND = Engine.load_audio(_folderpath .. "lockon.ogg")

--possible states for character
local states = { DEFAULT = 1, THUNDER = 2, SLASH = 3 }

-- local instance = 1

-- actions for states

-- Code that runs in the default state
---@param frame number
local action_default = function(self, frame)
    -- print("DarkMech" .. self.instance .. ": DEFAULT: ",frame)
    if frame == self.frames_between_actions then
        if not battle_helpers.any_stunned_enemy(self) then
            self.move_counter = self.move_counter + 1
            local anim = self:get_animation()
            local anim_arm = self.armNode_anim
            local target_tile = battle_helpers.get_random_adjacent(self)
            local current_tile = self:get_current_tile()
            if not target_tile then target_tile = current_tile end
            target_tile:reserve_entity_by_id(self:get_id())
            anim:set_state("IDLE")
            anim_arm:set_state("IDLE")
            battle_helpers.spawn_visual_artifact(self:get_field(), target_tile, TELEPORT_TEXTURE, TELEPORT_ANIM,
                "MEDIUM_TELEPORT_TO",
                0, -36, -1)
            anim:on_frame(2, function() self:teleport(target_tile, ActionOrder.Immediate) end)
            anim:on_complete(function()
                battle_helpers.spawn_visual_artifact(self:get_field(), current_tile, TELEPORT_TEXTURE, TELEPORT_ANIM,
                "MEDIUM_TELEPORT_FROM",
                0, -36, -1)
                anim:set_state("IDLE")
                anim_arm:set_state("IDLE")
                anim:on_complete(function()
                    if (self.move_counter < 2) then
                        self.set_state(states.DEFAULT)
                    else
                        self.move_counter = 0
                        self.set_state(states.THUNDER)
                    end
                end)
            end)
        else
           self.set_state(states.SLASH)
        end
    end
end

--- Code that runs in the thunder state
---@param frame number
local action_thunder = function(self, frame)
    -- print("DarkMech" .. self.instance .. ": THUNDER: ",frame)
    if frame == self.frames_between_actions+1 then
        if not battle_helpers.any_stunned_enemy(self) then
            local anim = self:get_animation()
            local anim_arm = self.armNode_anim
            anim:set_state("THUNDER_READY")
            anim_arm:set_state("THUNDER_READY")
            anim:on_complete(function()
                anim:set_state("THUNDER_COUNTER")
                anim_arm:set_state("THUNDER_COUNTER")
                anim:on_frame(3, function() self.set_state(states.DEFAULT) end)
                anim:on_frame(5, function() self:toggle_counter(true) end)
                anim:on_complete(function()
                    battle_helpers.spawn_visual_artifact(self:get_field(), self:get_tile(), CHARACTER_TEXTURE, CHARACTER_ANIMATION,
                    "FLASH",
                    0, -4, nil, self:get_facing(), self:get_current_palette())
                    thunder.card_create_action(self)
                    anim:set_state("THUNDER_POST")
                    anim_arm:set_state("THUNDER_POST")
                    anim:on_frame(4, function() self:toggle_counter(false) end)
                end)
            end)
        else
            self.set_state(states.SLASH)
        end
    end
end

--- Code that runs in the slash state.
---@param frame number
local action_slash = function(self, frame)
    -- print("DarkMech" .. self.instance .. ": SLASH: ",frame)
    local anim = self:get_animation()
    local anim_arm = self.armNode_anim
    if frame == 1 then
        local first_accessible_stunned, target_tile = battle_helpers.get_first_accessible_stunned(self)
        
        if first_accessible_stunned then
            self.target = first_accessible_stunned
            target_tile:reserve_entity_by_id(self:get_id())
            battle_helpers.toggle_targeted_enemy(self.target, true)
            self.current_tile = self:get_current_tile()
            if self.target:get_tile(self:get_facing(), 1) == target_tile then
                self.turn_around = true
            end
            
            anim:set_state("SLASH_DASH")
            anim_arm:set_state("SLASH_DASH")
            battle_helpers.spawn_visual_artifact(self:get_field(), self.target:get_current_tile(), LOCKON_TEXTURE, LOCKON_ANIM,
                "4",
                0, -38, -2)
            Engine.play_audio(LOCKON_SOUND, AudioPriority.High)
            anim:on_frame(3, function()
                local slide_frames = math.abs(self.current_tile:x() - target_tile:x()) * 2
                if slide_frames == 0 then 
                    slide_frames = math.abs(self.current_tile:y() - target_tile:y()) * 2
                    if slide_frames == 0 then slide_frames = 1 end
                end
                battle_helpers.spawn_afterimages(self, slide_frames)
                self:slide(target_tile, frames(slide_frames), frames(0), ActionOrder.Immediate, function()
                    self.slide_done_frame = self.frame_counter + slide_frames
                    self:set_float_shoe(true)
                end)
            end)
            
        else
            anim:set_state("IDLE")
            anim_arm:set_state("IDLE")
            battle_helpers.spawn_visual_artifact(self:get_field(), self:get_current_tile(), TELEPORT_TEXTURE, TELEPORT_ANIM,
                "MEDIUM_TELEPORT_TO",
                0, -36, -1)
            anim:on_complete(function()
                battle_helpers.spawn_visual_artifact(self:get_field(), self:get_current_tile(), TELEPORT_TEXTURE, TELEPORT_ANIM,
                "MEDIUM_TELEPORT_FROM",
                0, -36, -1)
                self.set_state(self.previous_state)
            end)
        end
        
    elseif frame == self.slide_done_frame then
        local target_tile = self:get_current_tile()
        if self.turn_around then self:set_facing(self:get_facing_away()) end
        self:toggle_counter(true)
        anim:set_state("SLASH")
        anim_arm:set_state("SLASH")
        anim:on_frame(2, function()
            self.current_tile:reserve_entity_by_id(self:get_id())
            self:set_float_shoe(false) 
        end)
        anim:on_frame(3, function() slash_spell.create_slash(self, self.damage) end)
        anim:on_frame(6, function() self:toggle_counter(false) end)
        anim:on_frame(7, function() self:teleport(self.current_tile, ActionOrder.Immediate) end)
        anim:on_complete(function()
            if self.turn_around then 
                self:set_facing(self:get_facing_away())
                self.turn_around = false
            end
            
            battle_helpers.toggle_targeted_enemy(self.target, false)
            battle_helpers.remove_stunned_character(self.target)
            self.target = nil
            battle_helpers.spawn_visual_artifact(self:get_field(), self.current_tile, TELEPORT_TEXTURE, TELEPORT_ANIM,
            "MEDIUM_TELEPORT_TO",
            0, -36, -1)
            battle_helpers.spawn_visual_artifact(self:get_field(), target_tile, TELEPORT_TEXTURE, TELEPORT_ANIM,
            "MEDIUM_TELEPORT_FROM",
            0, -36, -1)
            anim:set_state("IDLE")
            anim_arm:set_state("IDLE")
            self.set_state(self.previous_state)
        end)
    end
end

-- Load character resources
---@param self Entity
function package_init(self, character_info)
    -- self.instance = instance
    -- instance = instance + 1
    -- Required function, main package information
    self:set_texture(CHARACTER_TEXTURE)
    self.animation = self:get_animation()
    self.animation:load(CHARACTER_ANIMATION)
    -- Load extra resources
    -- Set up character meta
    -- Common Properties
    self:set_name(character_info.name)
    self:set_health(character_info.hp)
    self:set_height(character_info.height)
    self:set_offset(0, -4)
    self:set_palette(Engine.load_texture(character_info.palette))
    self.damage = (character_info.damage)
    self.frames_between_actions = character_info.frames_between_actions
    self.thunder_speed = character_info.thunder_speed
    self:set_element(Element.Break)

    --Other Setup
    self:set_explosion_behavior(4, 1, false)
    self.stun_time = (character_info.stun_time)
    -- entity will spawn with this animation.
    self.animation:set_state("IDLE")
    self.frame_counter = 0
    self.started = false
    --This defense rule is added to prevent enemy from gaining invincibility after taking damage.
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)
    self.move_counter = 0
    --This helps with the SLASH state
    self.slide_done_frame = 0
    self.current_tile = nil
    self.turn_around = false
    self.target = nil
    -- DarkMech's front arm
    self.armNode = self:create_node()
    self.armNode:set_texture(CHARACTER_TEXTURE)
    self.armNode_anim = Engine.Animation.new(CHARACTER_ANIMATION_ARM)
    self.armNode:set_layer(-2)
    self.armNode_anim:set_state("IDLE")
    self.armNode_anim:refresh(self.armNode)
    self.armNode:enable_parent_shader(true)
    
    local ref = self
    -- This is how we animate nodes. <- Node stuff borrowed from louise_swordy!
    self.animate_component = Battle.Component.new(self, Lifetimes.Battlestep)
    self.animate_component.update_func = function(self, dt)
        ref.armNode_anim:update(dt, ref.armNode)
    end
    self:register_component(self.animate_component)
    
    -- DarkMech's custom move so it can slide into enemy territory
    self.can_move_to_func = function(next_tile)
        if not next_tile:is_walkable() or 
            (self.state ~= states.SLASH and next_tile:get_team() ~= self:get_team()) or   
            next_tile:is_reserved({ self:get_id(), self._reserver }) then
            return false
        else
            return true
        end
    end
    
    --utility to set the update state, and reset frame counter
    ---@param state number
    self.set_state = function(state)
        self.previous_state = self.state
        self.state = state
        self.frame_counter = 0
    end
    
    local actions = { [1] = action_default, [2] = action_thunder, [3] = action_slash }
    self.update_func = function()
        self.frame_counter = self.frame_counter + 1
        if not self.started then
            self.started = true
            self.state = states.DEFAULT
            self.set_state(states.DEFAULT)
            self.frame_counter = self.frames_between_actions - 2
            battle_helpers.init(self)
        else
            battle_helpers.update(self)
            local action_func = actions[self.state]
            action_func(self, self.frame_counter)
        end
    end
    
    --Untargets enemy in case it dies mid-attack or such
    self.delete_func = function()
        if self.target then battle_helpers.toggle_targeted_enemy(self.target, false) end
    end
end

return package_init