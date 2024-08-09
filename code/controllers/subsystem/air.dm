SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 0.5 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cached_cost = 0

	var/cost_turfs = 0
	var/cost_groups = 0
	var/cost_highpressure = 0
	var/cost_deferred_airs
	var/cost_hotspots = 0
	var/cost_post_process = 0
	var/cost_superconductivity = 0
	var/cost_pipenets = 0
	var/cost_rebuilds = 0
	var/cost_atmos_machinery = 0
	var/cost_equalize = 0
	var/thread_wait_ticks = 0
	var/cur_thread_wait_ticks = 0

	var/low_pressure_turfs = 0
	var/high_pressure_turfs = 0

	var/num_group_turfs_processed = 0
	var/num_equalize_processed = 0

	var/gas_mixes_count = 0
	var/gas_mixes_allocated = 0

	var/list/hotspots = list()
	var/list/networks = list()
	var/list/pipenets_needing_rebuilt = list()
	var/list/obj/machinery/atmos_machinery = list()
	var/list/pipe_init_dirs_cache = list()

	//atmos singletons
	var/list/gas_reactions = list()
	var/list/atmos_gen
	var/list/planetary = list() //auxmos already caches static planetary mixes but could be convenient to do so here too
	//Special functions lists
	var/list/turf/open/high_pressure_delta = list()


	var/list/currentrun = list()
	var/currentpart = SSAIR_REBUILD_PIPENETS

	var/map_loading = TRUE

	var/log_explosive_decompression = TRUE // If things get spammy, admemes can turn this off.

	// Max number of turfs equalization will grab.
	var/equalize_turf_limit = 10
	// Max number of turfs to look for a space turf, and max number of turfs that will be decompressed.
	var/equalize_hard_turf_limit = 2000
	// Whether equalization is enabled. Can be disabled for performance reasons.
	var/equalize_enabled = FALSE
	// Max number of times process_turfs will share in a tick.
	var/share_max_steps = 3
	// Target for share_max_steps; can go below this, if it determines the thread is taking too long.
	var/share_max_steps_target = 3
	// Excited group processing will try to equalize groups with total pressure difference less than this amount.
	var/excited_group_pressure_goal = 1
	// Target for excited_group_pressure_goal; can go below this, if it determines the thread is taking too long.
	var/excited_group_pressure_goal_target = 1

	var/list/paused_z_levels	//Paused z-levels will not add turfs to active

	var/planet_share_ratio = 0

/datum/controller/subsystem/air/stat_entry(msg)
	msg += "C:{"
	msg += "HP:[round(cost_highpressure,1)]|"
	msg += "HS:[round(cost_hotspots,1)]|"
	msg += "SC:[round(cost_superconductivity,1)]|"
	msg += "PN:[round(cost_pipenets,1)]|"
	msg += "AM:[round(cost_atmos_machinery,1)]"
	msg += "} "
	msg += "TC:{"
	msg += "AT:[round(cost_turfs,1)]|"
	msg += "EG:[round(cost_groups,1)]|"
	msg += "EQ:[round(cost_equalize,1)]|"
	msg += "PO:[round(cost_post_process,1)]"
	msg += "}"
	msg += "TH:[round(thread_wait_ticks,1)]|"
	msg += "HS:[hotspots.len]|"
	msg += "PN:[networks.len]|"
	msg += "HP:[high_pressure_delta.len]|"
	msg += "HT:[high_pressure_turfs]|"
	msg += "LT:[low_pressure_turfs]|"
	msg += "ET:[num_equalize_processed]|"
	msg += "GT:[num_group_turfs_processed]|"
	msg += "GA:[gas_mixes_count]|"
	msg += "MG:[gas_mixes_allocated]"
	return ..()

/datum/controller/subsystem/air/Initialize(timeofday)
	map_loading = FALSE
	setup_allturfs()
	setup_atmos_machinery()
	setup_pipenets()
	gas_reactions = init_gas_reactions()
	auxtools_update_reactions()
	equalize_enabled = CONFIG_GET(flag/atmos_equalize_enabled)
	return ..()

/datum/controller/subsystem/air/proc/extools_update_ssair()


