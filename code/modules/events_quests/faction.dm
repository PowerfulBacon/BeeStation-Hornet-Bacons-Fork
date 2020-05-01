/datum/quest_system/faction
	var/name = "Faction Name"	//Faction name
	var/desc = "Faction Description"	//Faction desc
	var/starting_rep = 0
	var/min_rep = -200
	var/max_rep = 200
	var/list/other_faction_rep = list()	//Reputation with other factions

	var/faction_state = FACTION_STATE_NEUTRAL
	var/faction_flags = 0

	//Loaded vars, don't set
	var/missions = list()
	var/reputation = 0	//Reputation with captain
