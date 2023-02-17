/datum/ambient_track/space/can_play(client/target)
	// Don't play to observers
	if (isobserver(target.mob))
		return FALSE
	// Ignore people not in space
	var/turf/T = get_turf(target.mob)
	if (!isspaceturf(T) || !istype(T.loc, /area/space))
		return FALSE
	return TRUE

/datum/ambient_track/space/ambispace
	audio_file = 'sound/ambience/ambispace.ogg'

/datum/ambient_track/space/ambispace
	audio_file = 'sound/ambience/ambispace2.ogg'

/datum/ambient_track/space/ambispace
	audio_file = 'sound/ambience/qwerty/constellations.ogg'

/datum/ambient_track/space/ambispace
	audio_file = 'sound/ambience/qwerty/starlight.ogg'

/datum/ambient_track/space/ambispace
	audio_file = 'sound/ambience/qwerty/drifting.ogg'
