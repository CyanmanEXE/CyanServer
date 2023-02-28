local battle_helpers = include("battle_helpers.lua")
local character_animation = _folderpath .. "battle.animation"
local anim_speed = 1
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")
local areagrab_chip = include("AreaGrab/entry.lua")
local scan_sound = Engine.load_audio(_folderpath .. "scan.ogg")
local airshot_sound = Engine.load_audio(_folderpath .. "airshot.ogg")
local attack_sprite = Engine.load_texture(_folderpath .. "attack.png")
local attack_animations = _folderpath .. "attack.animation"
local teleport_texture = Engine.load_texture(_folderpath .. "teleport.png")
local teleport_anim = _folderpath .. "teleport.animation"
local impacts_texture = Engine.load_texture(_folderpath .. "impacts.png")
local impacts_animation_path = _folderpath .. "impacts.animation"

--possible states for character
local states = { IDLE = 1, SCAN = 2, ATTACK = 3, TELEPORT = 4 }
-- Load character resources
local piranhas = {}
local nm_mode = false
---@param self Entity
function package_init(self, character_info)
    -- Required function, main package information

    local base_animation_path = character_animation
    self:set_texture(CHARACTER_TEXTURE)
    self.animation = self:get_animation()
    self.animation:load(base_animation_path)
    self.animation:set_playback_speed(anim_speed)
    -- Load extra resources
    -- Set up character meta
    self:set_name(character_info.name)
    self:set_health(character_info.hp)
    self:set_height(character_info.height)
    self.hop_time = (character_info.move_speed)
    self.damage = (character_info.damage)
    self:share_tile(false)
    self:set_explosion_behavior(4, 1, false)
    self:set_offset(0, 0)
    self.cursor_speed = character_info.cursor_speed
    --piranha is water elem
    self:set_element(Element.Aqua)
    self:set_palette(Engine.load_texture(character_info.palette))
    self:set_air_shoe(true)
    self.has_areagrab = (character_info.has_areagrab)
    self.animation:set_state("SPAWN")
    self.frame_counter = 0
    self.frames_between_actions = character_info.frames_between_actions
    self.started = false
    self.attack_count = 0

    self.move_direction = Direction.Right
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)


    -- actions for states
    -- state idle
    self.action_idle = function(frame)
        if (frame == 1) then
            self.animation:set_state("IDLE")
            self.animation:set_playback(Playback.Loop)
        end
        if (frame == self.frames_between_actions) then
            self.set_state(states.TELEPORT)
        end
    end
    ---state attack
    ---@param frame number
    self.action_attack = function(frame)
        if (frame == 1) then
            self.animation:set_state("IDLE")
            --22 frame delay before attack starts
        elseif (frame == 22) then

            self.animation:on_frame(4, function()
                self:toggle_counter(true)
                self.animation:set_state("ATTACK_BEGIN")
                self.animation:on_complete(function()
                    --create arrow
                    self:toggle_counter(false)
                    Engine.play_audio(airshot_sound, AudioPriority.High)
                    create_arrow(self)
                    self.animation:set_state("ATTACK")
                    self.animation:on_complete(function()
                        self.animation:set_state("ATTACK_END")
                        self.animation:on_complete(function()
                            self.animation:set_state("IDLE")
                            self.set_state(states.IDLE)
                        end)
                    end)
                end)
            end)
        end
    end

    ---state scan
    ---@param frame number
    self.action_scan = function(frame)
        if (frame == 1) then
            self.animation:set_state("SCAN")
            create_scanner(self)
        end
    end

    ---state teleport
    ---@param frame number
    self.action_teleport = function(frame)
        if (frame == 1) then
            battle_helpers.spawn_visual_artifact(self:get_field(), self:get_tile(), teleport_texture, teleport_anim,
                "MEDIUM_TELEPORT_FROM",
                0, 0)
        end
        if (frame == 3) then
            local tile = self:get_tile(Direction.Down, 1);
            if (tile:is_edge()) then
                tile = self:get_tile(Direction.Up, 2)
            end
            local moved = self:teleport(tile, ActionOrder.Involuntary, nil)
            if moved then
                battle_helpers.spawn_visual_artifact(self:get_field(), tile, teleport_texture, teleport_anim,
                    "MEDIUM_TELEPORT_TO",
                    0, 0)
            end
        elseif (frame == 20) then
            self.set_state(states.SCAN)
        end
    end

    self.on_spawn_func = function(self)
        table.insert(piranhas, self)

    end

    self.delete_func = function(self)
        removebyId(piranhas, self)
    end

    --utility to set the update state, and reset frame counter
    ---@param state number
    self.set_state = function(state)
        self.state = state
        self.frame_counter = 0
    end

    local actions = { [1] = self.action_idle, [2] = self.action_scan, [3] = self.action_attack,
        [4] = self.action_teleport }

    self.update_func = function()
        self.frame_counter = self.frame_counter + 1
        if not self.started then
            self.current_direction = self:get_facing()
            self.enemy_dir = self:get_facing()
            self.started = true
            self.set_state(states.IDLE)
        else
            local action_func = actions[self.state]
            action_func(self.frame_counter)
        end
    end

    ---Used by piranha to create a scanner
    ---@param owner Entity
    function create_scanner(owner)
        owner.ignore_cursor = false
        local team = owner:get_team()
        local field = owner:get_field()
        local direction = owner:get_facing()
        local y_offset = -20;
        ---@type Spell
        local spell = Battle.Spell.new(team)
        local direction_offset = 1
        if (direction == Direction.Left) then
            direction_offset = -1
        end

        spell.nextile = owner:get_tile(direction, 2)
        spell.starttile = owner:get_tile(direction, 1)
        spell:set_facing(owner:get_facing())
        local speed = spell.starttile:width() / owner.cursor_speed
        spell.speed = math.floor(speed)
        spell.fractional_speed = math.fmod(speed, 1)
        spell.fractional_portion = 0
        spell.target_found = false
        spell:sprite():set_layer(-5)
        spell:set_hit_props(HitProps.new(
            0,
            Hit.None,
            Element.None,
            owner:get_context(),
            Drag.new()
        ))


        local sprite = spell:sprite()
        sprite:set_texture(attack_sprite)
        spell:set_offset(0, y_offset)
        spell.wait_frames = 0

        local animation = spell:get_animation()
        animation:load(attack_animations)
        animation:set_state("CURSOR")
        animation:refresh(sprite)
        Engine.play_audio(scan_sound, AudioPriority.High)
        spell.update_func = function()
            if (not spell.target_found) then
                if (spell:get_actual_tile():is_edge()) then
                    spell:erase()
                    if (not owner:is_deleted() and owner.state == states.SCAN) then
                        owner.set_state(states.IDLE)
                    end
                end
                if (spell.wait_frames == 1) then

                    local extra = 0
                    if (spell.fractional_portion > 1) then
                        extra = 1
                        spell.fractional_portion = spell.fractional_portion - 1
                    end
                    local totalSpeed = direction_offset * spell.speed + extra
                    spell:set_offset(spell:get_offset().x + totalSpeed, y_offset)
                    spell.fractional_portion = spell.fractional_portion + spell.fractional_speed
                    spell.wait_frames = 0
                end
                spell.wait_frames = spell.wait_frames + 1
                spell:get_actual_tile():attack_entities(spell)
            end
        end

        spell.get_actual_tile = function(self)
            local start_tile = self:get_current_tile()
            if (spell:get_offset().x == 0) then
                return start_tile
            end
            local tiles_travelled = math.floor(math.abs(spell:get_offset().x) / start_tile:width())
            return start_tile:get_tile(self:get_facing(), tiles_travelled)
        end

        spell.can_move_to_func = function(self)
            return true
        end

        spell.collision_func = function(self, other)
            if (Battle.Character.from(other) == nil) then
                return
            end
            spell.target_found = true
            local begin = function()
                spell:set_offset(0, y_offset)
            end
            spell:teleport(spell:get_actual_tile(), ActionOrder.Involuntary, begin)

            spell:get_animation():set_state("TARGET_FOUND")
            spell:get_animation():on_complete(function()
                spell:get_animation():set_state("TARGET_LOCK")
                spell:get_animation():on_complete(function()
                    spell:erase()
                end)
            end)
            --all piranhas will attack
            for index, piranha in pairs(piranhas) do
                if (not piranha:is_deleted() and not piranha.ignore_cursor) then
                    piranha.set_state(states.ATTACK)
                    piranha.ignore_cursor = true
                end

            end

        end
        field:spawn(spell, spell.starttile)
    end

    ---Used by piranha to create an arrow
    ---@param owner Entity
    function create_arrow(owner)
        local team = owner:get_team()
        local field = owner:get_field()
        local direction = owner:get_facing()
        ---@type Spell
        local spell = Battle.Spell.new(team)
        spell.nextile = owner:get_tile(direction, 2)
        spell.starttile = owner:get_tile(direction, 1)
        spell:set_facing(owner:get_facing())
        spell.wait_frames = 18
        spell:sprite():set_layer(-5)
        spell:set_hit_props(HitProps.new(
            owner.damage,
            Hit.Impact | Hit.Flinch,
            Element.Aqua,
            owner:get_context(),
            Drag.new()
        ))


        local sprite = spell:sprite()
        sprite:set_texture(attack_sprite)
        spell:set_offset(0, -40)

        local animation = spell:get_animation()
        animation:load(attack_animations)
        animation:set_state("ARROW")
        animation:refresh(sprite)
        spell.update_func = function()
            spell:highlight_tile(Highlight.Solid)
            if (spell:get_current_tile():is_edge()) then
                spell:erase()
            end
            if (not spell:is_sliding()) then
                local can_slide = spell:slide(spell.nextile, frames(6), frames(0), ActionOrder.Immediate, nil)
                spell.nextile = spell.nextile:get_tile(direction, 1)
                spell.wait_frames = 0
            end
            spell.wait_frames = spell.wait_frames + 1
            spell:get_current_tile():attack_entities(spell)
        end

        spell.can_move_to_func = function(self)
            return true
        end

        spell.collision_func = function(self, dt)
            local artifact = Battle.Artifact.new()
            artifact:never_flip(true)
            artifact:set_texture(impacts_texture)
            artifact:set_animation(impacts_animation_path)
            --FX
            local anim = artifact:get_animation()
            anim:set_state("3")
            anim:on_complete(function()
                artifact:erase()
            end)
            spell:erase()
            field:spawn(artifact, spell:get_current_tile())
        end
        field:spawn(spell, spell.starttile)
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

    function removebyId(tab, val)
        for i, v in pairs(tab) do
            if (v:get_id() == val:get_id()) then
                tab[i] = nil
            end
        end
    end


end

return package_init
