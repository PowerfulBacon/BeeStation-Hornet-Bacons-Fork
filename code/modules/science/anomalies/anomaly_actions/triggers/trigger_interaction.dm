/**
 * Trigger Interaction
 * Attaches an interaction signal to the anomaly base.
 * When an interaction is triggered, the child nodes will be triggered.
 */

///Register signals to the anomaly base datum
/datum/anomaly_action/trigger/interaction/initialise_anomaly(datum/component/anomaly_base/anomaly)
	//This registers the signals with an intermediary class
	RegisterSignal(anomaly.parent, COMSIG_ANOMALY_DIRECT_INTERACTION, .proc/relay_interaction)
	//Register children
	..()

/datum/anomaly_action/trigger/interaction/proc/relay_interaction(atom/source, mob/user)
	trigger_action(source, list(user))

/datum/anomaly_action/trigger/interaction/trigger_action(atom/anomaly_parent, list/mob/living/trigger_mobs)
	for (var/datum/anomaly_action/child_action in children)
		child_action.trigger_action(anomaly_parent, trigger_mobs)
