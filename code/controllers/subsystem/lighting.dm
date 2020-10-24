GLOBAL_LIST_EMPTY(lighting_update_lights) // List of lighting sources  queued for update.
GLOBAL_LIST_EMPTY(lighting_overlays)

SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER

	var/list/lighting_mask_queue = list()

/datum/controller/subsystem/lighting/Initialize(timeofday)
	if(!initialized)
		if (CONFIG_GET(flag/starlight))
			for(var/I in GLOB.sortedAreas)
				var/area/A = I
				if (A.dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
					A.luminosity = 0
		initialized = TRUE
	return ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	return

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
