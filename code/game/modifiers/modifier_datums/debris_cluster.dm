/datum/round_modifier/debris_cluster
	name = "Debris Cluster"
	desc = "Sensors indicate a large amount of space debris around \
				this sector, making the possibility of a collision \
				much more likely."
	points = -1
	weight = 10

/datum/round_modifier/debris_cluster/post_setup()
	for(var/datum/round_event_control/meteor_wave/event in SSevents.control)
		event.weight = round(event.weight * 1.8)
