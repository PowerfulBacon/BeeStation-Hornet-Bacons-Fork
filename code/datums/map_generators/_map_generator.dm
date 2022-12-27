/// ======================================
/// Ruin generator process holder
/// ======================================
/datum/map_generator
	var/completed = FALSE
	var/ticks = 0
	var/list/datum/callback/completion_callbacks = list()
	var/list/callback_args
	var/list/waiting_for = list()

/// Begin generating
/datum/map_generator/proc/generate(...)
	Master.StartLoadingMap()
	SSmap_generator.executing_generators += src
	callback_args = args.Copy(1)

/datum/map_generator/proc/on_completion(datum/callback/completion_callback)
	completion_callbacks += completion_callback

// Attempt to execute the run, pause if we are awaiting
/datum/map_generator/proc/try_execute_run()
	//Check if we are waiting
	if (length(waiting_for))
		for (var/datum/map_generator/awaiting_generator as() in waiting_for)
			if (awaiting_generator.completed)
				waiting_for -= awaiting_generator
		// Wait to execute
		if (length(waiting_for))
			return MAP_GENERATOR_PAUSE
	// Execute the map generator
	return execute_run()

/// Execute a current run.
/// Returns TRUE if finished
/datum/map_generator/proc/execute_run()
	ticks ++
	return MAP_GENERATOR_FINISHED

/datum/map_generator/proc/wait_for(datum/map_generator/other)
	waiting_for += other

/datum/map_generator/proc/get_name()
	return "Map generator"

/datum/map_generator/proc/complete()
	Master.StopLoadingMap()
	completed = TRUE
	var/list/arguments = list(src)
	if (callback_args)
		arguments += callback_args
	for (var/datum/callback/on_completion as() in completion_callbacks)
		on_completion.Invoke(arglist(arguments))
	//to_chat(world, "<span class='announce'>[get_name()] completed and loaded succesfully.</span>")
