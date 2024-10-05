
/**
 * baconmos procs for atmos
 */

/datum/controller/subsystem/air
	var/list/atmos_grid = list()
	/// List of atmospheric regions in the world
	var/list/atmospheric_regions = list()

/**
 * Sets the atmos density of a tile.
 * This will permanently seperate or connect regions together
 */
/datum/controller/subsystem/air/proc/set_density(x, y, z, density)
	var/turf/closed/affected_turf = locate(x, y, z)

/datum/controller/subsystem/air/proc/get_region(x, y, z)

/datum/controller/subsystem/air/proc/block_flow(x, y, z)

/datum/controller/subsystem/air/proc/allow_flow(x, y, z)

/**
 * Init shit
 */

/turf/var/_region_built = FALSE
/turf/var/_temp_group = 0

/datum/controller/subsystem/air/proc/initialise_atmospherics()
	for (var/z in 1 to world.maxz)
		build_z_level(z)

/datum/controller/subsystem/air/proc/build_z_level(z_value)
	// Expand the atmos grid until it reaches its necessary size
	while (length(atmos_grid) < z_value)
		var/list/z_grid = new(world.maxx, world.maxy)
		atmos_grid += z_grid

/datum/controller/subsystem/air/proc/build_zone_recursively(zone_x, zone_y, zone_z)
	var/left = zone_x
	var/bottom = zone_y
	var/right = zone_x
	var/top = zone_y
	// Begin expanding diagonally
	while (TRUE)
		var/vertical_check = TRUE
		var/horizontal_check = TRUE
		// Check for valid vertical expansion
		for (var/x in left to right + 1)
			var/turf/zone_turf = locate(x, top, zone_z)
			var/turf/identified_turf = locate(x, top + 1, zone_z)
			// Ensure that atmos can flow from a zone tile upwards
			if (!CANATMOSPASS(zone_turf, identified_turf))
				// If atmos cannot flow upwards, we cannot expand up
				vertical_check = FALSE
				break
			// Ensure that atmos can flow between all tiles in the vertical strip
			if (x > left)
				var/turf/left_turf = locate(x - 1, top + 1, zone_z)
				if (!CANATMOSPASS(left_turf, identified_turf))
					vertical_check = FALSE
					break
			if (x < right + 1)
				var/turf/right_turf = locate(x + 1, top + 1, zone_z)
				if (!CANATMOSPASS(left_turf, identified_turf))
					vertical_check = FALSE
					break
		// Check for valid horizontal expansion
		for (var/y in bottom to top + 1)
			var/turf/zone_turf = locate(right, y, zone_z)
			var/turf/identified_turf = locate(right + 1, y, zone_z)
			// Ensure that atmos can flow from a zone tile upwards
			if (!CANATMOSPASS(zone_turf, identified_turf))
				// If atmos cannot flow upwards, we cannot expand up
				horizontal_check = FALSE
				break
			// Ensure that atmos can flow between all tiles in the vertical strip
			if (y > bottom)
				var/turf/below_turf = locate(right + 1, y - 1, zone_z)
				if (!CANATMOSPASS(below_turf, identified_turf))
					horizontal_check = FALSE
					break
			if (y < top + 1)
				var/turf/above_turf = locate(right + 1, y + 1, zone_z)
				if (!CANATMOSPASS(above_turf, identified_turf))
					horizontal_check = FALSE
					break
		// Determine what to do next, which inolves descending deeper and finding
		// the adjacent zones
		// Zone cannot expand
		if (!vertical_check && !horizontal_check)
		// Zone can only expand upwards
		else if (vertical_check && !horizontal_check)
		// Zone can only expand right
		else if (!vertical_check && horizontal_check)
		// Zone can expand right and upwards, but we need to check that the corner is valid too
		else if (vertical_check && horizontal_check)