/datum/controller/subsystem/air/proc/add_reaction(datum/gas_reaction/r)
	gas_reactions += r
	sortTim(gas_reactions, GLOBAL_PROC_REF(cmp_gas_reaction))
	auxtools_update_reactions()

/proc/reset_all_air()
	SSair.can_fire = 0
	message_admins("Air reset begun.")
	for(var/turf/open/T in world)
		T.Initalize_Atmos(0)
		CHECK_TICK
	message_admins("Air reset done.")
	SSair.can_fire = 1

/proc/fix_corrupted_atmos()

/datum/admins/proc/fixcorruption()
	set category = "Debug"
	set desc="Fixes air that has weird NaNs (-1.#IND and such). Hopefully."
	set name="Fix Infinite Air"
	fix_corrupted_atmos()

/datum/controller/subsystem/air/fire(resumed = 0)
	var/timer = TICK_USAGE_REAL

	thread_wait_ticks = MC_AVERAGE(thread_wait_ticks, cur_thread_wait_ticks)
	cur_thread_wait_ticks = 0

	gas_mixes_count = get_amt_gas_mixes()
	gas_mixes_allocated = get_max_gas_mixes()

	if(currentpart == SSAIR_REBUILD_PIPENETS)
		timer = TICK_USAGE_REAL
		var/list/pipenet_rebuilds = pipenets_needing_rebuilt
		for(var/thing in pipenet_rebuilds)
			var/obj/machinery/atmospherics/AT = thing
			if(!istype(AT))
				continue
			AT.build_network()
		cost_rebuilds = MC_AVERAGE(cost_rebuilds, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		pipenets_needing_rebuilt.Cut()
		if(state != SS_RUNNING)
			return
		resumed = FALSE
		currentpart = SSAIR_PIPENETS

	if(currentpart == SSAIR_PIPENETS || !resumed)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_pipenets(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(cached_cost))
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY

	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_atmos_machinery(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		resumed = 0
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(cached_cost))
		currentpart = SSAIR_ACTIVETURFS

	if(currentpart == SSAIR_ACTIVETURFS)
		timer = TICK_USAGE_REAL
		if (process_turfs_auxtools(resumed))
			pause()
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = equalize_enabled ? SSAIR_EQUALIZE : SSAIR_EXCITEDGROUPS

	if(currentpart == SSAIR_EQUALIZE)
		if (process_turf_equalize_auxtools(resumed))
			pause()
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_EXCITEDGROUPS

	if(currentpart == SSAIR_EXCITEDGROUPS)
		if (process_excited_groups_auxtools(resumed))
			pause()
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_FINALIZE_TURFS

	if(currentpart == SSAIR_FINALIZE_TURFS)
		if (finish_turf_processing_auxtools(resumed))
			pause()
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_HIGHPRESSURE

	if(currentpart == SSAIR_HIGHPRESSURE)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_high_pressure_delta(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_highpressure = MC_AVERAGE(cost_highpressure, TICK_DELTA_TO_MS(cached_cost))
		resumed = 0
		currentpart = SSAIR_HOTSPOTS

	if(currentpart == SSAIR_HOTSPOTS)
		timer = TICK_USAGE_REAL
		if(!resumed)
			cached_cost = 0
		process_hotspots(resumed)
		cached_cost += TICK_USAGE_REAL - timer
		if(state != SS_RUNNING)
			return
		cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(cached_cost))
		resumed = 0
		currentpart = SSAIR_REBUILD_PIPENETS

/datum/controller/subsystem/air/proc/process_pipenets(resumed = 0)
	if (!resumed)
		src.currentrun = networks.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process()
		else
			networks.Remove(thing)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/add_to_rebuild_queue(atmos_machine)
	if(istype(atmos_machine, /obj/machinery/atmospherics))
		pipenets_needing_rebuilt += atmos_machine

/datum/controller/subsystem/air/proc/process_atmos_machinery(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/M = currentrun[currentrun.len]
		currentrun.len--
		if(!M || (M.process_atmos(seconds) == PROCESS_KILL))
			atmos_machinery.Remove(M)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_hotspots(resumed = 0)
	if (!resumed)
		src.currentrun = hotspots.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/effect/hotspot/H = currentrun[currentrun.len]
		currentrun.len--
		if (H)
			H.process()
		else
			hotspots -= H
		if(MC_TICK_CHECK)
			return


/datum/controller/subsystem/air/proc/process_high_pressure_delta(resumed = 0)
	while (high_pressure_delta.len)
		var/turf/open/T = high_pressure_delta[high_pressure_delta.len]
		high_pressure_delta.len--
		T.high_pressure_movements()
		T.pressure_difference = 0
		T.pressure_specific_target = null
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/StartLoadingMap()
	map_loading = TRUE

/datum/controller/subsystem/air/StopLoadingMap()
	map_loading = FALSE

/datum/controller/subsystem/air/proc/setup_allturfs()
	var/list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))
	var/times_fired = ++src.times_fired

	// Clear active turfs - faster than removing every single turf in the world
	// one-by-one, and Initalize_Atmos only ever adds `src` back in.

	for(var/thing in turfs_to_init)
		var/turf/T = thing
		if (T.blocks_air)
			continue
		T.Initalize_Atmos(times_fired)
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.atmosinit()
		CHECK_TICK

