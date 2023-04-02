GLOBAL_LIST_EMPTY(player_spawn_screens)

/atom/movable/screen/player_spawns
	maptext_width = 460
	maptext_x = -230
	maptext = ""
	var/faded = FALSE

/atom/movable/screen/player_spawns/New(loc, ...)
	. = ..()
	GLOB.player_spawn_screens += src
	if (SSround_manager.can_fire && SSround_manager.initialized)
		display_endgame_text()
	else
		update_player_counts()

/atom/movable/screen/player_spawns/Destroy()
	GLOB.player_spawn_screens -= src
	if (datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSprocessing, src)
	return ..()

/atom/movable/screen/player_spawns/proc/update_player_counts()
	if (faded)
		return
	var/datum/faction/nanotrasen = SSorbits.get_lead_faction(/datum/faction/nanotrasen)
	if (!nanotrasen)
		return
	maptext = "<span class='maptext'><span class='big'><font color='#2681a5'>Nanotrasen: [nanotrasen.respawns_available] spawns</font></span></span>"
	transform=matrix()*1.1
	animate(src, transform=matrix(), time=5)

/atom/movable/screen/player_spawns/proc/disable()
	faded = TRUE
	animate(src, 3 SECONDS, alpha=0)
	addtimer(CALLBACK(src, PROC_REF(display_endgame_text)))

/atom/movable/screen/player_spawns/proc/display_endgame_text()
	animate(src, 2 SECONDS, alpha=255)
	maptext = "<span class='maptext big center'>THE FOG IS COMING.\nFLY TO THE CENTER OF THE MAP TO SURVIVE.</span>"
	START_PROCESSING(SSprocessing, src)

/atom/movable/screen/player_spawns/process(delta_time)
	maptext = "<span class='maptext big center'>THE FOG IS COMING.\nFLY TO THE CENTER OF THE MAP TO SURVIVE.\nRound end: [time2text(SSround_manager.time_to_end, "mm:ss")]</span>"

/atom/movable/screen/player_spawns/syndicate/update_player_counts()
	if (faded)
		return
	var/datum/faction/syndicate = SSorbits.get_lead_faction(/datum/faction/syndicate)
	if (!syndicate)
		return
	maptext = "<span class='maptext'><span class='big'><span class='right'><font color='#8f4a4b'>Syndicate: [syndicate.respawns_available] spawns</font></span></span></span>"
	transform=matrix()*1.1
	animate(src, transform=matrix(), time=5)

/atom/movable/screen/player_spawns/syndicate/display_endgame_text()
	alpha = 0
	faded = TRUE
