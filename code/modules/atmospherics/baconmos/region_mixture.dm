/datum/gas_mixture/regional
	var/datum/atmospheric_zone/region
	var/will_reconsile = FALSE

/datum/gas_mixture/regional/New(volume, region)
	. = ..(volume)
	src.region = region

/datum/gas_mixture/regional/gas_content_change(visual_only = FALSE)
	// Recalculate the appearance of the region
	for (var/i in 1 to GAS_MAX)
		var/obj/effect/overlay/gas/gas_overlay = region.gas_overlays[i]
		if (!gas_overlay)
			continue
		gas_overlay.alpha = 255 * CLAMP01(gas_contents[i] / (FACTOR_GAS_VISIBLE_MAX * (initial_volume / CELL_VOLUME)))
