local battle_helpers = include("battle_helpers.lua")
local character_animation = _folderpath.."battle.animation"
local anim_speed = 1
local corn_sfx = Engine.load_audio(_folderpath .. "popcorn.ogg")
local cornshot_texture = Engine.load_texture(_folderpath .. "cornshot.png")
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")
local cornshot_anim = _folderpath .. "cornshot.animation"
local cornblast = Engine.load_texture(_folderpath .. "cornblast.png")
local cornblast_fx = Engine.load_audio(_folderpath .. "cornblastfx.ogg")
local cornblast_anim_path = _folderpath .. "cornblast.animation"
local corn_delay = 40
local areagrab_chip = include("AreaGrab/entry.lua")

function package_init(self, character_info)
    -- Required function, main package information
    -- Load character resources
    local base_animation_path = character_animation
	self:set_texture(CHARACTER_TEXTURE, true)
    self.animation = self:get_animation()
    self.animation:load(base_animation_path)
	self.animation:set_playback_speed(anim_speed)
    -- Load extra resources
    -- Set up character meta
    self:set_name(character_info.name)
    self:set_health(character_info.hp)
    self:set_height(character_info.height)
    self.hop_time = (character_info.move_speed)
    self.damage=(character_info.damage)
    self.cornshots = character_info.cornshots
    self:share_tile(false)
    self:set_explosion_behavior(4, 1, false)
    self:set_offset(0, 0)
    self:set_element(Element.Wood)
    self:set_palette(Engine.load_texture(character_info.palette))
    self.has_areagrab=(character_info.has_areagrab)
	
    self.animation:set_state("SPAWN")
    self.frame_counter=0
    self.frames_between_actions = 100 
    self.started = false
    self.attack_count=0
    self.state = "None"
    self.move_direction = Direction.Right
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)
    
    -- mob tracker stuff.

    self.corn_action = function ()
        self.animation:set_state("ATTACK")
        self.animation:on_frame(6,function ()
            self:toggle_counter(true)
        end)
        self.animation:on_complete(function ()
            self:toggle_counter(false)
            self.animation:set_state("ATTACK_END")
            Engine.play_audio(corn_sfx, AudioPriority.Highest)
            self.state = "attacking"    
            local corn_tiles = find_tiles(self)
            local corn1 = nil
            for index, value in pairs(corn_tiles) do
                    toss_spell(self, 100, cornshot_texture, cornshot_anim, value, 40, function()
                    create_corn_blast(self, value, cornblast, cornblast_anim_path, cornblast_fx)
                    self.animation:set_state("IDLE")
                    self.animation:set_playback(Playback.Loop)
                    self.state="IDLE"
                    self.frame_counter=0
                    if(self.attack_count== 4 and self.has_areagrab) then
                        local grab = areagrab_chip.card_create_action(self)
                        self:card_action_event(grab, ActionOrder.Involuntary)
                        self.has_areagrab=false
                    else                    
                    self.attack_count=self.attack_count+1
                    end
                end)
            end
            end)
        end

	self.update_func = function ()
        if not self.started then
            self.current_direction=self:get_facing()
            self.enemy_dir=self:get_facing()
            self.started=true
        end
        self.frame_counter=self.frame_counter+1
        if(self.state == "IDLE" or self.state == "None") then
                if(self.frame_counter%2 == 0) then
                idle(self)        
                end
        elseif self.state == "attacking" then
        elseif self.state == "IN_AIR" then
            if(self.frame_counter==self.hop_time) then
                land(self)
            end
        end
end

function idle(self)
    begin_hop(self)
end
function begin_hop(self)
    --begin hop
    self.animation:set_state("BEGIN_HOP")
    self.state="BEGIN_HOP"
    self.animation:on_complete(function()
        try_hop(self, true)
    end)
end

function try_hop(self, try_again)
    local target_tile = self:get_tile(self.move_direction, 1)
    local play_hop_anim = function()
        self.animation:set_state("IN_AIR")
        self.state="IN_AIR"
        self.frame_counter=0
    end
    if(target_tile:get_team() ~= self:get_team() and self.move_direction==self.enemy_dir) then
        self:corn_action()
        self.frame_counter=0
        self.state = "prepare_attack"
        self.move_direction = Direction.reverse(self.move_direction)
        return
    else

    if(target_tile:is_edge() or not battle_helpers.can_move_to_func(target_tile, self)) then
            self.move_direction = Direction.reverse(self.move_direction)
            if(try_again) then
            try_hop(self, false)
            return
            else
                --stuck, hop in place.
                play_hop_anim()
            end
    end
    self:slide(target_tile, frames(self.hop_time), frames(0), ActionOrder.Voluntary, play_hop_anim)
    end
end

