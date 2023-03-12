/**
 * Prioritise Concious
 * Sorts the target list so that concious entities will be above
 * unconcious ones.
 * Stable for mobs with the same stat.
 */

/datum/anomaly_action/sorting/prioritise_concious

/datum/anomaly_action/sorting/prioritise_concious/trigger_action(list/atom/trigger_atoms, list/extra_data)
	var/result = success(trigger_atoms)
	// Override our return result (In cases where we do more sorting in the children branches)
	for (var/datum/anomaly_action/child_action in children)
		result = or(result, child_action.trigger_action(trigger_atoms, extra_data))
	return result
