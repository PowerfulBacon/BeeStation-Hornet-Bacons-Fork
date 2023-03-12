/**
 * Trigger Process Unsupressed
 * Will process only while the anomaly is in a breached state
 * Returns a success state if any of the children return success states
 */

/datum/anomaly_action/trigger/process_unsupressed
	var/seconds_wait = 1
	var/_ticks = 0
	var/processing = FALSE

///Register signals to the anomaly base datum
/datum/anomaly_action/trigger/process_unsupressed/initialise_anomaly(datum/component/anomaly_base/anomaly)
	. = ..()
	if (anomaly.anomaly_state == ANOMALY_STATE_BREACHED)
		START_PROCESSING(SSanomaly_science, src)
		processing = FALSE
	// Register signal to the anomaly object in order to detect containment breaches
	RegisterSignal(anomaly.parent, COMSIG_ANOMALY_BREACHED, .proc/on_breach)
	RegisterSignal(anomaly.parent, COMSIG_ANOMALY_ENTER_SUPRESSED_STATE, .proc/on_supression)
	RegisterSignal(anomaly.parent, COMSIG_ANOMALY_EXIT_SUPRESSED_STATE, .proc/on_desupression)

/datum/anomaly_action/trigger/process_unsupressed/deactive_anomaly(datum/component/anomaly_base/anomaly)
	if (processing)
		STOP_PROCESSING(SSanomaly_science, src)
	UnregisterSignal(anomaly.parent, COMSIG_ANOMALY_BREACHED)
	. = ..()

/datum/anomaly_action/trigger/process_unsupressed/proc/on_breach(datum/source)
	START_PROCESSING(SSanomaly_science, src)
	processing = TRUE

/datum/anomaly_action/trigger/process_unsupressed/proc/on_supression(datum/source)
	STOP_PROCESSING(SSanomaly_science, src)
	processing = FALSE

/datum/anomaly_action/trigger/process_unsupressed/proc/on_desupression(datum/source)
	START_PROCESSING(SSanomaly_science, src)
	processing = TRUE

/datum/anomaly_action/trigger/process_unsupressed/process(delta_time)
	if (parent_anomaly.anomaly_state != ANOMALY_STATE_BREACHED)
		return PROCESS_KILL
	if ((_ticks ++) % seconds_wait != 0)
		return
	trigger_action(list(), list(
		"delta_time" = delta_time
	))

/datum/anomaly_action/trigger/process_unsupressed/trigger_action(list/atom/trigger_atoms, list/extra_data)
	return execute_children(trigger_atoms, extra_data)
