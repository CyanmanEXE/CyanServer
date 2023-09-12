--Functions for easy reuse in scripts
--Version 1.1

MobTable = {}
function MobTable:new()
    local o = {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    if not o.tbl_mobs then
        o.tbl_mobs = {}
        o.tbl_index = 1
    end
    return o
end

function MobTable:add_by_id(mob_id)
    table.insert(self.tbl_mobs, mob_id)
    --print('added',mob_id)
end

function MobTable:print_ids()
    for index, value in ipairs(self.tbl_mobs) do
        print('i=', index, 'id=', value)
    end
end

function MobTable:sort_turn_order(sort_function, reverse_sorting)
    --print('sorting mob tracker turn order')
    local reversable_sort = function(a, b)
        local bool_result = sort_function(a, b)
        if reverse_sorting then
            bool_result = not bool_result
        end
        return bool_result
    end
    table.sort(self.tbl_mobs, reversable_sort)
end

function MobTable:get_index(mob_id)
    for index, value in ipairs(self.tbl_mobs) do
        if value == mob_id then
            return index
        end
    end
    return nil
end

function MobTable:remove_by_id(mob_id)
    --print('removing ',mob_id)
    local i = self:get_index(mob_id)
    table.remove(self.tbl_mobs, i)
    if self.tbl_index > i then
        self.tbl_index = self.tbl_index - 1
    end
    if self.tbl_index > #self.tbl_mobs then
        self.tbl_index = 1
    end
end

function MobTable:clear()
    --print('clearing mob tracker')
    for index, value in ipairs(self.tbl_mobs) do
        table.remove(self.tbl_mobs, index)
    end
    self.tbl_index = 1
end

function MobTable:get_active_mob()
    return self.tbl_mobs[self.tbl_index]
end

function MobTable:advance_a_turn()
    self.tbl_index = self.tbl_index + 1
    if self.tbl_index > #self.tbl_mobs then
        self.tbl_index = self.tbl_index - #self.tbl_mobs
    end
end

---@class MobTracker
MobTracker = {}


MobTracker.redteam_tracker = MobTable:new()
MobTracker.blueteam_tracker = MobTable:new()

--Enable mobtracker for entity
MobTracker.enable_mob_tracker = function(entity)
    entity.battle_start_func = MobTracker.battle_start_func
    entity.battle_end_func = MobTracker.battle_end_func
    entity.on_spawn_func = MobTracker.on_spawn_func
    entity.delete_func = MobTracker.delete_func
end

MobTracker.battle_start_func = function(self)
    MobTracker.add_enemy_to_tracking(self)
    local field = self:get_field()
    local mob_sort_func = function(a, b)
        -- rank compare
        local met_a_tile = field:get_entity(a):get_current_tile()
        local met_b_tile = field:get_entity(b):get_current_tile()
        local var_a = (met_a_tile:x() * 3) + met_a_tile:y()
        local var_b = (met_b_tile:x() * 3) + met_b_tile:y()
        return var_a < var_b
    end
    MobTracker.blueteam_tracker:sort_turn_order(mob_sort_func)
    MobTracker.redteam_tracker:sort_turn_order(mob_sort_func, true) --reverse sort direction
end

MobTracker.battle_end_func = function(self)
    MobTracker.blueteam_tracker:clear()
    MobTracker.redteam_tracker:clear()
end
MobTracker.on_spawn_func = function(self, spawn_tile)
    --In theory we should not need to do this as they would be cleared at the end of the last battle
    --However there is a bug in ONB V2 which causes battle_end_func to be missed sometimes.
    MobTracker.blueteam_tracker:clear()
    MobTracker.redteam_tracker:clear()
end

MobTracker.delete_func = function(self)
    MobTracker.remove_enemy_from_tracking(self)
end

MobTracker.get_tracker_for_team = function(team)
    if team == Team.Red then
        return MobTracker.redteam_tracker
    elseif team == Team.Blue then
        return MobTracker.blueteam_tracker
    end
end

MobTracker.advance_a_turn = function(team)
    local mob_tracker = MobTracker.get_tracker_for_team(team)
    return mob_tracker:advance_a_turn()
end

MobTracker.is_active = function(ent)
    local mob_tracker = MobTracker.get_tracker_for_team(ent:get_team())
    return mob_tracker:get_active_mob() == ent:get_id()
end

MobTracker.get_active_mob_id_for_team = function(team)
    local mob_tracker = MobTracker.get_tracker_for_team(team)
    return mob_tracker:get_active_mob()
end

MobTracker.add_enemy_to_tracking = function(enemy)
    local team = enemy:get_team()
    local id = enemy:get_id()
    local mob_tracker = MobTracker.get_tracker_for_team(team)
    mob_tracker:add_by_id(id)
end

MobTracker.remove_enemy_from_tracking = function(enemy)
    local team = enemy:get_team()
    local id = enemy:get_id()
    local mob_tracker = MobTracker.get_tracker_for_team(team)
    mob_tracker:remove_by_id(id)
end

return MobTracker
