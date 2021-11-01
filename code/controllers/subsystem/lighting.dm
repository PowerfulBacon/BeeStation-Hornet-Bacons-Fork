//The index of light sources in the big world list
#define LIGHT_SOURCE 1
//The index of something exposed to a light source
#define LIGHT_EXPOSED 2
//The index of light viewers
#define LIGHT_VIEWER 3

//Defer events
#define LIGHT_DEFER_CREATION 1
#define LIGHT_DEFER_MODIFY 2
#define LIGHT_DEFER_DESTROY 3

SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING
	flags = SS_TICKER

	var/duplicate_shadow_updates_in_init = 0
	var/total_shadow_calculations = 0

	var/list/queued_shadow_updates = list()

	var/total_calculations = list()
	var/total_time_spent_processing = list()

	//Assoc list
	//Key = holder
	//Value = client
	var/list/deferred_viewer_inits = list()

	var/started = FALSE
	var/list/sources_that_need_updating = list()
	var/list/light_sources = list()

	//4 dimensional array containing lists of light sources.
	//light_source_grid[z][x][y][LIGHT_SOURCE] = list()
	//light_source_grid[z][x][y][LIGHT_VIEWER] = list()
	var/list/light_source_grid

	//Deffered creation events
	//Lights can be created, modified and destroyed before SSlighting init.
	//Store those events here and then deal with them later
	var/list/deferred_events = list(
		LIGHT_DEFER_CREATION = list(),
		LIGHT_DEFER_MODIFY = list(),
		LIGHT_DEFER_DESTROY = list()
		)

/datum/controller/subsystem/lighting/get_metrics()
	. = ..()
	var/list/cust = list()
	cust["total_shadow_calculations"] = total_shadow_calculations
	cust["sources_that_need_updating"] = length(sources_that_need_updating)
	cust["light_sources"] = length(light_sources)
	cust["queued_shadow_updates"] = length(queued_shadow_updates)
	.["custom"] = cust

/datum/controller/subsystem/lighting/New()
	. = ..()


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
		//Handle this
		handle_defered_events()
		//Do this
		for(var/atom/movable/lighting_mask_holder/holder as() in deferred_viewer_inits)
			var/client/C = deferred_viewer_inits[holder]
			holder.assign(C)
		deferred_viewer_inits = null
	fire(FALSE, TRUE)
	. = ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	if(LAZYLEN(queued_shadow_updates))
		draw_shadows()

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	light_source_grid = SSlighting.light_source_grid
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
				y_things += list(list(LIGHT_SOURCE = null, LIGHT_EXPOSED = null, LIGHT_VIEWER = null))
			x_things += list(y_things)
		light_source_grid += list(x_things)

/datum/controller/subsystem/lighting/proc/add_new_z()
	var/list/x_things = list()
	for(var/x in 1 to world.maxx)
		var/list/y_things
		for(var/y in 1 to world.maxy)
			//Add an empty list
			y_things += list(list(LIGHT_SOURCE = null, LIGHT_EXPOSED = null, LIGHT_VIEWER = null))
		x_things += list(y_things)
	light_source_grid += list(x_things)
	message_admins("added new z")	//breaks if this isnt added for some reason

//===============
// Shadow building
//===============

/datum/controller/subsystem/lighting/proc/build_shadows()
	var/timer = TICK_USAGE
	message_admins("Building [light_sources.len] shadows.")
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

//===============
// Handle defered events
//===============

/datum/controller/subsystem/lighting/proc/handle_defered_events()
	//Handle creation events
	for(var/source in deferred_events[LIGHT_DEFER_CREATION])
		create_source(source)
	//Handle destroy events
	for(var/source in deferred_events[LIGHT_DEFER_DESTROY])
		destroy_source(source)
	//Quick message
	to_chat(world, "<span class='boldannounce'>Created [length(deferred_events[LIGHT_DEFER_CREATION])] light sources at SSlighting initialization.</span>")
	to_chat(world, "<span class='boldannounce'>Destroyed [length(deferred_events[LIGHT_DEFER_DESTROY])] light sources at SSlighting initialization.</span>")
	//Finish up here, save memory
	deferred_events = null
