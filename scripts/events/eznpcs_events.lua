local eznpcs = require('scripts/ezlibs-scripts/eznpcs/eznpcs')
local ezmemory = require('scripts/ezlibs-scripts/ezmemory')
local ezmystery = require('scripts/ezlibs-scripts/ezmystery')
local ezweather = require('scripts/ezlibs-scripts/ezweather')
local ezwarps = require('scripts/ezlibs-scripts/ezwarps/main')
local ezencounters = require('scripts/ezlibs-scripts/ezencounters/main')
local helpers = require('scripts/ezlibs-scripts/helpers')

local event1 = {
    name="Heel1",
    action=function (npc,player_id,dialogue,relay_object)
        return async(function()
        Net.initiate_encounter(player_id, "/server/assets/bosses/com_louise_mob_HeelNavi.zip")
        return dialogue.custom_properties["Next 1"]
    end)
end
}

eznpcs.add_event(event1)


local event2 = {
    name="Clown1",
    action=function (npc,player_id,dialogue,relay_object)
        return async(function()
        Net.initiate_encounter(player_id, "/server/assets/bosses/com_louise_CircusMan.zip")
        return dialogue.custom_properties["Next 1"]
    end)
end
}


eznpcs.add_event(event2)
