/obj/item/nbodypart/head
	bodyslot = BP_HEAD

/obj/item/nbodypart/head/human/Initialize()
	. = ..()
	held_bodyparts = list(
		BP_JAW = new /obj/item/nbodypart/jaw/human(src),
		BP_SKULL = new /obj/item/nbodypart/skull/human(src),
/*		BP_NECK,
		BP_NOSE,
		BP_LEFT_EYE,
		BP_RIGHT_EYE,
		BP_LEFT_EAR,
		BP_RIGHT_EAR*/
	)