//this can't be done with setup_atmos_machinery() because
//	all atmos machinery has to initalize before the first
//	pipenet can be built.
/datum/controller/subsystem/air/proc/setup_pipenets()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.build_network()
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	if(!initialized) // yogs - fixes randomized bars
		return // yogs
	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.atmosinit()
		CHECK_TICK

	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.build_network()
		CHECK_TICK

/datum/controller/subsystem/air/proc/get_init_dirs(type, dir)
	if(!pipe_init_dirs_cache[type])
		pipe_init_dirs_cache[type] = list()

	if(!pipe_init_dirs_cache[type]["[dir]"])
		var/obj/machinery/atmospherics/temp = new type(null, FALSE, dir)
		pipe_init_dirs_cache[type]["[dir]"] = temp.GetInitDirections()
		qdel(temp)

	return pipe_init_dirs_cache[type]["[dir]"]

/datum/controller/subsystem/air/proc/generate_atmos()
	atmos_gen = list()
	for(var/T in subtypesof(/datum/atmosphere))
		var/datum/atmosphere/atmostype = T
		atmos_gen[initial(atmostype.id)] = new atmostype

/datum/controller/subsystem/air/proc/preprocess_gas_string(gas_string)
	if(!atmos_gen)
		generate_atmos()
	if(!atmos_gen[gas_string])
		return gas_string
	var/datum/atmosphere/mix = atmos_gen[gas_string]
	return mix.gas_string

/datum/controller/subsystem/air/proc/start_processing_machine(obj/machinery/machine)
	if(machine.atmos_processing)
		return
	machine.atmos_processing = TRUE
	atmos_machinery += machine

/datum/controller/subsystem/air/proc/stop_processing_machine(obj/machinery/machine)
	if(!machine.atmos_processing)
		return
	machine.atmos_processing = FALSE
	atmos_machinery -= machine
	currentrun -= machine

/datum/controller/subsystem/air/proc/pause_z(z_level)
	LAZYADD(paused_z_levels, z_level)
	for (var/turf/T as() in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		T.ImmediateDisableAdjacency()

/datum/controller/subsystem/air/proc/unpause_z(z_level)
	LAZYREMOVE(paused_z_levels, z_level)
	for (var/turf/T as() in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if (isspaceturf(T))
			continue
		T.Initalize_Atmos(0)

#undef SSAIR_PIPENETS
#undef SSAIR_ATMOSMACHINERY
#undef SSAIR_EXCITEDGROUPS
#undef SSAIR_HIGHPRESSURE
#undef SSAIR_HOTSPOTS
#undef SSAIR_REBUILD_PIPENETS
#undef SSAIR_EQUALIZE
#undef SSAIR_ACTIVETURFS
#undef SSAIR_TURF_POST_PROCESS
#undef SSAIR_FINALIZE_TURFS
#undef SSAIR_ATMOSMACHINERY_AIR
