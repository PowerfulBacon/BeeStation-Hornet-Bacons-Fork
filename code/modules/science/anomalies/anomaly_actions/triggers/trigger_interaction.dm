/**
 * Trigger Interaction
 * Attaches an interaction signal to the anomaly base.
 * When an interaction is triggered, the child nodes will be triggered.
 */

///Register signals to the anomaly base datum
/datum/anomaly_action/trigger/interaction/register_signals(datum/anomaly_base/anomaly)
	RegisterSignal(anomaly, COMSIG_ANOMALY_DIRECT_INTERACTION, .proc/triggered)

/datum/anomaly_action/trigger/interaction/proc/triggered(mob/user)
	for (var/datum/anomaly_action/child_action in sub_actions)
		child_action.trigger_action(anomaly.parent_atom, list(user))
