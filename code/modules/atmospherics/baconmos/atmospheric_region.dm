/datum/atmospheric_region
	var/list/contained_zones

/**
 * When the region is subdivided, it is important that we check to ensure that
 * all zones within the region still linkup to all other zones and that a subdivision hasn't
 * occurred.
 */
/datum/atmospheric_region/proc/check_region_connectivity()
