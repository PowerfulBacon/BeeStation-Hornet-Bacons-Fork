/**
 * https://www.desmos.com/calculator/omozxzqjlv
 */

/datum/game_mode/dynamic
	/// Amount of chaos that you start out with, higher means that the calculator
	/// will be biased into considering rounds to be more chaotic than they are,
	/// reducing the amount of things that it will do to satisfy its chaos desire.
	var/base_chaos = 15
	/// Amount of chaos gained per pop increase
	var/chaos_per_pop = -0.8
	/// Every minute the current chaos increases by this amount
	var/chaos_per_minute = -0.5
	/// Every death the current chaos increases by this amount
	/// Only living crew count towards this number
	var/chaos_per_station_wipe = 120
	/// How much chaos for every traitor
	var/chaos_per_traitor = 4

/datum/game_mode/dynamic/proc/get_chaos()
	. = base_chaos
	// Calculate time based chaos
	var/elapsed_minutes = (world.time - SSticker.round_start_time) / (1 MINUTES)
	. += chaos_per_minute * elapsed_minutes
	var/population = 0
	// Calculate death based chaos
	var/deaths = 0
	for (var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		if (ghost.ckey in GLOB.joined_player_list)
			deaths ++
	for (var/mob/living/carbon/human/person in GLOB.player_list)
		if (!person.ckey in GLOB.joined_player_list)
			continue
		if (!person.mind)
			continue
		// Check if this person owns their original mob
		if (SSjob.name_occupations[person.mind.assigned_role])
			continue
		deaths ++
	. += (deaths / population) * chaos_per_station_wipe
	// Every antag adds its chaos if alive
	for (var/datum/antagonist/antag in GLOB.antagonists)
		if (!antag.owner)
			continue
		if (!antag.owner.current)
			continue
		if (antag.owner.current.stat == DEAD)
			continue
		. += antag.chaos_cost * chaos_per_traitor
