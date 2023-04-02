SUBSYSTEM_DEF(round_manager)
	name = "Round Manager"
	wait = 5
	flags = SS_KEEP_TIMING
	var/base_docking_allowed = FALSE
	var/time_to_end = 10 MINUTES

/datum/controller/subsystem/round_manager/Initialize(start_timeofday)
	can_fire = FALSE
	addtimer(CALLBACK(src, PROC_REF(leak_nuke_codes)), 90 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(sudden_death)), 120 MINUTES)

/datum/controller/subsystem/round_manager/fire(resumed)
	time_to_end -= wait
	if (time_to_end < 0)
		SSticker.force_ending = TRUE
		return
	if (time_to_end < 1 MINUTES)
		return
	// Decrease the size of the map
	var/datum/orbital_map/map = SSorbits.orbital_maps[PRIMARY_ORBITAL_MAP]
	map.map_radius -= 50 * (wait / 10)

/datum/controller/subsystem/round_manager/proc/leak_nuke_codes()
	var/code = random_code(5)
	for(var/obj/machinery/nuclearbomb/selfdestruct/SD in GLOB.nuke_list)
		SD.r_code = code
	priority_announce("A recent security vulnerability has been found in all NukeCo nuclear bombs. It was revealed that the nuclear authentication code is [code]. Fortunately, a nuclear authentication disk is still required to arm the nuke; which can be tracked using a pinpointer.", "BERAKING NEWS")
	play_soundtrack_music(/datum/soundtrack_song/bee/future_perception, only_station = SOUNDTRACK_PLAY_ALL)
	base_docking_allowed = TRUE

/datum/controller/subsystem/round_manager/proc/sudden_death()
	if (can_fire)
		return
	for (var/datum/faction/f in SSorbits.lead_faction_instances)
		f.respawns_available = 0
	for (var/atom/movable/screen/player_spawns/ps in GLOB.player_spawn_screens)
		ps.update_player_counts()

/datum/controller/subsystem/round_manager/proc/activate()
	if (can_fire)
		return
	for (var/atom/movable/screen/player_spawns/ps in GLOB.player_spawn_screens)
		ps.disable()
	for (var/mob/dead/new_player/np in GLOB.new_player_list)
		np.make_me_an_observer()
	can_fire = TRUE
