/obj/item/nbodypart/skull
	bodyslot = BP_SKULL

//Organic generic skull
/obj/item/nbodypart/skull/organic/initialize_contents()
	held_bodyparts = list(
		BP_BRAIN = BP_EMPTY,	//Brain gets created by the body
	)
