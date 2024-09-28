SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 0.5 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_turfs = 0
	var/cost_groups = 0
	var/cost_highpressure = 0
	var/cost_hotspots = 0
	var/cost_post_process = 0
	var/cost_superconductivity = 0
	var/cost_pipenets = 0
	var/cost_rebuilds = 0
	var/cost_atmos_machinery = 0
	var/cost_equalize = 0
	var/thread_wait_ticks = 0
	var/cur_thread_wait_ticks = 0
	///The last time the subsystem completely processed
	var/last_complete_process = 0

	var/low_pressure_turfs = 0
	var/high_pressure_turfs = 0

	var/num_group_turfs_processed = 0
	var/num_equalize_processed = 0

	var/list/hotspots = list()
	var/list/networks = list()
	var/list/pipenets_needing_rebuilt = list()
	var/list/obj/machinery/atmos_machinery = list()
	var/list/obj/machinery/atmos_air_machinery = list()
	var/list/pipe_init_dirs_cache = list()

	//atmos singletons
	var/list/gas_reactions = list()

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
	// Whether equalization should be enabled at all.
	var/equalize_enabled = FALSE
	// Whether turf-to-turf heat exchanging should be enabled.
	var/heat_enabled = FALSE
	// Max number of times process_turfs will share in a tick.
	var/share_max_steps = 3
	// Excited group processing will try to equalize groups with total pressure difference less than this amount.
	var/excited_group_pressure_goal = 1

	var/list/paused_z_levels	//Paused z-levels will not add turfs to active
	var/list/unpausing_z_levels = list()
	var/list/unpause_processing = list()

	var/list/pausing_z_levels = list()
	var/list/pause_processing = list()

	var/list/atmospheric_regions = list()

/datum/controller/subsystem/air/stat_entry(msg)
	msg += "C:{"
	msg += "HP:[round(cost_highpressure,1)]|"
	msg += "HS:[round(cost_hotspots,1)]|"
	msg += "HE:[round(heat_process_time(),1)]|"
	msg += "SC:[round(cost_superconductivity,1)]|"
	msg += "PN:[round(cost_pipenets,1)]|"
	msg += "AM:[round(cost_atmos_machinery,1)]"
	msg += "} "
	msg += "TC:{"
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
	msg += "GA:[get_amt_gas_mixes()]|"
	msg += "MG:[get_max_gas_mixes()]"
	return ..()

/datum/controller/subsystem/air/Initialize()
	map_loading = FALSE
	setup_allturfs()
	setup_atmos_machinery()
	setup_pipenets()
	gas_reactions = init_gas_reactions()
	build_regions()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/air/proc/extools_update_ssair()

/datum/controller/subsystem/air/proc/thread_running()
	return FALSE

/proc/fix_corrupted_atmos()

/datum/controller/subsystem/air/fire(resumed = 0)

	var/timer = TICK_USAGE_REAL

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
		process_pipenets(resumed)
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY

	// This is only machinery like filters, mixers that don't interact with air
	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = TICK_USAGE_REAL
		process_atmos_machinery(resumed)
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY_AIR

	if(currentpart == SSAIR_ATMOSMACHINERY_AIR)
		timer = TICK_USAGE_REAL
		process_atmos_air_machinery(resumed)
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_HOTSPOTS

	if(currentpart == SSAIR_HOTSPOTS)
		timer = TICK_USAGE_REAL
		process_hotspots(resumed)
		cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0

	currentpart = SSAIR_REBUILD_PIPENETS
	last_complete_process = world.time

