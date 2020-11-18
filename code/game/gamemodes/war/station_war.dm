
//==================
// Globals
//==================

GLOBAL_LIST_EMPTY(syndicate_pvp_spawns)
GLOBAL_LIST_EMPTY(nanotrasen_pvp_spawns)

/datum/game_mode/station_war
	name = "Station War"
	config_tag = "war"
	false_report_weight = -1
	required_players = 0
	required_enemies = 0
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "The Syndicate have declared war on Nanotrasen in this sector for authorising construction in their territory!\n\
	Construct your station, build shuttles and set up teleporter links to access the enemy station before beginning your assault.\n\
	<span class='danger'>Syndicate</span>: Security the Nuclear Authentication disk from Nanotrasen and destroy their station.\n\
	<span class='notice'>Nanotrasen</span>: Trigger the self-destruct sequence in the core of the Syndicate station and destroy it."
