/**
 * Trigger Process
 * Will trigger children to perform their action event with
 * some set tick rate.
 * Returns a success state if any of the children return success states
 */

/datum/anomaly_action/trigger/process
	var/seconds_wait = 1
	var/_ticks = 0

///Register signals to the anomaly base datum
/datum/anomaly_action/trigger/process/initialise_anomaly(datum/component/anomaly_base/anomaly)
	. = ..()
	START_PROCESSING(SSanomaly_science, src)

/datum/anomaly_action/trigger/process/deactive_anomaly(datum/component/anomaly_base/anomaly)
	. = ..()
	STOP_PROCESSING(SSanomaly_science, src)

/datum/anomaly_action/trigger/process/process(delta_time)
	if ((_ticks ++) % seconds_wait != 0)
		return
	trigger_action(list(), list(
		"delta_time" = delta_time
	))

/datum/anomaly_action/trigger/process/trigger_action(list/atom/trigger_atoms, list/extra_data)
	return execute_children(trigger_atoms, extra_data)
