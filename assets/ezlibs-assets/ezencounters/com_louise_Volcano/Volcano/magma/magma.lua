local debug = true
local attachment_texture = Engine.load_texture(_folderpath .. "attachment.png")
local attachment_animation_path = _folderpath .. "attachment.animation"
local explosion_texture1 = Engine.load_texture(_folderpath .. "explosion.png")
local explosion_sfx = Engine.load_audio(_folderpath .. "explosion.ogg")
local explosion_animation_path = _folderpath .. "explosion.animation"
local flame_trail = include("flame_trail.lua")


function debug_print(text)
    if debug then
        print("[chip] " .. text)
    end
end

local chip = {

}

chip.card_create_action = function(actor, props)
    local anim = actor:get_animation()
    local explosion_texture = explosion_texture1
    local hit_props = HitProps.new(
        props.damage,
        Hit.Impact | Hit.Flinch | Hit.Flash,
        props.element,
        actor:get_context(),
        Drag.None
    )








    local corn_tiles = find_tiles(actor, props.amount)
    for index, tilee in pairs(corn_tiles) do

        local dist = math.abs(tilee:x() - actor:get_tile():x())

        local toss_height = dist * 30
        local frames_in_air = math.max(dist * 14, 20)

        local function on_landing()
            if tilee:is_walkable() then
                hit_explosion(actor, tilee, hit_props, explosion_texture, explosion_animation_path,
                    explosion_sfx)
            end
        end

        toss_spell(actor, toss_height, attachment_texture, attachment_animation_path, tilee, frames_in_air,
            on_landing)
    end
end

---comment
---@param tosser any
---@param toss_height any
---@param texture any
---@param animation_path any
---@param target_tile Tile
---@param frames_in_air any
---@param arrival_callback any
function toss_spell(tosser, toss_height, texture, animation_path, target_tile, frames_in_air, arrival_callback)
    local starting_height = -110
    local start_tile = tosser:get_current_tile()
    local field = tosser:get_field()
    local spell = Battle.Spell.new(tosser:get_team())
    local spell_animation = spell:get_animation()
    spell_animation:load(animation_path)
    spell_animation:set_state("DEFAULT")
    if tosser:get_height() > 1 then
        starting_height = -(tosser:get_height() + 40)
    end

    spell.jump_started = false
    spell.starting_y_offset = starting_height
    spell.starting_x_offset = 40
    spell.ending_x_offset = 40
    if tosser:get_facing() == Direction.Left then
        spell.starting_x_offset = -40
        spell.ending_x_offset = -40
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
            self.x_offset = self.x_offset - (self.ending_x_offset / frames_in_air)
            self:set_offset(self.x_offset, self.y_offset)
            target_tile:highlight(Highlight.Flash)
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
    if (target_tile:is_edge()) then
        return
    end
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
            local chars_on_tile = spell:get_current_tile():find_characters(function()
                return true
            end)
            if (#chars_on_tile == 0) then
                flame_trail.create_flame_trail(self, props.damage, spell:get_current_tile())
            end

            spell.has_attacked = true
        end
    end
    field:spawn(spell, target_tile)
end

-- corn stuff
---comment
---@param max_amt number Max_amt of tiles to return
---@return table #table of tile patterns
function find_tiles(self, max_amt)
    local target_char = find_target(self)
    local target_tile = target_char:get_tile()
    local tilePatterns = {}
    local team = self:get_team()
    local enemy_field = getEnemyField(team, target_tile, self:get_field())
    shuffle(enemy_field)
    --targets will always contain the target tile, plus extras.
    table.insert(tilePatterns, target_tile)
    for i = 1, max_amt - 1, 1 do
        table.insert(tilePatterns, enemy_field[i])
    end

    return tilePatterns
end

--shuffle function to provide some randomness
function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

--get the enemy field, besides the target tile.
function getEnemyField(team, target_tile, field)
    local tile_arr = {}
    for i = 1, 6, 1 do
        for j = 1, 3, 1 do
            local tile = field:tile_at(i, j)
            if (tile ~= target_tile and tile:get_team() ~= team) then
                table.insert(tile_arr, tile)
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

return chip
