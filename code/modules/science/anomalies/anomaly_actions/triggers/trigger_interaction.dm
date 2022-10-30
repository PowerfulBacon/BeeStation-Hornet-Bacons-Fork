/**
 * Trigger Interaction
 * Attaches an interaction signal to the anomaly base.
 * When an interaction is triggered, the child nodes will be triggered.
 */

///Register signals to the anomaly base datum
/datum/anomaly_action/trigger/interaction/initialise_anomaly(datum/component/anomaly_base/anomaly)
	//This registers the signals with an intermediary class
	new /datum/event_holder(anomaly, src)
	//Register children
	..()

/datum/anomaly_action/trigger/interaction/trigger_action(atom/anomaly_parent, list/mob/living/trigger_mobs)
	for (var/datum/anomaly_action/child_action in children)
		child_action.trigger_action(anomaly_parent, trigger_mobs)

//Injection function due to the lack of lambda functions in DM
/datum/event_holder
	var/datum/component/anomaly_base/anomaly
	var/datum/anomaly_action/event_trigger

/datum/event_holder/New(anom, trig)
	. = ..()
	anomaly = anom
	event_trigger = trig
	RegisterSignal(anomaly.parent, COMSIG_ANOMALY_DIRECT_INTERACTION, .proc/trigger)

/datum/event_holder/proc/trigger(datum/source, mob/user)
	SIGNAL_HANDLER
	event_trigger.trigger_action(anomaly.parent, list(user))
