/turf/open/world_turf
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	name = "\proper world turf"
	intact = 0

	FASTDMM_PROP(\
		pipe_astar_cost = 4\
	)

	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

	var/static/datum/gas_mixture/immutable/space/empty_space = new

/turf/open/world_turf/Initialize(mapload = FALSE)
	do_init_stuff()

	if(!SSturf_setter.should_quickinit(src))
		return INITIALIZE_HINT_NORMAL

	if(!mapload)
		setup_world_turf()

	return INITIALIZE_HINT_NORMAL

/turf/open/world_turf/setup_world_turf()

	if(!istype(loc, SSmapping.config.default_area_type))
		//Find the area type
		var/area/new_area = GLOB.areas_by_type[SSmapping.config.default_area_type]
		//Create the area if it doesn't exist
		if(!new_area)
			message_admins("New area type created!")
			new_area = new SSmapping.config.default_area_type()
		new_area.contents += src
		change_area(loc, new_area)

	//Change ourselves
	new SSmapping.config.default_turf_type(src, TRUE)

/turf/open/world_turf/proc/do_init_stuff()
	air = empty_space
	update_air_ref()
	vis_contents.Cut() //removes inherited overlays
	visibilityChanged()

	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")

	flags_1 |= INITIALIZED_1

/turf/open/world_turf/Initalize_Atmos(times_fired)
	return
