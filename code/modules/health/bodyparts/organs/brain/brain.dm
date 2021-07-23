/obj/item/nbodypart/organ/brain
	name = "Brain"
	bodyslot = BP_BRAIN
	maxhealth = 15
	bodypart_flags = BP_FLAG_CRITICAL | BP_FLAG_REMOVABLE

	//100% of conciousness is in the brain.
	//Lose 70% of brain efficiency, lose 70% of conciousness.
	conciousness_factor = 100

	//Does the brain have AI?
	var/is_ai_brain = FALSE

	var/pre_removal_state = AI_ON
	var/AIStatus = AI_ON //The Status of our AI, can be changed via toggle_ai(togglestatus) to AI_ON (On, usual processing), AI_IDLE (Will not process, but will return to AI_ON if an enemy comes near), AI_OFF (Off, Not processing ever), AI_Z_OFF (Temporarily off due to nonpresence of players)
	var/can_have_ai = TRUE //once we have become sentient, we can never go back
	var/shouldwakeup = FALSE //convenience var for forcibly waking up an idling AI on next check.

/obj/item/nbodypart/organ/brain/Initialize()
	. = ..()
	//TODO Add brain to NPC pool
	if(is_ai_brain)
		GLOB.npc_brains[AIStatus] += src

/obj/item/nbodypart/organ/brain/Destroy()
	if(is_ai_brain)
		GLOB.npc_brains[AIStatus] -= src
		if (SSnpcpool.state == SS_PAUSED && LAZYLEN(SSnpcpool.currentrun))
			SSnpcpool.currentrun -= src
		var/turf/T = get_turf(src)
		if (T && AIStatus == AI_Z_OFF)
			SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= owner_body?.owner
	. = ..()

/obj/item/nbodypart/organ/brain/removed()
	if(is_ai_brain)
		//Disable AI
		pre_removal_state = AIStatus
		toggle_ai(AI_OFF)
	. = ..()

/obj/item/nbodypart/organ/brain/human
