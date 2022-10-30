/datum/anomaly_action/pick_action
	action_desc = "anomaly_random"
	var/child_index = 0

/datum/anomaly_action/pick_action/initialise_anomaly(datum/component/anomaly_base/anomaly)
	. = ..()
	child_index = rand(0, length(children))

/datum/anomaly_action/pick_action/trigger_action(atom/anomaly_parent, list/mob/living/trigger_mobs)
	var/datum/anomaly_action/child_action = children[child_index]
	child_action.trigger_action(anomaly_parent, trigger_mobs)
