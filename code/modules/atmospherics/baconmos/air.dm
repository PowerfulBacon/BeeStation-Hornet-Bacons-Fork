
/**
 * baconmos procs for atmos
 */

#define ATMOS_AT(x, y, z) atmos_grid[z][x][y]
// Turfs get atmos if they allow air init and don't have anything on them blocking their flow
#define TURF_SUPPORTS_ATMOS(turf) turf.atmos_flow_directions != 0

/datum/controller/subsystem/air
	/// The atmos grid, stores regions in a list of 2D arrays
	var/list/atmos_grid = list()
	/// List of atmospheric regions in the world
	var/list/atmospheric_regions = list()

/**
 * Sets the atmos density of a tile.
 * This will permanently seperate or connect regions together.
 */
/datum/controller/subsystem/air/proc/set_atmos_flow_directions(x, y, z, directions)
	// Check for blocked flow
	// We know we have to do something if we share a zone with something in that direction

/datum/controller/subsystem/air/proc/get_region(x, y, z)

/**
 * Allow flow between 2 regions, creating a temporary bridge
 * that will transfer gasses between 2 areas.
 */
/datum/controller/subsystem/air/proc/allow_flow(x, y, z)

/**
 * Removes the atmospheric bridge between 2 regions
 */
/datum/controller/subsystem/air/proc/block_flow(x, y, z)

/**
 * Inititalise the atmos grid to a consistent state
 */

/datum/controller/subsystem/air/proc/initialise_atmospherics()
	for (var/z in 1 to world.maxz)
		build_z_level(z)

/datum/controller/subsystem/air/proc/build_z_level(z_value)
	// Expand the atmos grid until it reaches its necessary size
	while (length(atmos_grid) < z_value)
		var/list/z_grid = new(world.maxx, world.maxy)
		atmos_grid += list(z_grid)
	for (var/x in 1 to world.maxx)
		for (var/y in 1 to world.maxy)
			if (ATMOS_AT(x, y, z_value))
				continue
			var/turf/T = locate(x, y, z_value)
			if (!TURF_SUPPORTS_ATMOS(T))
				continue
			var/list/region_zones = list()
			build_zone_recursively(x, y, z_value, region_zones)
			// Create the region
			var/datum/atmospheric_region/created_region = new(region_zones)

