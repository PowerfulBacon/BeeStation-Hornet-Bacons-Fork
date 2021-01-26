/turf/open/world_turf
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	name = "\proper world turf"
	intact = 0

	FASTDMM_PROP(\
		pipe_astar_cost = 4\
	)

	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/turf/open/world_turf/Initialize(mapload)
	if(!mapload)
		setup_world_turf()
	return INITIALIZE_HINT_NORMAL

/turf/open/world_turf/setup_world_turf()
	if(!istype(src, SSmapping.config.default_turf_type))

		if(!istype(loc, SSmapping.config.default_area_type))
			var/area/new_area = GLOB.areas_by_type[SSmapping.config.default_area_type]
			if(!new_area)
				new_area = new SSmapping.config.default_area_type()
			change_area(loc, new_area)

		ChangeTurf(SSmapping.config.default_turf_type, list(SSmapping.config.default_turf_type), CHANGETURF_SKIP)
		return

/turf/open/world_turf/Initalize_Atmos(times_fired)
	return
