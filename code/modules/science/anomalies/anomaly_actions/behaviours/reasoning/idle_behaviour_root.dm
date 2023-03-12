/**
 * Idle Behaviour Root
 * Will perform subactions when the conciousness root
 * asks for idle behaviour to be performed.
 */

///Register signals to the anomaly base datum
/datum/anomaly_action/trigger/idle_behaviour_root/initialise_anomaly(datum/component/anomaly_base/anomaly)
	//This registers the signals with an intermediary class
	RegisterSignal(anomaly.parent, COMSIG_ANOMALY_IDLE_BEHAVIOUR, .proc/relay_interaction)
	//Register children
	..()

/datum/anomaly_action/trigger/idle_behaviour_root/deactive_anomaly(datum/component/anomaly_base/anomaly)
	UnregisterSignal(anomaly.parent, COMSIG_ANOMALY_IDLE_BEHAVIOUR)
	. = ..()

/datum/anomaly_action/trigger/idle_behaviour_root/proc/relay_interaction(atom/source)
	trigger_action(list(), list())

/datum/anomaly_action/trigger/idle_behaviour_root/trigger_action(list/atom/trigger_atoms, list/extra_data)
	return execute_children(trigger_atoms, extra_data)
