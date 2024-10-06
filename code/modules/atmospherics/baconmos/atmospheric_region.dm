/datum/atmospheric_zone
	var/left
	var/bottom
	var/right
	var/top
	var/datum/gas_mixture/regional/gas
	var/list/gas_overlays = new(GAS_MAX)

/datum/atmospheric_zone/New(left, bottom, right, top, z_level)
	. = ..()
	src.left = left
	src.bottom = bottom
	src.right = right
	src.top = top
	var/list/turfs = block(locate(left, bottom, z_level), locate(top, right, z_level))
	gas = new(length(turfs) * CELL_VOLUME, src)
	var/color = random_color()
	// Set the turfs air reference
	for (var/turf/open/T in turfs)
		T.air = gas
		gas.populate_from_gas_string(T.initial_gas_mix)
		T.add_atom_colour("#[color]", ADMIN_COLOUR_PRIORITY)
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
