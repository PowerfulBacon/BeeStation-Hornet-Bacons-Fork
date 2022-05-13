/datum/bodypart/body
	//Give this some health value
	//Body is abstract though and cannot be destroyed
	max_health = 100
	//Allow this to be in the root slot
	allowed_slots = list(SLOT_ROOT)
	//All bodyparts that are contained within this one
	//Associative slot -> bodypart
	contained_parts = list()
