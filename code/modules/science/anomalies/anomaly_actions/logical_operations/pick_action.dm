/datum/anomaly_action/pick_action
	action_desc = "anomaly_random"

/datum/anomaly_action/pick_action/trigger_action(atom/anomaly_parent, list/mob/living/trigger_mobs)
	var/datum/anomaly_action/child_action = pick(children)
	child_action.trigger_action(anomaly_parent, trigger_mobs)
