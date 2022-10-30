/datum/anomaly_action
	/// Description of how this action works
	var/action_desc
	/// Any additional information to attach to the anomaly
	var/list/addition_details = list()
	/// Any actions that are children of this node, if the node supports children.
	var/list/children = list()

///Register signals to the anomaly base datum
/datum/anomaly_action/proc/initialise_anomaly(datum/component/anomaly_base/anomaly)
	//Initialise children
	for (var/datum/anomaly_action/child_action in children)
		children.initialise_anomaly(anomaly)

///Trigger the action of the anomaly
/// anomaly_parent (/atom): The anomaly this action is attached to
/// trigger_mobs (list of /mob/living): Any mobs that are considered causes for the trigger (used in interaction triggers)
/datum/anomaly_action/proc/trigger_action(atom/anomaly_parent, list/mob/living/trigger_mobs)
	CRASH("Not implemented exception on type [type]. The method 'trigger_action()' has not been implemented correctly.")
