/obj/item/nbodypart
	//The body that we are inside of. (If we are inside of a body)
	var/datum/body/owner_body

	//Bodyslot key
	var/bodyslot

	//Any bodyparts we hold
	//ASSOC
	//Key: bodyslot ID
	//Value: Bodypart object
	var/list/held_bodyparts = list()

/obj/item/nbodypart/Initialize()
	. = ..()
	initialize_contents()

/obj/item/nbodypart/proc/initialize_contents()
	return

/obj/item/nbodypart/proc/init_body(datum/body/parent_body, obj/item/nbodypart/parent_part)
	owner_body = parent_body
	for(var/obj/item/nbodypart/contained_part in contents)
		contained_part.init_body(parent_body, parent_part)
	//BAM
	owner_body.bodypart_slot_holders[bodyslot] = parent_part?.bodyslot
	owner_body.bodypart_by_slot[bodyslot] = src
	//Update any nulls in held bodyparts.
	for(var/bodypart_held in held_bodyparts)
		var/thing = held_bodyparts[bodypart_held]
		if(thing == BP_EMPTY)
			owner_body.bodypart_slot_holders[bodypart_held] = bodyslot
			owner_body.bodypart_by_slot[bodypart_held] = BP_EMPTY

/obj/item/nbodypart/proc/removed()
	owner_body.bodypart_by_slot[bodyslot] = BP_EMPTY
	owner_body = null
