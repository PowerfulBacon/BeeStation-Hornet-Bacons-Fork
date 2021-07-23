/obj/item/nbodypart/organ/eye/god
	name = "eye of God"
	desc = "A strange eye, said to have been torn from an omniscient creature that used to roam the wastes."
	bodyslot = null
	maxhealth = 30

	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "godeye"
	item_state = "godeye"

	//You cannot remove the eye of god.
	bodypart_flags = NONE

	parent_typepath = /obj/item/nbodypart/organ/eye/god

	//+40% vision when equipped.
	sight_factor = 90

	//Sight stuff
	sight_flags = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_in_dark = 8
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/nbodypart/organ/eye/god/insert(datum/body/parentbody, mob/living/L, obj/item/nbodypart/parent_part)
	. = ..()
	if(.)
		to_chat(L, "<span class='userdanger'>You feel a sudden shock through your entire body as [src] embeds itself deep into your brain!</span>")
		L.emote("scream")

/obj/item/nbodypart/organ/eye/god/attack_self(mob/living/user)
	//Try the left eye.
	bodyslot = BP_LEFT_EYE
	name = "left eye of God"
	if(user.body.remove_part_in_slot(BP_LEFT_EYE))
		insert(user.body, user)
		return
	//try the right eye instead.
	bodyslot = BP_RIGHT_EYE
	name = "right eye of God"
	if(user.body.remove_part_in_slot(BP_RIGHT_EYE))
		insert(user.body, user)
		return
