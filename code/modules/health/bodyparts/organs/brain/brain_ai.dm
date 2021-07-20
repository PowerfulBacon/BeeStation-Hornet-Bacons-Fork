
/obj/item/nbodypart/organ/brain/proc/handle_ai(mob/living/L)
	if(L.is_concious())
		handle_automated_action(L)
	if(L.is_concious())
		handle_automated_movement(L)
	if(L.is_concious())
		handle_automated_speech(L, FALSE)

/obj/item/nbodypart/organ/brain/proc/handle_automated_action(mob/living/L)
	return

/obj/item/nbodypart/organ/brain/proc/handle_automated_movement(mob/living/L)
	return

/obj/item/nbodypart/organ/brain/proc/handle_automated_speech(mob/living/L, var/override)
	return
