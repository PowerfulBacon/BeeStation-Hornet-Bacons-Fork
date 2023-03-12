/**
 * Shuffle Targets
 * Shuffles the target list
 */

/datum/anomaly_action/shuffle

/datum/anomaly_action/shuffle/trigger_action(list/atom/trigger_atoms, list/extra_data)
	var/result = success(shuffle(trigger_atoms))
	// Override our return result (In cases where we do more sorting in the children branches)
	for (var/datum/anomaly_action/child_action in children)
		result = or(result, child_action.trigger_action(trigger_atoms, extra_data))
	return result
