SUBSYSTEM_DEF(round_manager)
	name = "Round Manager"
	wait = 5
	flags = SS_KEEP_TIMING
	var/time_to_end = 10 MINUTES

/datum/controller/subsystem/round_manager/Initialize(start_timeofday)
	can_fire = FALSE

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

/datum/controller/subsystem/round_manager/proc/activate()
	if (can_fire)
		return
	for (var/atom/movable/screen/player_spawns/ps in GLOB.player_spawn_screens)
		ps.disable()
	for (var/mob/dead/new_player/np in GLOB.new_player_list)
		np.make_me_an_observer()
	can_fire = TRUE