/datum/controller/subsystem/air/Recover()
	thread_wait_ticks = SSair.thread_wait_ticks
	cur_thread_wait_ticks = SSair.cur_thread_wait_ticks
	low_pressure_turfs = SSair.low_pressure_turfs
	high_pressure_turfs = SSair.high_pressure_turfs
	num_group_turfs_processed = SSair.num_group_turfs_processed
	num_equalize_processed = SSair.num_equalize_processed
	hotspots = SSair.hotspots
	networks = SSair.networks
	pipenets_needing_rebuilt = SSair.pipenets_needing_rebuilt
	atmos_machinery = SSair.atmos_machinery
	atmos_air_machinery = SSair.atmos_air_machinery
	pipe_init_dirs_cache = SSair.pipe_init_dirs_cache
	gas_reactions = SSair.gas_reactions
	high_pressure_delta = SSair.high_pressure_delta
	currentrun = SSair.currentrun
	currentpart = SSair.currentpart
	map_loading = SSair.map_loading
	log_explosive_decompression = SSair.log_explosive_decompression
	equalize_turf_limit = SSair.equalize_turf_limit
	equalize_hard_turf_limit = SSair.equalize_hard_turf_limit
	equalize_enabled = SSair.equalize_enabled
	heat_enabled = SSair.heat_enabled
	share_max_steps = SSair.share_max_steps
	excited_group_pressure_goal = SSair.excited_group_pressure_goal
	paused_z_levels = SSair.paused_z_levels

