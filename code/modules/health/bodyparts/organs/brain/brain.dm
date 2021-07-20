/obj/item/nbodypart/organ/brain
	bodyslot = BP_BRAIN

	//Does the brain have AI?
	var/is_ai_brain = FALSE

/obj/item/nbodypart/organ/brain/Initialize()
	. = ..()
	//TODO Add brain to NPC pool
	//if(is_ai_brain)


/obj/item/nbodypart/organ/brain/human
