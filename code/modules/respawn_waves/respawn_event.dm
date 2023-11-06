/datum/respawn_event
	var/assigned_role = null
	var/special_role = null
	var/antag_datum = null

/// Generate the text to be annonuced to the station
/// spawned_mobs: A list of mobs that were spawned as part of executing this events
/// Returns: A text value or null, if there is no announcement.
/datum/respawn_event/proc/generate_announcement_text(list/spawned_mobs)
	return null

/// Execute the respawn events
/// candidates: A list of /clients of the people that want to be included in the respawn wave.
/datum/respawn_event/proc/execute(list/candidates)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/datum/task/async_task = prepare(candidates)
	if (!istype(async_task))
		generate_mobs(candidates)
	else
		// Since we can't create functions with a closure, we have to send the variable
		// like this which I don't like
		async_task.continue_with(CALLBACK(src, PROC_REF(prepare), candidates))

/// Prepare anything that needs to be done for this respawn event, such as crashing
/// a shuttle into the station
/// candidates: A list of /clients of the people that want to be included in the respawn wave.
/// Note: Returning a task will make this function work asynchronously
/datum/respawn_event/proc/prepare(list/candidates)

/// Generate the mobs for this respawn event
/// candidates: A list of /clients of the people that want to be included in the respawn wave. May contain nulls.
/datum/respawn_event/proc/generate_mobs(list/candidates)
	SHOULD_NOT_OVERRIDE(TRUE)
	// No candidates, nothing to do here
	if (!length(candidates))
		return
	// Generate the spawn locations for our candidates
	var/list/spawn_locations = generate_spawn_locations()
	// Ensure that we have enough spawns
	if (length(spawn_locations) < length(candidates))
		WARNING("Respawn event [type] made less spawn locations than there were candidates (Spawn locations: [length(spawn_locations)], candidates: [length(candidates)])")
	// Prevent bug behaviour by safely crashing
	if (!length(spawn_locations))
		CRASH("Respawn event [type] made no spawn locations! (Spawn locations: [length(spawn_locations)], candidates: [length(candidates)])")
	// Populate the spawn locations
	var/list/unused_spawns = spawn_locations.Copy()
	for (var/client/candidate in candidates)
		if (QDELETED(candidate))
			continue
		// Spawn the candidate
		var/mob/created_mob = generate_mob(pick_n_take(unused_spawns), candidate)
		// Create the mind
		var/datum/mind/new_mind = new /datum/mind(candidate.key)
		new_mind.active = TRUE
		new_mind.assigned_role = assigned_role
		new_mind.special_role = special_role
		if (antag_datum)
			new_mind.add_antag_datum(antag_datum)
		new_mind.transfer_to(created_mob)
		// Reset the unused spawn location list in the case that we made less spawn locations than candidates
		if (!length(unused_spawns))
			unused_spawns = spawn_locations.Copy()

/// Generates the list of valid spawn locations for this respawn wave.
/// candidates: A list of /clients of the people that want to be included in the respawn wave.
/// Returns: A list of turfs
/datum/respawn_event/proc/generate_spawn_locations(list/candidates)
	RETURN_TYPE(/list)

/// Generate a mob for a candidate. Note that you do not actually need to put the candidates mind into the mob, that is handled automatically.
/// Override this if you want a more control about the mobs that are created, if you simply want humans in outfits then use generate_outfit
/// spawn_location: The location that the mob should be spawned at.
/// candidate: The mind of the user attempting to be spawned
/// Returns a /mob
/datum/respawn_event/proc/generate_mob(turf/spawn_location, client/candidate)
	SHOULD_NOT_SLEEP(TRUE)
