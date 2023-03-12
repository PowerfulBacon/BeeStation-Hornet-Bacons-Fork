/**
 * Trigger Interaction
 * Attaches an interaction signal to the anomaly base.
 * When an interaction is triggered, the child nodes will be triggered.
 * Returns a success state if any of the children return success states.
 */

///Register signals to the anomaly base datum
/datum/anomaly_action/trigger/interaction/initialise_anomaly(datum/component/anomaly_base/anomaly)
	//This registers the signals with an intermediary class
	RegisterSignal(anomaly.parent, COMSIG_ANOMALY_DIRECT_INTERACTION, .proc/relay_interaction)
	//Register children
	..()

/datum/anomaly_action/trigger/interaction/deactive_anomaly(datum/component/anomaly_base/anomaly)
	UnregisterSignal(anomaly.parent, COMSIG_ANOMALY_DIRECT_INTERACTION)
	. = ..()

/datum/anomaly_action/trigger/interaction/proc/relay_interaction(atom/source, mob/user)
	trigger_action(list(user), list())

/datum/anomaly_action/trigger/interaction/trigger_action(list/atom/trigger_atoms, list/extra_data)
	return execute_children(trigger_atoms, extra_data)
