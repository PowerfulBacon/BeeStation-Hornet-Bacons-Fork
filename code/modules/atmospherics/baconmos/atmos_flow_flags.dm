
/// If true, this object will be considered atmos dense and will divide regions
/// Should be avoided on movable things if possible.
/// When atmos density is true, flow behaves in the following way:
/// - set_density(FALSE): Temporarilly creates a bridge between adjacent atmos regions, causing repressurisation to occur.
/// - set_atmos_density(FALSE): Permanently removed the atom's ability to block atmos, restoring the connectivity of zones
/// If a turf is set to atmos dense, then it must always have the flow directions set
/// Note that turfs will not respect the ATMOS_DENSE_DIRECTIONAL flag
/atom/var/atmos_density = ATMOS_PASS

/// Directions that atmos is allowed to flow on this turf.
/// Modified by atoms moving in and out of it.
/// Set on init for tuefs that have atmos densities
/turf/var/atmos_flow_directions = ALL

/// How many atmos dense objects are contained on this turf
/turf/var/atmos_dense_objects = 0
/// How many atmos dense objects which block to the north are contained on this turf
/turf/var/atmos_dense_north_objects = 0
/// How many atmos dense objects which block to the north are contained on this turf
/turf/var/atmos_dense_east_objects = 0
/// How many atmos dense objects which block to the north are contained on this turf
/turf/var/atmos_dense_south_objects = 0
/// How many atmos dense objects which block to the north are contained on this turf
/turf/var/atmos_dense_west_objects = 0

/**
 * Fully recalculates atmos density for scenarios where things
 * mysteriously get messed up for no good reason (admins)
 */
/turf/proc/reconsolidate_atmos_density()
	atmos_density = initial(atmos_density)
	atmos_dense_objects = 0
	atmos_dense_north_objects = 0
	atmos_dense_east_objects = 0
	atmos_dense_south_objects = 0
	atmos_dense_west_objects = 0
	atmos_flow_directions = ALL
	for (var/atom/atom in contents)
		// Atom is not blocking atmos at all
		if (!atom.atmos_density)
			continue
		// Atom is not currently restricting the flow of atmos
		if (!atom.density && !(atom.atmos_density & ATMOS_ALWAYS_DENSE))
			continue
		// Atom is blocking atmos, check directional flags
		if (atom.atmos_density & ATMOS_DENSE_DIRECTIONAL)
			if (atom.dir & NORTH)
				atmos_dense_north_objects ++
			if (atom.dir & EAST)
				atmos_dense_east_objects ++
			if (atom.dir & SOUTH)
				atmos_dense_south_objects ++
			if (atom.dir & WEST)
				atmos_dense_west_objects ++
		else
			atmos_dense_objects ++
	// Enable always density
	if (atmos_dense_objects)
		atmos_flow_directions = NONE
	// Enable north density
	if (atmos_dense_north_objects)
		atmos_flow_directions &= ~NORTH
	// Enable east density
	if (atmos_dense_east_objects)
		atmos_flow_directions &= ~EAST
	// Enable south density
	if (atmos_dense_south_objects)
		atmos_flow_directions &= ~SOUTH
	// Enable west density
	if (atmos_dense_west_objects)
		atmos_flow_directions &= ~WEST
	// Set the flow directions
	UPDATE_TURF_ATMOS_FLOW(src)
