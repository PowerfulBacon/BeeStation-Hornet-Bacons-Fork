SUBSYSTEM_DEF(idlenpcpool)
	name = "Idling NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	priority = FIRE_PRIORITY_IDLE_NPC
	wait = 60
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/static/list/idle_mobs_by_zlevel[][]

/datum/controller/subsystem/idlenpcpool/stat_entry()
	var/list/idlelist = GLOB.npc_brains[AI_IDLE]
	var/list/zlist = GLOB.npc_brains[AI_Z_OFF]
	. = ..("IdleNPCS:[idlelist.len]|Z:[zlist.len]")

/datum/controller/subsystem/idlenpcpool/proc/MaxZChanged()
	if (!islist(idle_mobs_by_zlevel))
		idle_mobs_by_zlevel = new /list(world.maxz,0)
	while (SSidlenpcpool.idle_mobs_by_zlevel.len < world.maxz)
		SSidlenpcpool.idle_mobs_by_zlevel.len++
		SSidlenpcpool.idle_mobs_by_zlevel[idle_mobs_by_zlevel.len] = list()

/datum/controller/subsystem/idlenpcpool/fire(resumed = FALSE)

	if (!resumed)
		var/list/idlelist = GLOB.npc_brains[AI_IDLE]
		src.currentrun = idlelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/item/nbodypart/organ/brain/brain = currentrun[currentrun.len]
		var/mob/living/brain_mob = brain.owner_body?.owner
		--currentrun.len

		if(!brain_mob)
			continue

		if(!brain)
			stack_trace("Null entry found at GLOB.npc_brains\[AI_IDLE\]. Null entries will be purged. Yell at coderbus. Subsystem will try to continue.")
			removeNullsFromList(GLOB.npc_brains[AI_IDLE])
			continue

		if(!brain_mob.ckey)
			INVOKE_ASYNC(brain, /obj/item/nbodypart/organ/brain.proc/handle_ai, brain_mob)
		if (MC_TICK_CHECK)
			return
