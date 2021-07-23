/obj/item/nbodypart/head
	bodyslot = BP_HEAD
	bodypart_flags = BP_FLAG_CRITICAL | BP_FLAG_REMOVABLE
	maxhealth = 60

/obj/item/nbodypart/head/organic/initialize_contents()
	held_bodyparts = list(
		BP_JAW = new /obj/item/nbodypart/jaw/organic(src),
		BP_SKULL = new /obj/item/nbodypart/skull/organic(src),
		BP_LEFT_EYE = new /obj/item/nbodypart/organ/eye/left(src),
		BP_RIGHT_EYE = new /obj/item/nbodypart/organ/eye/right(src)
/*		BP_NECK,
		BP_NOSE,
		BP_LEFT_EYE,
		BP_RIGHT_EYE,
		BP_LEFT_EAR,
		BP_RIGHT_EAR*/
	)
