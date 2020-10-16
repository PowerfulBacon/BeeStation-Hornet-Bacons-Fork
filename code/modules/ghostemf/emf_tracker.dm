/datum/component/emf_tracker
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/tracked_emfs

/datum/component/emf_tracker/Initialize(...)
	. = ..()
	tracked_emf = list()
	RegisterSignal(parent, COMSIG_ATOM_EMF_REGISTER, .proc/track_emf)

/datum/component/emf_tracker/proc/track_emf(tracked)
	tracked_emfs += tracked

/datum/component/emf_tracker/proc/get_emf_reading()
	var/max_reading = 0
	for(var/datum/emf_source/source as() in tracked_emfs)
		max_reading = max(source.power, max_reading)
	return max_reading
