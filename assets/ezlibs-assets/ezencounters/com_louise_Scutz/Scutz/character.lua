-- Imports
---@type EnemyUtils
local enemy_utils = include("lib/enemy_utils.lua")

---@type BattleHelpers
local battle_helpers = include("lib/battle_helpers.lua")

---@type SpellsLib
local spells_lib = include("spells/spells.lua")

-- Animations, Textures and Sounds
local CHARACTER_ANIMATION = _folderpath .. "battle.animation"
local CHARACTER_TEXTURE = Engine.load_texture(_folderpath .. "battle.greyscaled.png")

local impacts_texture = Engine.load_texture(_folderpath .. "lib/effect.png")
local impacts_animation_path = _folderpath .. "lib/effect.animation"
local flame_animation = "flame.animation"
local wave_texture = Engine.load_texture(_folderpath .. "flame.png")
local wave_sfx = Engine.load_audio(_folderpath .. "burn.ogg")
local auraChip = include("spells/aura.lua")
local BARRIER_UP_SOUND = Engine.load_audio(_folderpath .. "spells/Barrier.ogg") -- Normalized -0.1

---@param self Entity
function package_init(self, character_info)
    -- Required function, main package information
    local base_animation_path = CHARACTER_ANIMATION
    self:set_texture(CHARACTER_TEXTURE)
    self.animation = self:get_animation()
    self.animation:load(base_animation_path)
    -- Set up character meta
    self:set_name(character_info.name)
    self.name = character_info.name
    self:set_health(character_info.hp)
    self:set_height(character_info.height)
    self.damage = (character_info.damage)
    self:set_element(character_info.element)
    self:set_palette(Engine.load_texture(character_info.palette))
    self:set_explosion_behavior(4, 1, false)
    self.defense = Battle.DefenseVirusBody.new()
    self:add_defense_rule(self.defense)
    self:set_shadow(Shadow.Big)
    self:show_shadow(true)
    self.animation:set_state("SPAWN")
    auraChip.card_create_action(self)
    self.move_speed = character_info.move_speed
    if (self:get_name() == "Scuttle") then
        self.action_move = enemy_utils.move_toward_enemy_row(self, character_info.move_speed, action_attack)
    elseif (self:get_name() == "Scuttler") then
        self.action_move = enemy_utils.move_at_random(self, 4, 40, action_attack)
    elseif (self:get_name() == "Scuttzer") then
        self.action_move = enemy_utils.slide_random_adjacent(self, 6, 40, action_attack)
    elseif (self:get_name() == "Scuttlest") then
        self.action_move = enemy_utils.move_toward_enemy_row(self, character_info.move_speed, action_attack)
    else
        self.action_move = enemy_utils.jump_toward_enemy(self, 30, 30, 40, action_attack)
    end

    enemy_utils.use_enemy_framework(self)
    self.init_func = function()
        self.set_current_action(self.action_move)
        self.animation:set_state("IDLE")
        self.animation:set_playback(Playback.Loop)
        Engine.play_audio(BARRIER_UP_SOUND, AudioPriority.Low)

    end


end

function action_attack(character)
    if (character.bolts == 0) then
        character.set_current_action(character.action_move)
    end
    character.set_current_action(enemy_utils.wait)
    character.animation:set_state("ATTACK")
    print(character:get_name())
    character.animation:on_frame(4, function()
        local facing = character:get_facing()
        local tile = character:get_tile(facing, 1)
        if (character:get_name() == "Scuttle") then
            spells_lib.spawn_icecube(character, character:get_team(), character:get_facing(), character:get_field(),
                character:get_tile(character:get_facing(), 1), character.damage)
        elseif (character:get_name() == "Scuttzer") then
            spells_lib.spawn_greenrope_1(character, character:get_team(), character:get_facing(), character:get_field(),
                character:get_tile(character:get_facing(), 1), character.damage)
        elseif (character:get_name() == "Scuttler") then
            local thunder_component = Battle.Component.new(character, Lifetimes.Battlestep)
            thunder_component.frame = 0
            thunder_component.update_func = function(self)
                if (self.frame % 30 == 0) then
                    spells_lib.spawn_thunderbolt(character, character:get_team(), character:get_facing(),
                        character:get_field(),
                        character.damage)
                end
                if (self.frame == 60) then
                    character.set_current_action(character.action_move)
                    self:eject()
                end
                self.frame = self.frame + 1
            end
            character:register_component(thunder_component)
        elseif (character.name == "Scuttlest") then
            spells_lib.spawn_laser(character, character:get_team(), character:get_facing(), character:get_field(),
                character:get_tile(), character.damage)
        else -- fire scutz
            spawn_flame(character, tile, facing, character.damage, wave_texture, flame_animation,
                wave_sfx, 22)
        end
    end)
    character.animation:on_complete(function()
        character.animation:set_state("IDLE")
        character.animation:set_playback(Playback.Loop)
    end)
end

function spawn_flame(owner, tile, direction, damage, wave_texture, wave_animation, wave_sfx, cascade_frame_index)
    local owner_id = owner:get_id()
    local team = owner:get_team()
    local field = owner:get_field()
    local cascade_frame = cascade_frame_index
    local spawn_next
    spawn_next = function()
        if not tile:is_walkable() then
            local r = math.random(1, 3)
            owner.set_current_action(owner.action_move)
            return
        end

        Engine.play_audio(wave_sfx, AudioPriority.Highest)

        local spell = Battle.Spell.new(team)
        spell:set_facing(direction)
        spell:highlight_tile(Highlight.Solid)
        spell:set_hit_props(HitProps.new(damage, Hit.Flash | Hit.Flinch | Hit.Impact, Element.Fire, owner_id, Drag.new()))

        local sprite = spell:sprite()
        sprite:set_texture(wave_texture)
        sprite:set_layer(-1)

        spell.collision_func = function(self, other)
            local artifact = Battle.Artifact.new()
            artifact:never_flip(true)
            artifact:set_texture(impacts_texture)
            artifact:set_animation(impacts_animation_path)
            --FX
            local anim = artifact:get_animation()
            anim:set_state("FIRE")
            anim:on_complete(function()
                artifact:erase()
            end)
            anim:refresh(artifact:sprite())
            field:spawn(artifact, spell:get_current_tile())
        end

        local animation = spell:get_animation()
        animation:load(_folderpath .. wave_animation)
        animation:set_state("DEFAULT")
        animation:refresh(sprite)

        animation:on_frame(cascade_frame - 10, function()
            tile = getNextTile(direction, spell)
        end)
        animation:on_frame(cascade_frame, function()

            spawn_next()
        end, true)
        animation:on_complete(function()
            spell:erase()

        end)

        spell.update_func = function()
            spell:get_current_tile():attack_entities(spell)
        end

        field:spawn(spell, tile)
    end

    spawn_next()
end

function getNextTile(direction, spell)
    local target_character = battle_helpers.find_target(spell)
    local target_character_tile = target_character:get_current_tile()
    local tile = spell:get_current_tile():get_tile(direction, 1)
    local target_movement_tile = tile
    if tile:y() < target_character_tile:y() then
        target_movement_tile = tile:get_tile(Direction.Down, 1)
    end
    if tile:y() > target_character_tile:y() then
        target_movement_tile = tile:get_tile(Direction.Up, 1)
    end
    return target_movement_tile;
end

return package_init
