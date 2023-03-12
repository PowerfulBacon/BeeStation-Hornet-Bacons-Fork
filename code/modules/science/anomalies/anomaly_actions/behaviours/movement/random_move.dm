/**
 * Randomly move
 * When triggered will randomly take a set amount of steps.
 */

/datum/anomaly_action/behaviour/random_move
	var/steps = 1

/datum/anomaly_action/behaviour/random_move/trigger_action(list/atom/trigger_atoms, list/extra_data)
	var/atom/parent_atom = parent_anomaly.parent
	// Must be at a turf
	if (!isturf(parent_atom.loc))
		return fail()
	for (var/step in 1 to steps)
		step(parent_anomaly.parent, pick(GLOB.alldirs))
	return success()
