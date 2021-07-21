SUBSYSTEM_DEF(npcpool)
	name = "NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()

/datum/controller/subsystem/npcpool/stat_entry()
	var/list/activelist = GLOB.npc_brains[AI_ON]
	. = ..("NPCS:[activelist.len]")

/datum/controller/subsystem/npcpool/fire(resumed = FALSE)

	if (!resumed)
		var/list/activelist = GLOB.npc_brains[AI_ON]
		src.currentrun = activelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/item/nbodypart/organ/brain/brain = currentrun[currentrun.len]
		var/mob/living/brain_mob = brain.owner_body?.owner
		--currentrun.len

		if(!brain)
			stack_trace("Null entry found at GLOB.npc_brains\[AI_ON\]. Null entries will be purged. Yell at coderbus. Subsystem will try to continue.")
			removeNullsFromList(GLOB.npc_brains[AI_ON])
			continue

		if(!brain_mob)
			stack_trace("Brain with no attached mob found on GLOB.npc_brains\[AI_ON\].")
			GLOB.npc_brains[AI_ON] -= brain
			continue

		if(!brain_mob.ckey && !brain_mob.notransform)
			INVOKE_ASYNC(brain, /obj/item/nbodypart/organ/brain.proc/handle_ai, brain_mob)
		if(brain_mob.special_process)
			brain_mob.process()
		if (MC_TICK_CHECK)
			return
