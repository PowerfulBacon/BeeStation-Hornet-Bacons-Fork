/client/var/atom/movable/lighting_mask_holder/lighting_holder

/client/New()
	. = ..()
	lighting_holder = new(mob?.loc)
	lighting_holder.assign(src)

/client/Destroy()
	QDEL_NULL(lighting_holder)
	. = ..()
