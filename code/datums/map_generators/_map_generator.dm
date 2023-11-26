/// ======================================
/// Ruin generator process holder
/// ======================================
/datum/task/map_generator
	var/completed = FALSE
	var/ticks = 0

/// Begin generating
/datum/task/map_generator/proc/generate()
	SSmap_generator.executing_generators += src

/// Execute a current run.
/// Returns TRUE if finished
/datum/task/map_generator/proc/execute_run()
	ticks ++
	return TRUE

/datum/task/map_generator/proc/get_name()
	return "Map generator"
