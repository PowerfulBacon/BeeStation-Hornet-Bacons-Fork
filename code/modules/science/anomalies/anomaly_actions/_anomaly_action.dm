/datum/anomaly_action
	var/datum/component/anomaly_base/parent_anomaly
	/// Description of how this action works
	var/action_desc
	/// Any additional information to attach to the anomaly
	var/list/addition_details = list()
	/// Any actions that are children of this node, if the node supports children.
	var/list/children = list()

/datum/anomaly_action/Destroy(force, ...)
	QDEL_LIST(children)
	. = ..()

///Register signals to the anomaly base datum
/datum/anomaly_action/proc/initialise_anomaly(datum/component/anomaly_base/anomaly)
	SHOULD_CALL_PARENT(TRUE)
	parent_anomaly = anomaly
	//Initialise children
	for (var/datum/anomaly_action/child_action in children)
		child_action.initialise_anomaly(anomaly)

///Unregister signals from the base datum
/datum/anomaly_action/proc/deactive_anomaly(datum/component/anomaly_base/anomaly)
	SHOULD_CALL_PARENT(TRUE)
	//Unregister from anomaly object
	parent_anomaly = null
	//Deactivate children
	for (var/datum/anomaly_action/child_action in children)
		child_action.deactive_anomaly(anomaly)

///Trigger the action of the anomaly
/// anomaly_parent (/atom): The anomaly this action is attached to
/// trigger_mobs (list of /mob/living): Any mobs that are considered causes for the trigger (used in interaction triggers)
/datum/anomaly_action/proc/trigger_action(list/atom/trigger_atoms, list/extra_data)
	CRASH("Not implemented exception on type [type]. The method 'trigger_action()' has not been implemented correctly.")