// This is going to be an expensive process that requires optimisation
// Since its in init times, at this point I don't really care if there are some micro ops
/datum/controller/subsystem/air/proc/build_regions()
	// Step 1: Group everything into regions based on connectivity
	var/list/regions = list()
	for (var/z in 1 to world.maxz)
		for (var/x in 1 to world.maxx)
			for (var/y in 1 to world.maxy)
				var/turf/T = locate(x, y, z)
				if (T._region_built || isspaceturf(T) || !T.CanAtmosPass(T))
					continue
				var/datum/temp_region/current_region = new()
				current_region.group_id = length(regions) + 1
				var/list/to_search = list(T)
				while (length(to_search))
					var/turf/open/searched = to_search[to_search.len]
					searched._region_built = TRUE
					to_search.len --
					current_region.turfs += searched
					searched._temp_group = current_region.group_id
					current_region.min_x = min(current_region.min_x, searched.x)
					current_region.min_y = min(current_region.min_y, searched.y)
					current_region.max_x = max(current_region.max_x, searched.x)
					current_region.max_y = max(current_region.max_y, searched.y)
					for (var/turf/open/adjacent in searched.GetAtmosAdjacentTurfs())
						if (adjacent._region_built || isspaceturf(adjacent))
							continue
						adjacent._region_built = TRUE
						to_search += adjacent
				regions += current_region
	to_chat(world, "[length(regions)] regions identified.")
	var/list/subregions = list()
	// Step 2: Divide each region into quad regions
	for (var/datum/temp_region/region in regions)
		while (length(region.turfs))
			var/datum/atmospheric_region/atmos_zone = new()
			var/turf/open/origin = region.turfs[1]
			region.turfs -= origin
			atmos_zone.turfs += origin
			origin._temp_group = 0
			origin.parent_region = atmos_zone
			var/minx = origin.x
			var/miny = origin.y
			var/maxx = origin.x
			var/maxy = origin.y
			// Greedy X expansion (Left)
			while (maxx + 1 <= world.maxx)
				var/turf/open/next = locate(maxx + 1, origin.y, origin.z)
				if (next._temp_group != region.group_id)
					break
				maxx = maxx + 1
				region.turfs -= next
				atmos_zone.turfs += next
				next.parent_region = atmos_zone
				next._temp_group = 0
			// Greedy X expansion (Right)
			while (minx - 1 >= 1)
				var/turf/open/next = locate(minx - 1, origin.y, origin.z)
				if (next._temp_group != region.group_id)
					break
				minx = minx - 1
				region.turfs -= next
				atmos_zone.turfs += next
				next.parent_region = atmos_zone
				next._temp_group = 0
			// Greedy Y expansion (Up)
			while (maxy + 1 <= world.maxy)
				// Ensure that the entire row of turfs is unblocked
				var/blocked = FALSE
				var/list/row = list()
				for (var/x in minx to maxx)
					var/turf/test = locate(x, maxy + 1, origin.z)
					if (test._temp_group != region.group_id)
						blocked = TRUE
						break
					row += test
				if (blocked)
					break
				maxy = maxy + 1
				for (var/turf/open/T in row)
					region.turfs -= T
					atmos_zone.turfs += T
					T.parent_region = atmos_zone
					T._temp_group = 0
			// Greedy Y expansion (Down)
			while (miny - 1 >= 1)
				// Ensure that the entire row of turfs is unblocked
				var/blocked = FALSE
				var/list/row = list()
				for (var/x in minx to maxx)
					var/turf/test = locate(x, miny - 1, origin.z)
					if (test._temp_group != region.group_id)
						blocked = TRUE
						break
					row += test
				if (blocked)
					break
				miny = miny - 1
				for (var/turf/opn/T in row)
					region.turfs -= T
					atmos_zone.turfs += T
					T.parent_region = atmos_zone
					T._temp_group = 0
			subregions += atmos_zone
	to_chat(world, "Atmos initialised with [length(subregions)] atmospheric regions.")
	for (var/datum/atmospheric_region/region in subregions)
		region.setup()
	atmospheric_regions = subregions

/datum/temp_region
	var/group_id
	var/list/turfs = list()
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY
