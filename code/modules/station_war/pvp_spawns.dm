/obj/effect/landmark/pvp_spawn
	name = "nukeop"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "snukeop_spawn"
	layer = MOB_LAYER

/obj/effect/landmark/pvp_spawn/Initialize(mapload)
	..()
	GLOB.servant_spawns += loc
	return INITIALIZE_HINT_QDEL
