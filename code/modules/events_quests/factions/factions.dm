/datum/quest_system/faction/centcom
	name = "Nanotrasen"
	starting_rep = 40
	min_rep = 20
	faction_state = FACTION_STATE_PASSIVE

/datum/quest_system/faction/syndicate
	name = "The Syndicate"
	starting_rep = -200
	max_rep = -50
	faction_state = FACTION_STATE_HOSTILE
	faction_flags = FACTION_NO_MISSIONS

/datum/quest_system/faction/spider
	name = "Spider Clan"

//This is for independant traders etc, that will trade items for services rather than rep
/datum/quest_system/faction/independant
	name = "Independant"
	max_rep = 0
	min_rep = 0
	faction_flags = FACTION_NO_REP

/datum/quest_system/faction/clown
	name = "Clown Planet Representatives"
	faction_state = FACTION_STATE_FRIENDLY

/datum/quest_system/faction/supermatter
	name = "People of The Stone"
	faction_state = FACTION_STATE_AGGRESSIVE

/datum/quest_system/faction/felinids
	name = "Clowder of Felinids"
	faction_state = FACTION_STATE_FRIENDLY

/datum/quest_system/faction/slimes
	name = "Slimes"
