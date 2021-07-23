/obj/item/nbodypart/organ/eye
	name = "Eye"
	desc = "Eye see you."
	bodyslot = null
	maxhealth = 10
	bodypart_flags = BP_FLAG_REMOVABLE

	icon_state = "eyeballs"

	//1 eye does half the seeing
	sight_factor = 50

	//Eye is not functioning due to compatability issue.
	var/non_functioning = FALSE

	//Parent typepath
	var/parent_typepath = /obj/item/nbodypart/organ/eye
	var/requires_compatability = FALSE	//If true, both eyes must be the same parent type or the effects won't be applied.

	//Warning for non compatability
	var/eye_warning = "<span class='warning robot'>Caution: Optical sensory unit offline due to incompatability with other eye. Please \
		make sure optical unit is installed into both eye sockets for normal operation.</span>"

	//Sight stuff
	var/sight_flags = 0
	var/see_in_dark = 2
	var/tint = 0
	var/eye_color = ""
	var/eye_icon_state = "eyes"
	var/old_eye_color = "fff"
	var/flash_protect = 0
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha
	var/no_glasses

/obj/item/nbodypart/organ/eye/insert(datum/body/parentbody, mob/living/L, obj/item/nbodypart/parent_part)
	. = ..()
	//Check compatability
	check_compatibility(L)

/obj/item/nbodypart/organ/eye/proc/check_compatibility(mob/living/L)
	var/valid = TRUE
	//Check validity
	if(!valid)
		non_functioning = TRUE
	else
		non_functioning = FALSE
	//Apply eye stats
	if(!non_functioning)
		if(ishuman(L))
			var/mob/living/carbon/human/HMN = L
			old_eye_color = HMN.eye_color
			if(eye_color)
				HMN.eye_color = eye_color
				HMN.regenerate_icons()
			else
				eye_color = HMN.eye_color
			if(HMN.has_dna())
				HMN.dna.species.handle_body(L)
		L.update_tint()
		L.update_sight()
	else
		to_chat(L, eye_warning)

/obj/item/nbodypart/organ/eye/left
	name = "Left Eye"
	desc = "I see you left this lying around."
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/right
	name = "Right Eye"
	desc = "Can you see this all right?"
	bodyslot = BP_RIGHT_EYE

/obj/item/nbodypart/organ/eye/nvtrait
	name = "Eye"
	desc = "A regular human eye with its pupils more dilated than usual."
	lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT

/obj/item/nbodypart/organ/eye/nvtrait/left
	name = "left eye"
	bodyslot = BP_LEFT_EYE

/obj/item/nbodypart/organ/eye/nvtrait/right
	name = "right eye"
	bodyslot = BP_RIGHT_EYE