function land(self)
    self.animation:set_state("LAND")
    self.animation:on_complete(function ()
        local target_tile = self:get_tile(self.move_direction, 1)
        if(target_tile:get_team() ~= self:get_team() and self.move_direction==self.enemy_dir) then
            self:corn_action()
            self.frame_counter=0
            self.state = "prepare_attack"
            self.move_direction = Direction.reverse(self.move_direction)
            return
        else 
        self.state="IDLE"
        self.frame_counter=0
    end
    end)
end


function toss_spell(tosser,toss_height,texture,animation_path,target_tile,frames_in_air,arrival_callback)
    local starting_height = -110
    local start_tile = tosser:get_current_tile()

    local field = tosser:get_field()
    local spell = Battle.Spell.new(tosser:get_team())
    local spell_animation = spell:get_animation()
    spell_animation:load(animation_path)
    spell_animation:set_state("DEFAULT")
    spell_animation:set_playback(Playback.Loop)
    if tosser:get_height() > 1 then
        starting_height = -(tosser:get_height())
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
    spell:set_offset(spell.x_offset,spell.y_offset)

    spell.update_func = function(self)
        target_tile:highlight(Highlight.Flash)
        if not spell.jump_started then
            self:jump(target_tile, toss_height, frames(frames_in_air), frames(frames_in_air), ActionOrder.Voluntary)
            self.jump_started = true
        end
        if self.y_offset < 0 then
            self.y_offset = self.y_offset + math.abs(self.starting_y_offset/frames_in_air)
            self.x_offset = self.x_offset - math.abs(self.starting_x_offset/frames_in_air)
            self:set_offset(self.x_offset,self.y_offset)
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

function create_corn_blast(user,target_tile,texture,anim_path,explosion_sound)
    local field = user:get_field()
    local spell = Battle.Spell.new(user:get_team())
    local spell_animation = spell:get_animation()
    spell:set_hit_props(
        HitProps.new(
            user.damage,
            Hit.Impact | Hit.Flinch, 
            Element.Wood,
            user:get_context(), 
            Drag.None
        )
    )
    spell_animation:load(anim_path)
    spell_animation:set_state("DEFAULT")
    spell:set_texture(texture)
    spell:sprite():set_layer(-2)
    spell_animation:refresh(spell:sprite())
    spell_animation:set_playback(Playback.Loop)
	spell.hits = 1
    local do_once = true
    spell.has_attacked = false
    spell.update_func = function(self, dt)
        if not spell.has_attacked then
            spell:get_current_tile():attack_entities(self)
            spell_animation:refresh(spell:sprite())
            spell_animation:on_frame(12, function()
                if spell.hits > 1 then
                    spell.hits = spell.hits - 1
                    local hitbox = Battle.Hitbox.new(spell:get_team())
                    if spell.hits == 1 then
                        local props = HitProps.new(
                            HitProps.new(
                                bomb.damage,
                                Hit.Impact | Hit.Flinch | Hit.Flash, 
                                bomb.element,
                                user:get_context(), 
                                Drag.None
                            )
                        )
                        hitbox:set_hit_props(props)
                    else
                        hitbox:set_hit_props(spell:copy_hit_props())
                    end
                    field:spawn(hitbox, spell:get_current_tile())
                    --Engine.play_audio(AUDIO, AudioPriority.High)
                else
                    spell:erase()
                end
            end)
            do_once = false
        end
        self:get_current_tile():attack_entities(self)
    end
    Engine.play_audio(explosion_sound, AudioPriority.Low)
    spell.collision_func = function(self, other)
    end
    spell.attack_func = function(self, other) 
    end
    spell.delete_func = function(self)
        self:erase()
    end
    spell.can_move_to_func = function(tile)
        return true
    end
    field:spawn(spell, target_tile)
end



function find_tiles(self)
    local target_char = find_target(self)
    local target_tile = target_char:get_tile()
    local tilePatterns = {}
    local team = self:get_team()
    local enemy_field = getEnemyField(team, target_tile, self:get_field())
    shuffle(enemy_field)
    --targets will always contain the target tile, plus extras.
    table.insert(tilePatterns, target_tile)
    for i = 1, self.cornshots-1, 1 do
        table.insert(tilePatterns, enemy_field[i])
    end
   
    return tilePatterns
end
  --get the enemy field, besides the target tile.
function getEnemyField(team, target_tile, field)
    local tile_arr = {}
    for i = 1, 6, 1 do
        for j = 1, 3, 1 do
            local tile = field:tile_at(i, j)
            if(tile ~= target_tile and tile:get_team() ~= team) then
                table.insert(tile_arr,tile)
            end
        end
    end
    return tile_arr
end

--find a target character
function find_target(self)
    local field = self:get_field()
    local team = self:get_team()
    local target_list = field:find_characters(function(other_character)
        return other_character:get_team() ~= team
    end)
    if #target_list == 0 then
        return
    end
    local target_character = target_list[1]
    return target_character
end



function tiletostring(tile) 
    return "Tile: [" .. tostring(tile:x()) .. "," .. tostring(tile:y()) .. "]"
end

--shuffle function to provide some randomness 
function shuffle(tbl)
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
  end


end
return package_init