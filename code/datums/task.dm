/datum/task
	var/result = null
	var/completed = FALSE
	var/list/subtasks
	var/list/continue_withs

/// Add a subtask to this subtask. When awaiting a parent task, it will wait for all subtasks to complete
/// and then will return a list containing all the results.
/datum/task/proc/add_subtask(datum/task/subtask)
	LAZYADD(subtasks, subtask)

/// Mark the task as being completed
/datum/task/proc/mark_completed(result = null)
	if (length(subtasks))
		CRASH("Attempting to mark a subtask holder as completed. This is not allowed")
	completed = TRUE
	src.result = result
	for (var/datum/callback/continue_with in continue_withs)
		continue_with.Invoke(src)

/// Wait for the task to be completed, or the timeout to expire
/// Returns true if the task was completed
/datum/task/proc/await(timeout = 30 SECONDS)
	var/start_time = world.time
	var/sleep_time = 1
	while(world.time < start_time + timeout && !is_completed())
		sleep(sleep_time)
		sleep_time = min(sleep_time * 2, 1 SECONDS)
	// Check for success
	var/success = length(subtasks) ? TRUE : completed
	if (length(subtasks) && !result)
		result = list()
		for (var/datum/task/subtask in subtasks)
			if (!subtask.completed)
				success = FALSE
			if (subtask.result)
				result += subtask.result
	return success

/datum/task/proc/is_completed()
	if (length(subtasks))
		for (var/datum/task/subtask in subtasks)
			if (!subtask.completed)
				return FALSE
		return TRUE
	return completed

/// When the task is completed, continue by executing a callback.
/// This task will be pushed as the final paremeter to the callback
/datum/task/proc/continue_with(datum/callback/callback)
	if (completed)
		callback.Invoke(src)
	else
		if (!islist(continue_withs))
			continue_withs = list()
		continue_withs += callback
