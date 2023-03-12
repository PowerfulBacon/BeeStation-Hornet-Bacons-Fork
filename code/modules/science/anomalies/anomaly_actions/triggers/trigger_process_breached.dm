/**
 * Trigger Process Breached
 * Will process only while the anomaly is in a breached state
 * Returns a success state if any of the children return success states
 */

/datum/anomaly_action/trigger/process_breached
	var/seconds_wait = 1
	var/_ticks = 0

///Register signals to the anomaly base datum
/datum/anomaly_action/trigger/process_breached/initialise_anomaly(datum/component/anomaly_base/anomaly)
	. = ..()
	if (anomaly.anomaly_state == ANOMALY_STATE_BREACHED)
		START_PROCESSING(SSanomaly_science, src)
	// Register signal to the anomaly object in order to detect containment breaches
	RegisterSignal(anomaly.parent, COMSIG_ANOMALY_BREACHED, .proc/on_breach)

/datum/anomaly_action/trigger/process_breached/deactive_anomaly(datum/component/anomaly_base/anomaly)
	if (anomaly.anomaly_state == ANOMALY_STATE_BREACHED)
		STOP_PROCESSING(SSanomaly_science, src)
	UnregisterSignal(anomaly.parent, COMSIG_ANOMALY_BREACHED)
	. = ..()

/datum/anomaly_action/trigger/process_breached/proc/on_breach(datum/source)
	START_PROCESSING(SSanomaly_science, src)

/datum/anomaly_action/trigger/process_breached/process(delta_time)
	if (parent_anomaly.anomaly_state != ANOMALY_STATE_BREACHED)
		return PROCESS_KILL
	if ((_ticks ++) % seconds_wait != 0)
		return
	trigger_action(list(), list(
		"delta_time" = delta_time
	))

/datum/anomaly_action/trigger/process_breached/trigger_action(list/atom/trigger_atoms, list/extra_data)
	return execute_children(trigger_atoms, extra_data)
