/datum/anomaly_action/targetting
	var/vision_range = 5

/datum/anomaly_action/targetting/trigger_action(list/atom/trigger_atoms, list/extra_data)
	var/list/targets_in_range = trigger_atoms + get_targets_in_range()
	var/result = success(targets_in_range)
	// Iterate over all children, overriding the return value if required
	for (var/datum/anomaly_action/child_action in children)
		result = or(result, child_action.trigger_action(targets_in_range, extra_data))
	// Return the result
	return result

/datum/anomaly_action/targetting/proc/get_targets_in_range()
	CRASH("Targetting not properly implemented")
