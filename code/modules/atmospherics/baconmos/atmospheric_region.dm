/datum/atmospheric_region
	var/list/contained_zones

/datum/atmospheric_region/New(list/zones)
	. = ..()
	contained_zones = zones
	for (var/datum/atmospheric_zone/zone as anything in contained_zones)
		zone.region = src

/**
 * When the region is subdivided, it is important that we check to ensure that
 * all zones within the region still linkup to all other zones and that a subdivision hasn't
 * occurred.
 */
/datum/atmospheric_region/proc/check_region_connectivity()
	var/datum/atmospheric_region/master = contained_zones[1]
	// Merge with adjacent zones
	for (var/datum/atmospheric_zone/adjacent_zone in master.get_border_zones())