/datum/controller/subsystem/air/proc/process_pipenets(resumed = FALSE)
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
	if (!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/current_machinery = currentrun[currentrun.len]
		currentrun.len--
		if(!current_machinery)
			atmos_machinery -= current_machinery
		// Prevents uninitalized atmos machinery from processing.
		if (!(current_machinery.flags_1 & INITIALIZED_1))
			continue
		if(current_machinery.process_atmos() == PROCESS_KILL)
			stop_processing_machine(current_machinery)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_atmos_air_machinery(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = atmos_air_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/current_machinery = currentrun[currentrun.len]
		currentrun.len--
		// Prevents uninitalized atmos machinery from processing.
		if (!(current_machinery.flags_1 & INITIALIZED_1))
			continue
		if(!current_machinery)
			atmos_air_machinery -= current_machinery
		if(current_machinery.process_atmos(seconds) == PROCESS_KILL)
			stop_processing_machine(current_machinery)
		if(MC_TICK_CHECK)
			return

/**
 * Adds a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to start processing. Can be any /obj/machinery.
 */
/datum/controller/subsystem/air/proc/start_processing_machine(obj/machinery/machine)
	if(machine.atmos_processing)
		return
	machine.atmos_processing = TRUE
	if(machine.interacts_with_air)
		atmos_air_machinery += machine
	else
		atmos_machinery += machine

/**
 * Removes a given machine to the processing system for SSAIR_ATMOSMACHINERY processing.
 *
 * Arguments:
 * * machine - The machine to stop processing.
 */
/datum/controller/subsystem/air/proc/stop_processing_machine(obj/machinery/machine)
	if(!machine.atmos_processing)
		return
	machine.atmos_processing = FALSE
	if(machine.interacts_with_air)
		atmos_air_machinery -= machine
	else
		atmos_machinery -= machine

	// If we're currently processing atmos machines, there's a chance this machine is in
	// the currentrun list, which is a cache of atmos_machinery. Remove it from that list
	// as well to prevent processing qdeleted objects in the cache.
	if(currentpart == SSAIR_ATMOSMACHINERY)
		currentrun -= machine
	if(machine.interacts_with_air && currentpart == SSAIR_ATMOSMACHINERY_AIR)
		currentrun -= machine

/datum/controller/subsystem/air/proc/process_turf_heat()

/datum/controller/subsystem/air/proc/process_hotspots(resumed = FALSE)
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

/datum/controller/subsystem/air/proc/process_turf_equalize(resumed = 0)
	if(process_turf_equalize_auxtools(resumed,MC_TICK_REMAINING_MS))
		pause()
	/*
	//cache for sanic speed
	var/fire_count = times_fired
	if (!resumed)
		src.currentrun = active_turfs.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/open/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			T.equalize_pressure_in_zone(fire_count)
			//equalize_pressure_in_zone(T, fire_count)
		if (MC_TICK_CHECK)
			return
	*/

/datum/controller/subsystem/air/proc/process_turfs(resumed = 0)
	if(process_turfs_auxtools(resumed,MC_TICK_REMAINING_MS))
		pause()
	/*
	//cache for sanic speed
	var/fire_count = times_fired
	if (!resumed)
		src.currentrun = active_turfs.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/open/T = currentrun[currentrun.len]
		currentrun.len--
		if (T)
			T.process_cell(fire_count)
		if (MC_TICK_CHECK)
			return
	*/

/datum/controller/subsystem/air/proc/process_excited_groups(resumed = 0)
	if(process_excited_groups_auxtools(resumed,MC_TICK_REMAINING_MS))
		pause()

/datum/controller/subsystem/air/proc/finish_turf_processing(resumed = 0)
	if(finish_turf_processing_auxtools(MC_TICK_REMAINING_MS))
		pause()

/datum/controller/subsystem/air/proc/post_process_turfs(resumed = 0)
	if(post_process_turfs_auxtools(resumed,MC_TICK_REMAINING_MS))
		pause()

/datum/controller/subsystem/air/proc/finish_turf_processing_auxtools()
/datum/controller/subsystem/air/proc/process_turfs_auxtools()
/datum/controller/subsystem/air/proc/post_process_turfs_auxtools()
/datum/controller/subsystem/air/proc/process_turf_equalize_auxtools()
/datum/controller/subsystem/air/proc/process_excited_groups_auxtools()
/datum/controller/subsystem/air/proc/get_amt_gas_mixes()
/datum/controller/subsystem/air/proc/get_max_gas_mixes()
/datum/controller/subsystem/air/proc/turf_process_time()
/datum/controller/subsystem/air/proc/heat_process_time()

/datum/controller/subsystem/air/StartLoadingMap()
	map_loading = TRUE

/datum/controller/subsystem/air/StopLoadingMap()
	map_loading = FALSE

/datum/controller/subsystem/air/proc/pause_z(z_level)
	LAZYADD(paused_z_levels, z_level)
	unpausing_z_levels -= z_level
	pausing_z_levels |= z_level

/datum/controller/subsystem/air/proc/unpause_z(z_level)
	pausing_z_levels -= z_level
	unpausing_z_levels |= z_level
	LAZYREMOVE(paused_z_levels, z_level)

/datum/controller/subsystem/air/proc/setup_allturfs()
	var/times_fired = ++src.times_fired

	for(var/turf/T as anything in ALL_TURFS())
		if (!T.init_air)
			continue
		T.Initalize_Atmos(times_fired)

/datum/controller/subsystem/air/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery + atmos_air_machinery)
		AM.atmosinit()

//this can't be done with setup_atmos_machinery() because
//	all atmos machinery has to initalize before the first
//	pipenet can be built.
/datum/controller/subsystem/air/proc/setup_pipenets()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery + atmos_air_machinery)
		AM.build_network()

/datum/controller/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	if(!initialized) // yogs - fixes randomized bars
		return // yogs
	var/obj/machinery/atmospherics/AM
	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
		AM.atmosinit()
		CHECK_TICK

	for(var/A in 1 to atmos_machines.len)
		AM = atmos_machines[A]
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

/**
 * BACONMOS
 */

/turf/var/_region_built = FALSE
/turf/var/_temp_group = 0
/turf/var/datum/atmospheric_region/atmospheric_region = null

