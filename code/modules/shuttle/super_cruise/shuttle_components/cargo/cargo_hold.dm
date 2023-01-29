/**
 * Cargo hold tracker.
 * Uses a turf instead of a component since components do not appear to have
 * proper handling for turf shuttle movement.
 *
 * If at any point this is made into a component instead (which it should be)
 * you will need to refactor turfs to transfer their components when a shuttle
 * moves, however by doing that you need to take into consideration things that
 * shouldn't move, things that should be removed until the shuttle takes off
 * and things that should move with the shuttle which is a lot of work.
 *
 * Author: @PowerfulBacon#3338
 */

/turf/open/floor/plasteel/cargo
	name = "cargo bay"
	desc = "A designated cargo bay area which allows anything on top of it to be sold to nearby stations."
	base_icon_state = "cargo_hold"
	icon_state = "cargo_hold"
	broken_states = list("cargo_hold_damaged")
	burnt_states = list("cargo_hold_damaged")
	var/list/tracked = list()
	var/obj/docking_port/mobile/linked_shuttle

/turf/open/floor/plasteel/cargo/Initialize(mapload)
	. = ..()
	var/area/shuttle/shuttle_area = loc
	if (!istype(shuttle_area))
		return
	if (!shuttle_area.mobile_port)
		return
	connect_to_shuttle(shuttle_area.mobile_port, shuttle_area.mobile_port.docked, null)

/turf/open/floor/plasteel/cargo/Destroy()
	disconnect()
	return ..()

/turf/open/floor/plasteel/cargo/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	// Link up to a shuttle
	linked_shuttle = port
	if (!linked_shuttle)
		return
	RegisterSignal(linked_shuttle, COMSIG_PARENT_QDELETING, .proc/shuttle_destroyed)
	for (var/atom/movable/sellable_good in contents)
		register_sellable_good(sellable_good)

/turf/open/floor/plasteel/cargo/proc/disconnect()
	if (!linked_shuttle)
		return
	for (var/atom/movable/sellable_good in contents)
		unregister_sellable_good(sellable_good)
	UnregisterSignal(linked_shuttle, COMSIG_PARENT_QDELETING)
	linked_shuttle = null

/turf/open/floor/plasteel/cargo/proc/shuttle_destroyed()
	SIGNAL_HANDLER
	linked_shuttle = null

/turf/open/floor/plasteel/cargo/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if (!linked_shuttle)
		return
	register_sellable_good(arrived)

/turf/open/floor/plasteel/cargo/proc/register_sellable_good(atom/movable/sellable_good)
	// Ignore anything we can't sell
	if (iseffect(sellable_good) || !isobj(sellable_good) || (sellable_good in tracked))
		return
	tracked += sellable_good
	linked_shuttle.sellable_atoms += sellable_good
	//Register signals
	RegisterSignal(sellable_good, COMSIG_MOVABLE_MOVED, .proc/on_good_moved)
	RegisterSignal(sellable_good, COMSIG_PARENT_QDELETING, .proc/on_good_deleted)

/turf/open/floor/plasteel/cargo/proc/unregister_sellable_good(atom/movable/sellable_good)
	// Ignore anything we can't sell
	if (iseffect(sellable_good) || !isobj(sellable_good) || !(sellable_good in tracked))
		return
	tracked -= sellable_good
	linked_shuttle.sellable_atoms -= sellable_good
	//Unregister signals
	UnregisterSignal(sellable_good, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(sellable_good, COMSIG_PARENT_QDELETING)

/turf/open/floor/plasteel/cargo/proc/on_good_deleted(atom/movable/source)
	SIGNAL_HANDLER
	unregister_sellable_good(source)

/turf/open/floor/plasteel/cargo/proc/on_good_moved(atom/movable/source)
	SIGNAL_HANDLER
	// It moved to the exact same location
	if (source.loc == src)
		return
	unregister_sellable_good(source)

/turf/open/floor/plasteel/cargo/onShuttleMove(turf/open/floor/plasteel/cargo/new_cargo_turf, list/movement_force, move_dir, shuttle_layers)
	. = ..()
	//Items get moved before turfs, so re-connect the new turf
	new_cargo_turf.connect_to_shuttle(linked_shuttle)
