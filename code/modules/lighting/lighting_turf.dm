/turf
	luminosity           = 1

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	return CLAMP01(dynamic_lumcount)

// Returns a boolean whether the turf is on soft lighting.
// Soft lighting being the threshold at which point the overlay considers
// itself as too dark to allow sight and see_in_dark becomes useful.
// So basically if this returns true the tile is unlit black.
/turf/proc/is_softly_lit()
	return dynamic_lumcount > 0

/turf/proc/change_area(var/area/old_area, var/area/new_area)
	return
