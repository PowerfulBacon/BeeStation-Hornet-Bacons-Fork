/obj/docking_port/stationary/spawn_point
	var/faction_allowed = NONE
	var/datum/dock_allocation_tracker/current_allocation

/obj/docking_port/stationary/spawn_point/Initialize(mapload)
	. = ..()
	SSship_spawning.spawn_points += src

/obj/docking_port/stationary/spawn_point/Destroy(force)
	QDEL_NULL(current_allocation)
	. = ..()

/obj/docking_port/stationary/spawn_point/proc/can_spawn_here(faction_tags)
	// All faction tags must be allowed to spawn here
	if ((faction_tags & faction_allowed) != faction_tags)
		return FALSE
	// Check if there are enemies on our z-level
	for (var/mob/living/player in GLOB.mob_living_list)
		var/turf/T = get_turf(player)
		if (T.z != z)
			continue
		if ((faction_allowed & FACTION_SYNDICATE) && istype(player.assigned_faction, /datum/faction/nanotrasen))
			return FALSE
		if ((faction_allowed & FACTION_NANOTRASEN) && istype(player.assigned_faction, /datum/faction/syndicate))
			return FALSE
	return TRUE

/obj/docking_port/stationary/spawn_point/on_docked(obj/docking_port/mobile/docked)
	current_allocation = new /datum/dock_allocation_tracker(docked.id, src)
	return ..()
