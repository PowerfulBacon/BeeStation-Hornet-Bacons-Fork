/*
 * Jumpsuit Icons
 */

/datum/greyscale_icon/jumpsuit/generate()
	set_icon('icons/obj/clothing/uniforms.dmi')
	add_layer(1, "jumpsuit", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_accessories", BLEND_OVERLAY)

/datum/greyscale_icon/jumpskirt/generate()
	set_icon('icons/obj/clothing/uniforms.dmi')
	add_layer(1, "jumpskirt", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_accessories", BLEND_OVERLAY)

/*
 * Jumpsuit Worn Icons
 */

/datum/greyscale_icon/jumpsuit_worn/generate()
	set_icon('icons/obj/clothing/uniforms.dmi')
	add_layer(1, "jumpsuit", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_accessories", BLEND_OVERLAY)

/datum/greyscale_icon/jumpsuit_worn/down/generate()
	set_icon('icons/mob/clothing/uniform.dmi')
	add_layer(1, "jumpsuit_d", BLEND_OVERLAY)

/datum/greyscale_icon/jumpskirt_worn/generate()
	set_icon('icons/mob/clothing/uniform.dmi')
	add_layer(1, "jumpskirt", BLEND_OVERLAY)
	add_fixed_layer("jumpskirt_accessories", BLEND_OVERLAY)

/datum/greyscale_icon/jumpskirt_worn/down/generate()
	set_icon('icons/mob/clothing/uniforms.dmi')
	add_layer(1, "jumpskirt_d", BLEND_OVERLAY)

/*
 * Jumpsuit Held Icons
 */

/datum/greyscale_icon/jumpsuit/in_hand/generate()
	add_layer(1, "jumpsuit", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_accessories", BLEND_OVERLAY)

/datum/greyscale_icon/jumpsuit/in_hand/left/generate()
	set_icon('icons/mob/inhands/clothing_lefthand.dmi')
	..()

/datum/greyscale_icon/jumpsuit/in_hand/right/generate()
	set_icon('icons/mob/inhands/clothing_righthand.dmi')
	..()


/*
 * Jumpsuit Prison Icons
 */

/datum/greyscale_icon/jumpsuit/prison/generate()
	set_icon('icons/obj/clothing/uniforms.dmi')
	add_layer(1, "jumpsuit", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_prison", BLEND_OVERLAY)

/datum/greyscale_icon/jumpskirt/prison/generate()
	set_icon('icons/obj/clothing/uniforms.dmi')
	add_layer(1, "jumpskirt", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_prison", BLEND_OVERLAY)

/*
 * Jumpsuit Prison Worn Icons
 */

/datum/greyscale_icon/jumpsuit/prison/worn/generate()
	set_icon('icons/mob/clothing/uniform.dmi')
	add_layer(1, "jumpsuit", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_prison", BLEND_OVERLAY)

/datum/greyscale_icon/jumpskirt/prison/worn/generate()
	set_icon('icons/mob/clothing/uniform.dmi')
	add_layer(1, "jumpskirt", BLEND_OVERLAY)
	add_fixed_layer("jumpskirt_prison", BLEND_OVERLAY)

/datum/greyscale_icon/jumpsuit/prison/worn/down/generate()
	set_icon('icons/mob/clothing/uniform.dmi')
	add_layer(1, "jumpsuit_d", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_d_prison", BLEND_OVERLAY)

/datum/greyscale_icon/jumpskirt/prison/worn/down/generate()
	set_icon('icons/mob/clothing/uniform.dmi')
	add_layer(1, "jumpskirt_d", BLEND_OVERLAY)
	add_fixed_layer("jumpskirt_d_prison", BLEND_OVERLAY)

/*
 * Jumpsuit Prison Held Icons
 */

/datum/greyscale_icon/jumpsuit/prison/in_hand/generate()
	add_layer(1, "jumpsuit", BLEND_OVERLAY)
	add_fixed_layer("jumpsuit_prison", BLEND_OVERLAY)

/datum/greyscale_icon/jumpsuit/prison/in_hand/left/generate()
	set_icon('icons/mob/inhands/clothing_lefthand.dmi')
	..()

/datum/greyscale_icon/jumpsuit/prison/in_hand/right/generate()
	set_icon('icons/mob/inhands/clothing_righthand.dmi')
	..()

