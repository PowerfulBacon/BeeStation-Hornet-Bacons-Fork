/datum/round_modifier/poor_hygiene
	name = "Poor Hygiene"
	desc = "Failure to follow standard Nanotrasen protocols meant the last \
		shift had to be evacuated early. As a result, hygiene standards \
		may have significantly worsened."
	points = -1
	weight = 8

/datum/round_modifier/poor_hygiene/post_setup()
	for(var/datum/round_event_control/disease_outbreak/event in SSevents.control)
		event.weight = round(event.weight * 2.2)
	for(var/datum/round_event_control/sentient_disease/event in SSevents.control)
		event.weight = round(event.weight * 1.5)
