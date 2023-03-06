/turf/open/indestructible/reebe_void
	name = "void"
	icon_state = "reebemap"
	layer = SPACE_LAYER
	baseturfs = /turf/open/indestructible/reebe_void
	planetary_atmos = TRUE
	bullet_bounce_sound = null //forever falling
	tiled_dirt = FALSE
	flags_1 = NOJAUNT_1

/turf/open/indestructible/reebe_void/Initialize(mapload)
	. = ..()
	icon_state = "reebegame"

/turf/open/indestructible/reebe_void/Enter(atom/movable/AM, atom/old_loc)
	if(!..())
		return FALSE
	else
		if(istype(AM, /obj/structure/window))
			return FALSE
		if(istype(AM, /obj/item/projectile))
			return TRUE
		if((locate(/obj/structure/lattice) in src))
			return TRUE
		return FALSE
