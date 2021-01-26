SUBSYSTEM_DEF(turf_setter)
	name = "Turf Setter"
	init_order = INIT_ORDER_WORLD_TURFS
	flags = SS_NO_FIRE

/datum/controller/subsystem/weather/Initialize(start_timeofday)
	to_chat(world, "<span class='boldannounce'>Finalizing base turfs.</span>")
	for(var/turf/T as() in block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz)))
		T.setup_world_turf()
	to_chat(world, "<span class='boldannounce'>World turfs setup, loading complete.</span>")
	return ..()
