/**
 * Probability
 * Performs the children actions with a probability determined at execution time.
 * Returns failure if the probability fails
 * Returns success state if any of the children return success states
 */

/datum/anomaly_action/probability
	var/probability = 100

/datum/anomaly_action/probability/trigger_action(list/atom/trigger_atoms, list/extra_data)
	var/delta_time = extra_data["delta_time"] || 1
	if (!DT_PROB(probability, delta_time))
		return fail()
	return execute_children(trigger_atoms, extra_data)
