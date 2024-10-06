/turf/open/water
	gender = PLURAL
	name = "water"
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/chasm/lavaland
	planetary_atmos = TRUE
	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

APPLY_OPENTURF_LOW_PRESSURE(/turf/open/water)

/turf/open/water/red
	icon_state = "abyssal_water"

/turf/open/water/air
	planetary_atmos = FALSE

APPLY_OPENTURF_DEFAULT_ATMOS(/turf/open/water/air)

APPLY_OPENTURF_DEFAULT_ATMOS(/turf/open/water/jungle)
