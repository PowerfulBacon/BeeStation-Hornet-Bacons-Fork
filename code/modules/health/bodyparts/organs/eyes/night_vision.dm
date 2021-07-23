//======================
// Robotic Night Vision
//======================

/obj/item/nbodypart/organ/eye/robotic/night
	name = "night-vision optical sensory unit"
	desc = "A highly advanced optical sensory unity shaped like a human eye. It has an in-built flashlight that illuminates \
		the surroundings with a wavelength of light not visible to regular eyes. The sensors installed quickly adjust to be adapted \
		for the environments light level, however not quick enough for intense flashes of light which are even more blinding for these sensors."
	bodyslot = null
	maxhealth = 12

	eye_color = "#15ff00"

	requires_compatability = TRUE
	parent_typepath = /obj/item/nbodypart/organ/eye/robotic/night

	//1 eye does half the seeing
	sight_factor = 50

	//Sight stuff
	flash_protect = -1
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/nbodypart/organ/eye/robotic/night/left
	name = "left night-vision optical sensory unit"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/robotic/night/right
	name = "right night-vision optical sensory unit"
	bodyslot = BP_RIGHT_EYE

//======================
// Organic Night Vision
//======================

/obj/item/nbodypart/organ/eye/night
	name = "shadow eye"
	desc = "An eyeball with increased perception in low-light conditions."
	bodyslot = null
	maxhealth = 10

	parent_typepath = /obj/item/nbodypart/organ/eye/night

	actions_types = list(/datum/action/item_action/organ_action/use)

	//1 eye does half the seeing
	sight_factor = 50

	//Sight stuff
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/nbodypart/organ/eye/night/ui_action_click(mob/user, actiontype)
	sight_flags = initial(sight_flags)
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			sight_flags &= ~SEE_BLACKNESS
	owner_body.owner.update_sight()

/obj/item/nbodypart/organ/eye/night/left
	name = "left shadow eye"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/night/right
	name = "right shadow eye"
	bodyslot = BP_RIGHT_EYE

/obj/item/nbodypart/organ/eye/night/alien
	name = "alien eye"
	desc = "It turned out they had them after all!"
	sight_flags = SEE_MOBS

/obj/item/nbodypart/organ/eye/night/alien/left
	name = "left alien eye"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/night/alien/right
	name = "right alien eye"
	bodyslot = BP_RIGHT_EYE

/obj/item/nbodypart/organ/eye/night/zombie
	name = "undead eye"
	desc = "Somewhat counterintuitively, these half-rotten eyes actually have superior vision to those of a living human."

	bodypart_flags = BP_FLAG_PROCESSING

//Rot while not in a zombie
/obj/item/nbodypart/organ/eye/night/zombie/life(datum/body/parentbody, mob/living/L)
	//Unrot in a zombie body
	if(istype(parentbody, /datum/body/humanlike/zombie))
		heal_injury(/datum/injury/rot, 0.5)
		return
	//Rot in a normal body
	apply_injury(/datum/injury/rot, 0.1)

/obj/item/nbodypart/organ/eye/night/zombie/left
	name = "left undead eye"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/night/zombie/right
	name = "right undead eye"
	bodyslot = BP_RIGHT_EYE

/obj/item/nbodypart/organ/eye/night/nightmare
	name = "burning red eye"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon_state = "burning_eyes"

	parent_typepath = /obj/item/nbodypart/organ/eye/night/nightmare
	requires_compatability = TRUE

/obj/item/nbodypart/organ/eye/night/nightmare/left
	name = "left nightmare eye"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/night/nightmare/right
	name = "right nightmare eye"
	bodyslot = BP_RIGHT_EYE

/obj/item/nbodypart/organ/eye/night/mushroom
	name = "fung-eye"
	desc = "While on the outside they look inert and dead, the eyes of mushroom people are actually very advanced."

/obj/item/nbodypart/organ/eye/night/mushroom/left
	name = "left fung-eye"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/night/mushroom/right
	name = "right fung-eye"
	bodyslot = BP_RIGHT_EYE
