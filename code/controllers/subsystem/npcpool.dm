SUBSYSTEM_DEF(npcpool)
	name = "NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()

/datum/controller/subsystem/npcpool/stat_entry()
	var/list/activelist = GLOB.simple_animals[AI_ON]
	. = ..("NPCS:[activelist.len]")

/datum/controller/subsystem/npcpool/fire(resumed = FALSE)

	if (!resumed)
		var/list/activelist = GLOB.simple_animals[AI_ON]
		src.currentrun = activelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/mob/living/simple_animal/SA = currentrun[currentrun.len]
		--currentrun.len

		if(!SA)
			stack_trace("Null entry found at GLOB.simple_animals\[AI_ON\]. Null entries will be purged. Yell at coderbus. Subsystem will try to continue.")
			removeNullsFromList(GLOB.simple_animals[AI_ON])
			continue

		if(!SA.ckey && !SA.notransform)
			//TODO get brain
			if(SA.is_alive())
				SA.handle_automated_movement()
			if(SA.is_alive())
				SA.handle_automated_action()
			if(SA.is_alive())
				SA.handle_automated_speech()
		if(SA.special_process)
			SA.process()
		if (MC_TICK_CHECK)
			return
