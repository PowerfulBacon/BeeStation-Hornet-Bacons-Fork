/datum/anomaly_action/probability
	var/probability = 100

/datum/anomaly_action/probability/trigger_action(list/atom/trigger_atoms, list/extra_data)
	var/delta_time = extra_data["delta_time"] || 1
	if (!DT_PROB(probability, delta_time))
		return
	for (var/datum/anomaly_action/child_action in children)
		child_action.trigger_action(trigger_atoms, extra_data)
