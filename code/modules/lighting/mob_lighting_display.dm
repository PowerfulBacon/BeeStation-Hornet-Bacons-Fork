/mob/var/obj/effect/lighting_mask_holder/lighting_holder

//Registers a lighting holder to the client
/mob/Login()
	. = ..()
	if(client)
		lighting_holder = new(loc, client)

/mob/Logout()
	QDEL_NULL(lighting_holder)
	. = ..()

/mob/Destroy()
	QDEL_NULL(lighting_holder)
	. = ..()
