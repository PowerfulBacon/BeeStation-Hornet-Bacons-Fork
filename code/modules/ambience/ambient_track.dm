/datum/ambient_track
	var/audio_file
	// Minimum time between playing
	var/cooldown = 20 MINUTES

/// Can this ambience track be played?
/datum/ambient_track/proc/can_play(client/target)
	return FALSE
