/datum/atmospheric_region
	var/list/turfs = list()
	var/datum/gas_mixture/regional/gas
	var/list/gas_overlays = new(GAS_MAX)
	/// Directly adjacent regions to this one
	var/list/adjacent = list()
	var/_last_share = 0
	/// List of regions that we directly share with, including ourselves
	var/list/shared_regions = list()
	var/list/shared_gas_mixtures = null

/datum/atmospheric_region/proc/setup()
	gas = new(length(turfs) * CELL_VOLUME, src)
	var/color = random_color()
	// Set the turfs air reference
	for (var/turf/open/T in turfs)
		T.air = gas
		gas.populate_from_gas_string(T.initial_gas_mix)
		T.add_atom_colour("#[color]", ADMIN_COLOUR_PRIORITY)
		// Join adjacent areas, kinda temporary, kinda not really
		for (var/turf/adjacent_turf in T.GetAtmosAdjacentTurfs())
			if (adjacent_turf.atmospheric_region != src)
				adjacent |= adjacent_turf.atmospheric_region
	// Calculate shared regions
	recalculate_shared_regions()
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

/datum/atmospheric_region/proc/recalculate_shared_regions()
	// Calculate linked regions
	var/static/total_shares = 0
	_last_share = ++total_shares
	for (var/datum/atmospheric_region/region as() in shared_regions)
		region.shared_regions -= src
	shared_regions = list(src)
	for (var/i = 1; i <= length(shared_regions); i++)
		var/datum/atmospheric_region/check_region = shared_regions[i]
		check_region._last_share = _last_share
		for (var/datum/atmospheric_region/adjacent_regions as() in check_region.adjacent)
			if (adjacent_regions._last_share == _last_share)
				continue
			shared_regions += adjacent_regions
		shared_regions[i] = check_region
	