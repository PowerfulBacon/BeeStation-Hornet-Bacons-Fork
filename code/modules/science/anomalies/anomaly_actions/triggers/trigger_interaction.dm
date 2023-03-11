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
	trigger_action(list(user), list())

/datum/anomaly_action/trigger/interaction/trigger_action(list/atom/trigger_atoms, list/extra_data)
	for (var/datum/anomaly_action/child_action in children)
		child_action.trigger_action(trigger_atoms, extra_data)
