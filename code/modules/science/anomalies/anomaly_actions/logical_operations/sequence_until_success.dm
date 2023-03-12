/**
 * Sequence until success
 * Performs all child nodes in sequence until one of them is successful.
 * Returns a failure state if no children succeed.
 * Returns a success state if a single child succeeds.
 */

/datum/anomaly_action/sequence_until_success

/datum/anomaly_action/probability/trigger_action(list/atom/trigger_atoms, list/extra_data)
	for (var/datum/anomaly_action/child_action in children)
		var/result = child_action.trigger_action(trigger_atoms, extra_data)
		if (is_success(result))
			return result
	return fail()
