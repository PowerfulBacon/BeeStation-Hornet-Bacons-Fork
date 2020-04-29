/datum/round_modifier/debris_cluster
	name = "Debris Cluster" //The name of the modifier
	desc = "Sensors indicate a large amount of space debris around \
				this sector, making the possibility of a collision \
				much more likely." //The description that comes up on comms console
	points = -1 //The overall chaos / danger of event. -5 would be terrible, 5 would be amazing
	weight = 10

/datum/round_modifier/debris_cluster/post_setup()
	for(var/datum/round_event_control/meteor_wave/event in SSevents.control)
		event.weight = round(event.weight * 1.8)
