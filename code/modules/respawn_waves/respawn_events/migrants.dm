/datum/respawn_event/migrants

/datum/respawn_event/migrants/generate_announcement_text(list/spawned_mobs)
	return "Your neighbourting station [new_station_name()] was recently forced to evacuate. Please support and welcome any refugees into your station, so that they may be picked up by the escape shuttle at the end of the shift."

/datum/respawn_event/migrants/prepare(list/candidates)
	return SSshuttle.load_template()
