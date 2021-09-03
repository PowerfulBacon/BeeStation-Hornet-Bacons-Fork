/mob/var/obj/effect/lighting_mask_holder/lighting_holder

/mob/Login()
	. = ..()
	lighting_holder = new(loc, src.client)

/mob/Logout()
	QDEL_NULL(lighting_holder)
	. = ..()

/mob/Destroy()
	QDEL_NULL(lighting_holder)
	. = ..()