/datum/controller/subsystem/air/proc/build_zone_recursively(zone_x, zone_y, zone_z, list/created_zones)
	RETURN_TYPE(/datum/atmospheric_zone)
	var/left = zone_x
	var/bottom = zone_y
	var/right = zone_x
	var/top = zone_y
	var/expand_vertically = TRUE
	var/expand_horizontally = TRUE
	// Begin expanding diagonally
	while (TRUE)
		var/vertical_check = expand_vertically && top < world.maxy
		var/horizontal_check = expand_horizontally && right < world.maxx
		// Check for valid vertical expansion
		if (expand_vertically)
			for (var/x in left to right)
				var/turf/zone_turf = locate(x, top, zone_z)
				var/turf/identified_turf = locate(x, top + 1, zone_z)
				// Ensure that atmos can flow from a zone tile upwards
				if (!CANATMOSPASS(zone_turf, identified_turf) || ATMOS_AT(identified_turf.x, identified_turf.y, identified_turf.z) || !TURF_SUPPORTS_ATMOS(identified_turf))
					// If atmos cannot flow upwards, we cannot expand up
					vertical_check = FALSE
					break
				// Ensure that atmos can flow between all tiles in the vertical strip
				if (x > left)
					var/turf/left_turf = locate(x - 1, top + 1, zone_z)
					if (!CANATMOSPASS(left_turf, identified_turf))
						vertical_check = FALSE
						break
				if (x < right)
					var/turf/right_turf = locate(x + 1, top + 1, zone_z)
					if (!CANATMOSPASS(right_turf, identified_turf))
						vertical_check = FALSE
						break
		// Check for valid horizontal expansion
		if (expand_horizontally)
			for (var/y in bottom to top)
				var/turf/zone_turf = locate(right, y, zone_z)
				var/turf/identified_turf = locate(right + 1, y, zone_z)
				// Ensure that atmos can flow from a zone tile upwards
				if (!CANATMOSPASS(zone_turf, identified_turf) || ATMOS_AT(identified_turf.x, identified_turf.y, identified_turf.z) || !TURF_SUPPORTS_ATMOS(identified_turf))
					// If atmos cannot flow upwards, we cannot expand up
					horizontal_check = FALSE
					break
				// Ensure that atmos can flow between all tiles in the vertical strip
				if (y > bottom)
					var/turf/below_turf = locate(right + 1, y - 1, zone_z)
					if (!CANATMOSPASS(below_turf, identified_turf))
						horizontal_check = FALSE
						break
				if (y < top)
					var/turf/above_turf = locate(right + 1, y + 1, zone_z)
					if (!CANATMOSPASS(above_turf, identified_turf))
						horizontal_check = FALSE
						break
		// Determine what to do next, which involves descending deeper and finding
		// the adjacent zones
		// Zone cannot expand
		if (!vertical_check && !horizontal_check)
			// Return our created zone
			var/datum/atmospheric_zone/our_region = new(left, bottom, right, top, zone_z)
			created_zones += our_region
			// Continue zone expansion to the right
			var/pointer = bottom
			while (pointer <= top)
				var/turf/zone_turf = locate(right, pointer, zone_z)
				var/turf/identified_turf = locate(right + 1, pointer, zone_z)
				// If we cannot expand into the adjacent turf, don't make a zone there
				if (!CANATMOSPASS(zone_turf, identified_turf) || ATMOS_AT(identified_turf.x, identified_turf.y, identified_turf.z) || !TURF_SUPPORTS_ATMOS(identified_turf))
					pointer ++
					continue
				var/datum/atmospheric_zone/created_region = build_zone_recursively(right + 1, pointer, zone_z)
				// Move the pointer up above the created zone
				pointer = created_region.top + 1
			// Continue zone expansion above
			pointer = left
			while (pointer <= right)
				var/turf/zone_turf = locate(pointer, top, zone_z)
				var/turf/identified_turf = locate(pointer, top + 1, zone_z)
				// If we cannot expand into the adjacent turf, don't make a zone there
				if (!CANATMOSPASS(zone_turf, identified_turf) || ATMOS_AT(identified_turf.x, identified_turf.y, identified_turf.z) || !TURF_SUPPORTS_ATMOS(identified_turf))
					pointer ++
					continue
				var/datum/atmospheric_zone/created_region = build_zone_recursively(pointer, top + 1, zone_z)
				// Move the pointer up above the created zone
				pointer = created_region.right + 1
			return our_region
		// Zone can only expand upwards
		else if (vertical_check && !horizontal_check)
			expand_horizontally = FALSE
			top = top + 1
		// Zone can only expand right
		else if (!vertical_check && horizontal_check)
			expand_vertically = FALSE
			right = right + 1
		// Zone can expand right and upwards, but we need to check that the corner is valid too
		else if (vertical_check && horizontal_check)
			var/turf/corner_turf = locate(right + 1, top + 1, zone_z)
			var/turf/top_turf = locate(right, top + 1, zone_z)
			var/turf/right_turf = locate(right + 1, top, zone_z)
			if (ATMOS_AT(corner_turf.x, corner_turf.y, corner_turf.z) || !CANATMOSPASS(top_turf, corner_turf) || !CANATMOSPASS(right_turf, corner_turf) || !TURF_SUPPORTS_ATMOS(corner_turf))
				// Give priority to right expansion
				right = right + 1
				expand_vertically = FALSE
				break
			top = top + 1
			right = right + 1
