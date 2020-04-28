/*
 *
 * Round Modifiers
 *
 * Round modifiers are things selected at round start that randomly
 * change certain aspects of the round.
 *
*/

/datum/round_modifier
	var/name = "invalid" //The name of the modifier
	var/desc = "This round modifier has not been correctly setup.\
				Please contact a coder with a bug report thanks!" //The description that comes up on comms console
	var/weight = 0 //The weight of this spawning,
	var/points = 0 //The overall chaos / danger of event. -5 would be terrible, 5 would be amazing
	var/minimum_pop = 0 //Minimum pop this can spawn on
	var/maximum_pop = 500 //maximum pop this can spawn on

/datum/round_modifier/proc/pre_setup()
	return 1

/datum/round_modifier/proc/post_setup()
	return 1

/datum/round_modifier/process()
	return 1
