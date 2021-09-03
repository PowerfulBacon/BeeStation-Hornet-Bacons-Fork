//The index of light sources in the big world list
#define LIGHT_SOURCE "source"
//The index of light viewers
#define LIGHT_VIEWER "viewer"

SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING

	var/duplicate_shadow_updates_in_init = 0
	var/total_shadow_calculations = 0

	var/list/queued_shadow_updates = list()

	var/total_calculations = list()
	var/total_time_spent_processing = list()

	var/started = FALSE
	var/list/sources_that_need_updating = list()
	var/list/light_sources = list()

	//A list of all light mask holders
	var/list/light_mask_holders = list()

	//3 dimensional array containing lists of light sources.
	//light_source_grid[z][x][y][LIGHT_SOURCE] = list()
	//light_source_grid[z][x][y][LIGHT_VIEWER] = list()
	var/list/light_source_grid

/client/verb/get_lighting_speed()
	set name = "light speed"
	set category = "lighting"

	for(var/range in SSlighting.total_calculations)
		var/total_amount = SSlighting.total_calculations[range]
		var/total_time = SSlighting.total_time_spent_processing[range]
		to_chat(usr, "[range] - [total_time / total_amount] ms")

/datum/controller/subsystem/lighting/Initialize(timeofday)
	started = TRUE
	if(!initialized)
		//Handle fancy lighting
		to_chat(world, "<span class='boldannounce'>Generating shadows on [sources_that_need_updating.len] light sources.</span>")
		var/timer = TICK_USAGE
		for(var/atom/movable/lighting_mask/mask as() in sources_that_need_updating)
			mask.calculate_lighting_shadows()
		sources_that_need_updating = null
		//Build the array
		setup_initial_sources()
		to_chat(world, "<span class='boldannounce'>Initial lighting conditions built successfully in [TICK_USAGE_TO_MS(timer)]ms.</span>")
		initialized = TRUE
	fire(FALSE, TRUE)
	. = ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	if(LAZYLEN(queued_shadow_updates))
		draw_shadows()

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()

//===============
// Light source rendering
//===============

/datum/controller/subsystem/lighting/proc/setup_initial_sources()
	for(var/z in 1 to world.maxz)
		var/list/x_things = list()
		for(var/x in 1 to world.maxx)
			var/list/y_things
			for(var/y in 1 to world.maxy)
				//Add an empty list
				y_things += list(list(LIGHT_SOURCE = list(), LIGHT_VIEWER = list()))
			x_things += list(y_things)
		light_source_grid += list(x_things)

/datum/controller/subsystem/lighting/proc/add_new_z()
	var/list/x_things = list()
	for(var/x in 1 to world.maxx)
		var/list/y_things
		for(var/y in 1 to world.maxy)
			//Add an empty list
			y_things += list(list(LIGHT_SOURCE = list(), LIGHT_VIEWER = list()))
		x_things += list(y_things)
	light_source_grid += list(x_things)

//===============
// Shadow building
//===============

/datum/controller/subsystem/lighting/proc/build_shadows()
	var/timer = TICK_USAGE
	message_admins("Building [light_sources.len] shadows, its been an honour mrs obama")
	for(var/datum/light_source/light as() in light_sources)
		light.our_mask.calculate_lighting_shadows()
	message_admins("Shadows built in [TICK_USAGE_TO_MS(timer)]ms ([light_sources.len] shadows)")

/datum/controller/subsystem/lighting/proc/queue_shadow_render(mask_to_queue)
	LAZYOR(queued_shadow_updates, mask_to_queue)

/datum/controller/subsystem/lighting/proc/draw_shadows()
	for(var/atom/movable/lighting_mask/mask as() in queued_shadow_updates)
		mask.calculate_lighting_shadows(TRUE)
	LAZYCLEARLIST(queued_shadow_updates)


//===============
// Stat Entry
//===============

/datum/controller/subsystem/lighting/stat_entry()
	. = ..("Sources: [light_sources.len], ShCalcs: [total_shadow_calculations]")

/*

	light_source_type = FANCY_LIGHTING

	light_mask_type = /atom/movable/lighting_mask

*/
