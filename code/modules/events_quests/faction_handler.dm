/datum/quest_system/faction_handler
	var/list/factions = list()

//Load in all the factions
/datum/quest_system/faction_handler/proc/load_factions()
	factions = subtypesof(/datum/quest_system/faction)
