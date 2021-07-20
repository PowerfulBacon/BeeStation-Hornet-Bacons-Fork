/obj/item/nbodypart/skull
	bodyslot = BP_SKULL

/obj/item/nbodypart/skull/human/Initialize()
	. = ..()
	held_bodyparts = list(
		BP_BRAIN = new /obj/item/nbodypart/organ/brain/human(src),
	)
