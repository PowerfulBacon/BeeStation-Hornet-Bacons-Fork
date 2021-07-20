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

/obj/item/nbodypart/proc/init_body(datum/body/parent_body)
	owner_body = parent_body
	for(var/obj/item/nbodypart/contained_part in contents)
		contained_part.init_body(parent_body)
	//BAM
	owner_body.bodypart_by_slot[bodyslot] = src
