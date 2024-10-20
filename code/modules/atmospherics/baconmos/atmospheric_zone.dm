/datum/atmospheric_zone
	var/left
	var/bottom
	var/right
	var/top
	var/z_level
	var/datum/gas_mixture/regional/gas
	var/list/gas_overlays = new(GAS_MAX)

/datum/atmospheric_zone/New(left, bottom, right, top, z_level, populate_initial = TRUE)
	. = ..()
	src.left = left
	src.bottom = bottom
	src.right = right
	src.top = top
	src.z_level = z_level
	var/list/turfs = block(locate(left, bottom, z_level), locate(right, top, z_level))
	gas = new(length(turfs) * CELL_VOLUME, src)
	var/color = random_color()
	// Set the turfs air reference
	for (var/turf/open/T in turfs)
		T.air = gas
		SSair.atmos_grid[T.z][T.x][T.y] = src
		if (populate_initial)
			T.populate_initial_gas(gas, FALSE)
		T.add_atom_colour("#[color]", ADMIN_COLOUR_PRIORITY)
	gas.gas_content_change()
	// Setup the turfs gas overlays
	for (var/i in 1 to GAS_MAX)
		if (!GLOB.gas_data.overlays[i])
			continue
		gas_overlays[i] = new /obj/effect/overlay/gas(GLOB.gas_data.overlays[i])
	for (var/obj/effect/overlay/gas/gas_overlay in gas_overlays)
		if (!gas_overlay)
			continue
		gas_overlay.alpha = 0
		for (var/turf/open/T in turfs)
			T.vis_contents += gas_overlay

/datum/atmospheric_zone/proc/disassociate()
	var/list/turfs = block(locate(left, bottom, z_level), locate(right, top, z_level))
	for (var/obj/effect/overlay/gas/gas_overlay in gas_overlays)
		if (!gas_overlay)
			continue
		for (var/turf/open/T in turfs)
			T.vis_contents -= gas_overlay

/datum/atmospheric_zone/proc/count_turfs()
	return (right - left + 1) * (top - bottom + 1)

/datum/atmospheric_zone/proc/link_graph_nodes(datum/atmospheric_zone/adjacent)

/datum/atmospheric_zone/proc/horizontal_cut(y_value, direction)
	if (direction != NORTH && direction != SOUTH)
		CRASH("Invalid direction value passed to horizontal_cut, expected either NORTH or SOUTH, got [direction].")
	if (y_value == top && direction == NORTH)
		CRASH("Attempting to subdivide a zone on its northern border, which is not allowed. You need to subdivide the regions instead.")
	if (y_value == bottom && direction == SOUTH)
		CRASH("Attempting to subdivide a zone on its southern border, which is not allowed. You need to subdivide the regions instead.")
	if (left == right)
		// Subdivide the zone into 2 regions, complex logic
		return
	// As long as we aren't on the border of the area, then we are guaranteed to have flow
	var/original_area = count_turfs()
	// We are losing our gas, so tell our turfs that they can stop using the gas overlay
	disassociate()
	var/datum/atmospheric_zone/bottom_subdivision = new /datum/atmospheric_zone(left, bottom, right, direction == NORTH ? y_value : y_value - 1, z_level, FALSE)
	var/datum/atmospheric_zone/top_subdivision = new /datum/atmospheric_zone(left, direction == NORTH ? y_value + 1 : y_value, right, top, z_level, FALSE)
	// Distribute our gas among the bottom and top
	gas.transfer_ratio_to(bottom_subdivision.gas, bottom_subdivision.count_turfs() / original_area)
	gas.transfer_ratio_to(top_subdivision.gas, top_subdivision.count_turfs() / original_area)

/datum/atmospheric_zone/proc/vertical_cut(x_value, direction)
	if (direction != EAST && direction != WEST)
		CRASH("Invalid direction value passed to vertical_cut, expected either EAST or WEST, got [direction].")
	if (x_value == right && direction == EAST)
		CRASH("Attempting to subdivide a zone on its eastern border, which is not allowed. You need to subdivide the regions instead.")
	if (x_value == left && direction == WEST)
		CRASH("Attempting to subdivide a zone on its western border, which is not allowed. You need to subdivide the regions instead.")
	if (top == bottom)
		// Subdivide the zone into 2 regions, complex logic
		return
	// As long as we aren't on the border of the area, then we are guaranteed to have flow
	var/original_area = count_turfs()
	// We are losing our gas, so tell our turfs that they can stop using the gas overlay
	disassociate()
	var/datum/atmospheric_zone/left_subdivision = new /datum/atmospheric_zone(left, bottom, direction == EAST ? x_value : x_value - 1, top, z_level, FALSE)
	var/datum/atmospheric_zone/right_subdivision = new /datum/atmospheric_zone(direction == EAST ? x_value + 1 : x_value, bottom, right, top, z_level, FALSE)
	// Distribute our gas among the bottom and top
	gas.transfer_ratio_to(left_subdivision.gas, left_subdivision.count_turfs() / original_area)
	gas.transfer_ratio_to(right_subdivision.gas, right_subdivision.count_turfs() / original_area)
