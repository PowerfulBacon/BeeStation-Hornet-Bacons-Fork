SUBSYSTEM_DEF(turf_setter)
	name = "Turf Setter"
	init_order = INIT_ORDER_WORLD_TURFS
	flags = SS_NO_FIRE
	//Are we creating a new z-level
	var/game_loading = TRUE
	var/list/creating_z_level = list()
	var/list/cached_init_turfs = list()

/datum/controller/subsystem/turf_setter/Initialize(start_timeofday)
	var/start_time = world.time
	to_chat(world, "<span class='boldannounce'>Setting world turfs.</span>")
	for(var/turf/T as() in block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz)))
		T.setup_world_turf()
		CHECK_TICK
	var/area/new_area = GLOB.areas_by_type[SSmapping.config.default_area_type]
	new_area.reg_in_areas_in_z()
	to_chat(world, "<span class='boldannounce'>World turfs setup in [DisplayTimeText(world.time - start_time)].</span>")
	game_loading = FALSE
	return ..()

/datum/controller/subsystem/turf_setter/proc/start_creating_z(z_value)
	creating_z_level |= z_value

/datum/controller/subsystem/turf_setter/proc/on_z_level_loaded(z_value)
	creating_z_level -= z_value
	if(game_loading || creating_z_level.len)
		return
	log_game("New Z-Level loaded, setting up [cached_init_turfs.len] turfs.")
	for(var/turf/T as() in cached_init_turfs)
		T.setup_world_turf()
		CHECK_TICK
	var/area/new_area = GLOB.areas_by_type[SSmapping.config.default_area_type]
	new_area.reg_in_areas_in_z()
	cached_init_turfs = list()

/datum/controller/subsystem/turf_setter/proc/should_quickinit(T)
	if(creating_z_level.len && !game_loading)
		cached_init_turfs += T
		return FALSE
	else
		return TRUE
