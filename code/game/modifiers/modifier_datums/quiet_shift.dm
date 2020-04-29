/datum/round_modifier/hostile_sector
	name = "Quiet Shift"
	desc = "Hacked communication channels with the syndicate suggest \
		that enemy activity is going to be lower in this sector. \
		Keep an eye out for hostile activity still, despite being reduced."
	points = 3
	weight = 3	//Make this pretty rare due to the chaos it could cause
	blacklisted_gamemodes = list(/datum/game_mode/extended)	//This can trigger on non traitor gamemodes, but will not affect the antagonist count.
	minimum_pop = 30

/datum/round_modifier/hostile_sector/pre_setup()
	SSticker.mode.antag_spawner_multiplier = 0.7
