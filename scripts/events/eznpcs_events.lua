local eznpcs = require('scripts/ezlibs-scripts/eznpcs/eznpcs')
local ezmemory = require('scripts/ezlibs-scripts/ezmemory')
local ezmystery = require('scripts/ezlibs-scripts/ezmystery')
local ezweather = require('scripts/ezlibs-scripts/ezweather')
local ezwarps = require('scripts/ezlibs-scripts/ezwarps/main')
local ezencounters = require('scripts/ezlibs-scripts/ezencounters/main')
local helpers = require('scripts/ezlibs-scripts/helpers')
local LibPlugin = require('scripts/ezlibs-custom/nebulous-liberations/main')

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

local liberation_item_list = {
	{n="HeroSwrd",d="A Hero Sword Chip. Use it in Liberations!"},
	{n="WideSwrd",d="A Wide Sword Chip. Use it in Liberations!"},
	{n="OldSaber",d="A Saber projection hilt, scarred with age. Use it in Liberations!"},
	{n="HevyShld",d="A heavy shield, great for defense. Use it in Liberations!"},
	{n="HexScyth",d="A wicked scythe which cleaves most anything. Use it in Liberations!"},
	{n="NumGadgt",d="A gadget that's constantly calculating outcomes. Use it in Liberations!"},
	{n="GutsHamr",d="A hammer that takes guts to wield. Use it in Liberations!"},
	{n="ShdwShoe",d="Delicate shoes that let you walk on air. Wear them in Liberations!"}
}

local RematchProgEvent ={
	name = "Refight Liberation",
	action = function(npc, player_id, dialogue, relay_object)
		return async(function()
			return LibPlugin.start_game_for_player(player_id, dialogue.custom_properties["Liberation Map"])
		end)
	end
}

local GrantLiberationAbility = {
	name = "Grant Liberation Mission Ability",
	action = function(npc, player_id, dialogue, relay_object)
		return async(function()
			for i = 1, #liberation_item_list, 1 do
				ezmemory.create_or_update_item(liberation_item_list[i].n, liberation_item_list[i].d, true)
				local item_count = ezmemory.count_player_item(player_id, liberation_item_list[i].n)
				if item_count > 0 then ezmemory.remove_player_item(player_id, liberation_item_list[i].n, item_count) end
			end

			if dialogue.custom_properties["Ability Item"] ~= nil then ezmemory.give_player_item(player_id, dialogue.custom_properties["Ability Item"], 1) end
		end)
	end
}
eznpcs.add_event(GrantLiberationAbility)
eznpcs.add_event(event2)
eznpcs.add_event(RematchProgEvent)