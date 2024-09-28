/datum/gas_mixture/regional
	var/datum/atmospheric_region/region
	var/will_reconsile = FALSE

/datum/gas_mixture/regional/New(volume, region)
	. = ..(volume)
	src.region = region

/datum/gas_mixture/regional/gas_content_change(visual_only = FALSE)
	// Bundle gas changes together in order to propogate them to other
	// directly adjacent regions.
	if (!visual_only && length(region.shared_regions) > 1)
		if (will_reconsile)
			return
		will_reconsile = TRUE
		// This will execute upon the next time that Byond decides to yield
		// which allows us to bundle multiple changes into a single visual update
		// preventing this from executing 14 times if we merge 2 gasses together
		spawn(0)
			will_reconsile = FALSE
			if (!region.shared_gas_mixtures)
				region.shared_gas_mixtures = list()
				for (var/datum/atmospheric_region/shared in region.shared_regions)
					region.shared_gas_mixtures += shared.gas
			// Perform regional sharing
			equalize_all_gases_in_list(region.shared_gas_mixtures, TRUE)
		return
	// Recalculate the appearance of the region
	for (var/i in 1 to GAS_MAX)
		var/obj/effect/overlay/gas/gas_overlay = region.gas_overlays[i]
		if (!gas_overlay)
			continue
		gas_overlay.alpha = 255 * CLAMP01(gas_contents[i] / (FACTOR_GAS_VISIBLE_MAX * (initial_volume / CELL_VOLUME)))
