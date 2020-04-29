/datum/round_modifier/hostile_sector
	name = "Hostile Sector"
	desc = "This sector is known for hostile activity. As a result \
		we have increased the security budget greatly and expanded the security \
		team. Please relay this message to your acting Head of Security immediately."
	points = -3
	weight = 1	//Make this pretty rare due to the chaos it could cause
	blacklisted_gamemodes = list(/datum/game_mode/extended)	//This can trigger on non traitor gamemodes, but will not affect the antagonist count.
	incompatible_modifiers = list(/datum/round_modifier/quiet_shift)
	minimum_pop = 40

/datum/round_modifier/hostile_sector/pre_setup()
	SSticker.mode.antag_spawner_multiplier = 1.2	//More antags ahhhh bad, so make this rare
	var/datum/job/job_sec = SSjob.GetJob("Security Officer")
	if(job_sec)
		//2 more sec jobs without HOP required
		job_sec.current_positions += 2
	//Find the budget card and give more money
	var/datum/bank_account/B = SSeconomy.get_dep_account(ACCOUNT_SEC)
	if(B)
		//Adds 40k to the sec budget. Wew
		B.adjust_money(40000)
