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
		//Handle legacy lightnig
		create_all_lighting_objects()
		var/timer = TICK_USAGE
		for(var/atom/movable/lighting_mask/mask as() in sources_that_need_updating)
			mask.light_mask_update()
		sources_that_need_updating = null
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

/datum/controller/subsystem/lighting/proc/build_shadows()
	var/timer = TICK_USAGE
	message_admins("Building [light_sources.len] shadows, its been an honour mrs obama")
	for(var/datum/light_source/light as() in light_sources)
		light.our_mask.light_mask_update()
	message_admins("Shadows built in [TICK_USAGE_TO_MS(timer)]ms ([light_sources.len] shadows)")

/datum/controller/subsystem/lighting/proc/queue_shadow_render(mask_to_queue)
	LAZYOR(queued_shadow_updates, mask_to_queue)

/datum/controller/subsystem/lighting/proc/draw_shadows()
	for(var/atom/movable/lighting_mask/mask as() in queued_shadow_updates)
		mask.light_mask_update(TRUE)
	LAZYCLEARLIST(queued_shadow_updates)

//!!!!LEGACY!!!!!

GLOBAL_LIST_EMPTY(lighting_update_lights) // List of lighting sources  queued for update.
GLOBAL_LIST_EMPTY(lighting_update_corners) // List of lighting corners  queued for update.
GLOBAL_LIST_EMPTY(lighting_update_objects) // List of lighting objects queued for update.

/datum/controller/subsystem/lighting/stat_entry()
	. = ..("Sources: [light_sources.len], ShCalcs: [total_shadow_calculations]|L:[GLOB.lighting_update_lights.len]|C:[GLOB.lighting_update_corners.len]|O:[GLOB.lighting_update_objects.len]")

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	if(LAZYLEN(queued_shadow_updates))
		draw_shadows()

	MC_SPLIT_TICK_INIT(3)

	if(!init_tick_checks)
		MC_SPLIT_TICK

	var/i = 0
	for (i in 1 to GLOB.lighting_update_lights.len)
		var/datum/legacy_light_source/L = GLOB.lighting_update_lights[i]

		L.update_corners()

		L.needs_update = LIGHTING_NO_UPDATE

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.lighting_update_lights.Cut(1, i+1)
		i = 0

	if(!init_tick_checks)
		MC_SPLIT_TICK

	for (i in 1 to GLOB.lighting_update_corners.len)
		var/datum/legacy_lighting_corner/C = GLOB.lighting_update_corners[i]

		C.update_objects()
		C.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.lighting_update_corners.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	for (i in 1 to GLOB.lighting_update_objects.len)
		var/atom/movable/legacy_lighting_object/O = GLOB.lighting_update_objects[i]

		if (QDELETED(O))
			continue

		O.update()
		O.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.lighting_update_objects.Cut(1, i+1)