// This is going to be an expensive process that requires optimisation
// Since its in init times, at this point I don't really care if there are some micro ops
/datum/controller/subsystem/air/proc/build_regions()
	// Step 1: Group everything into regions based on connectivity
	var/list/regions = list()
	for (var/z in 1 to world.maxz)
		for (var/x in 1 to world.maxx)
			for (var/y in 1 to world.maxy)
				var/turf/T = locate(x, y, z)
				if (T._region_built || isspaceturf(T) || !T.CanAtmosPass(T))
					continue
				var/datum/temp_region/current_region = new()
				current_region.group_id = length(regions) + 1
				var/list/to_search = list(T)
				while (length(to_search))
					var/turf/searched = to_search[to_search.len]
					searched._region_built = TRUE
					to_search.len --
					current_region.turfs += searched
					searched._temp_group = current_region.group_id
					current_region.min_x = min(current_region.min_x, searched.x)
					current_region.min_y = min(current_region.min_y, searched.y)
					current_region.max_x = max(current_region.max_x, searched.x)
					current_region.max_y = max(current_region.max_y, searched.y)
					for (var/turf/adjacent in searched.GetAtmosAdjacentTurfs())
						if (adjacent._region_built || isspaceturf(adjacent))
							continue
						adjacent._region_built = TRUE
						to_search += adjacent
				regions += current_region
	to_chat(world, "[length(regions)] regions identified.")
	var/list/subregions = list()
	// Step 2: Divide each region into quad regions
	for (var/datum/temp_region/region in regions)
		while (length(region.turfs))
			var/datum/atmospheric_region/atmos_zone = new()
			var/turf/origin = region.turfs[1]
			region.turfs -= origin
			atmos_zone.turfs += origin
			origin._temp_group = 0
			origin.atmospheric_region = atmos_zone
			var/minx = origin.x
			var/miny = origin.y
			var/maxx = origin.x
			var/maxy = origin.y
			// Greedy X expansion (Left)
			while (maxx + 1 <= world.maxx)
				var/turf/next = locate(maxx + 1, origin.y, origin.z)
				if (next._temp_group != region.group_id)
					break
				maxx = maxx + 1
				region.turfs -= next
				atmos_zone.turfs += next
				next.atmospheric_region = atmos_zone
				next._temp_group = 0
			// Greedy X expansion (Right)
			while (minx - 1 >= 1)
				var/turf/next = locate(minx - 1, origin.y, origin.z)
				if (next._temp_group != region.group_id)
					break
				minx = minx - 1
				region.turfs -= next
				atmos_zone.turfs += next
				next.atmospheric_region = atmos_zone
				next._temp_group = 0
			// Greedy Y expansion (Up)
			while (maxy + 1 <= world.maxy)
				// Ensure that the entire row of turfs is unblocked
				var/blocked = FALSE
				var/list/row = list()
				for (var/x in minx to maxx)
					var/turf/test = locate(x, maxy + 1, origin.z)
					if (test._temp_group != region.group_id)
						blocked = TRUE
						break
					row += test
				if (blocked)
					break
				maxy = maxy + 1
				for (var/turf/T in row)
					region.turfs -= T
					atmos_zone.turfs += T
					T.atmospheric_region = atmos_zone
					T._temp_group = 0
			// Greedy Y expansion (Down)
			while (miny - 1 >= 1)
				// Ensure that the entire row of turfs is unblocked
				var/blocked = FALSE
				var/list/row = list()
				for (var/x in minx to maxx)
					var/turf/test = locate(x, miny - 1, origin.z)
					if (test._temp_group != region.group_id)
						blocked = TRUE
						break
					row += test
				if (blocked)
					break
				miny = miny - 1
				for (var/turf/T in row)
					region.turfs -= T
					atmos_zone.turfs += T
					T.atmospheric_region = atmos_zone
					T._temp_group = 0
			subregions += atmos_zone
	to_chat(world, "Atmos initialised with [length(subregions)] atmospheric regions.")
	for (var/datum/atmospheric_region/region in subregions)
		region.setup()
	atmospheric_regions = subregions

/datum/temp_region
	var/group_id
	var/list/turfs = list()
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY

#undef SSAIR_PIPENETS
#undef SSAIR_ATMOSMACHINERY
#undef SSAIR_HOTSPOTS
#undef SSAIR_ATMOSMACHINERY_AIR
