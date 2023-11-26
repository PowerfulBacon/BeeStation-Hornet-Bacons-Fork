
/atom/movable/screen/respawn_timer
	screen_loc = "CENTER:16,TOP:-12"
	plane = ABOVE_HUD_PLANE
	maptext_width = 460
	maptext_x = -230
	maptext = ""
	alpha = 0
	var/visible = FALSE

/atom/movable/screen/respawn_timer/New(loc, ...)
	. = ..()
	START_PROCESSING(SSrespawn_events, src)
	// Fade in immediately
	if (SSticker.current_state == GAME_STATE_PLAYING)
		fade_in()

/atom/movable/screen/respawn_timer/Destroy()
	STOP_PROCESSING(SSrespawn_events, src)
	. = ..()

/atom/movable/screen/respawn_timer/proc/fade_in()
	if (visible)
		return
	animate(src, time = 5 SECONDS, alpha=255)
	visible = TRUE

/atom/movable/screen/respawn_timer/proc/fade_out()
	if (!visible)
		return
	animate(src, time = 5 SECONDS, alpha=0)
	visible = FALSE

/atom/movable/screen/respawn_timer/process(delta_time)
	// Invalid game state
	if (SSticker.current_state != GAME_STATE_PLAYING)
		if (visible)
			fade_out()
		return
	// We were a ghost from before roundstart and the timer wasn't showing
	if (!visible && SSticker.current_state == GAME_STATE_PLAYING)
		fade_in()
	maptext = "<span class='maptext'><span class='big center ghostalert'>Respawn in: [time2text(SSrespawn_events.respawn_event_time - world.time, "mm:ss")]</span></span>"
