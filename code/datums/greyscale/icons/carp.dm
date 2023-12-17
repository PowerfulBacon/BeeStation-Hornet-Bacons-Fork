/datum/greyscale_icon/carp/generate()
	set_icon('icons/mob/carp.dmi')
	add_layer(1, "base", BLEND_OVERLAY)
	add_fixed_layer("base_mouth", BLEND_OVERLAY)

/datum/greyscale_icon/carp/dead/generate()
	set_icon('icons/mob/carp.dmi')
	add_layer(1, "base_dead", BLEND_OVERLAY)
	add_fixed_layer("base_dead_mouth", BLEND_OVERLAY)

/datum/greyscale_icon/carp/disk/generate()
	..()
	add_layer(1, "disk_mouth", BLEND_OVERLAY)
