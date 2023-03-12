/datum/anomaly_action
	/// The parent anomaly
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
///Returns TRUE/FALSE depending on if the action was successful or not
/datum/anomaly_action/proc/trigger_action(list/atom/trigger_atoms, list/extra_data)
	RETURN_TYPE(/datum/anomaly_action_result)
	CRASH("Not implemented exception on type [type]. The method 'trigger_action()' has not been implemented correctly.")

/// Execute the children and return the default result. May take in a result value if this proc
/// returns a result value.
/datum/anomaly_action/proc/execute_children(list/atom/trigger_atoms, list/extra_data, datum/anomaly_action_result/result = null)
	for (var/datum/anomaly_action/child_action in children)
		result = or(result, child_action.trigger_action(trigger_atoms, extra_data))
	return result

/// Requires that all children must succeed in order for this to succeed
/datum/anomaly_action/proc/execute_children_required(list/atom/trigger_atoms, list/extra_data, datum/anomaly_action_result/result = null)
	for (var/datum/anomaly_action/child_action in children)
		result = and(result, child_action.trigger_action(trigger_atoms, extra_data))
	return result

/// Create a failure result
/datum/anomaly_action/proc/fail()
	RETURN_TYPE(/datum/anomaly_action_result)
	var/static/failure = new /datum/anomaly_action_result(FALSE)
	return failure

/// Create a success result with the wrapped return value
/datum/anomaly_action/proc/success(value)
	RETURN_TYPE(/datum/anomaly_action_result)
	return new /datum/anomaly_action_result(TRUE, value)

/// Create a result with a failure/success state accordingly
/datum/anomaly_action/proc/finish(pass)
	RETURN_TYPE(/datum/anomaly_action_result)
	return new /datum/anomaly_action_result(pass)

/// Determine if an action is a failure or a success action
/datum/anomaly_action/proc/is_success(datum/anomaly_action_result/action)
	RETURN_TYPE(/datum/anomaly_action_result)
	return action.success

/// Create an empty failure result
/datum/anomaly_action/proc/result()
	RETURN_TYPE(/datum/anomaly_action_result)
	return new /datum/anomaly_action_result(FALSE)

/// Succeed if either are success values
/// NOTE: IN CASES WHERE BOTH RESULTS RETURN VALUES, THE SECOND WILL BE PRIORITISED
/datum/anomaly_action/proc/or(datum/anomaly_action_result/first, datum/anomaly_action_result/second)
	RETURN_TYPE(/datum/anomaly_action_result)
	if (!first)
		// Fail by default
		first = fail()
	first.success = first.success || second.success
	if (second.result)
		first.result = second.result
	return first

/// Suceed if both are success values
/// NOTE: IN CASES WHERE BOTH RESULTS RETURN VALUES, THE SECOND WILL BE PRIORITISED
/datum/anomaly_action/proc/and(datum/anomaly_action_result/first, datum/anomaly_action_result/second)
	RETURN_TYPE(/datum/anomaly_action_result)
	if (!first)
		// Fail by default
		first = fail()
	first.success = first.success && second.success
	if (second.result)
		first.result = second.result
	return first
