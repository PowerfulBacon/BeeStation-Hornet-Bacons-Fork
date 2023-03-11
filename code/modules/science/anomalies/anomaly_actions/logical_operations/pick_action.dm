/datum/anomaly_action/pick_action
	action_desc = "anomaly_random"
	var/child_index = 0

/datum/anomaly_action/pick_action/initialise_anomaly(datum/component/anomaly_base/anomaly)
	. = ..()
	child_index = rand(1, length(children))
	var/datum/anomaly_action/child_action = children[child_index]
	child_action.initialise_anomaly(anomaly)

/datum/anomaly_action/pick_action/trigger_action(list/atom/trigger_atoms, list/extra_data)
	var/datum/anomaly_action/child_action = children[child_index]
	child_action.trigger_action(trigger_atoms, extra_data)
