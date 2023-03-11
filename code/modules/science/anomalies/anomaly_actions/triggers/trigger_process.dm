/**
 * Trigger Process
 * Will trigger children to perform their action event with
 * some set tick rate.
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
	for (var/datum/anomaly_action/child_action in children)
		child_action.trigger_action(trigger_atoms, extra_data)
