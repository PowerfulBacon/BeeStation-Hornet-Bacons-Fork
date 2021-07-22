//AI is stored in the bal- brain, I meant brain.
//The majority of AI functions will be the same things players can do.
//IE, the brain AI clicks on things. This means that when transfered to a different mob
//the AI will still perform its basic actions.
//Put Ian's brain in a human, the human will move towards food and eat it just like Ian would.
//Put a hostile mobs brain in something else and the new mob will act like the old hostile mob, even if it cant attack anymore.
//For the most part however; movement cheats and just calls move directly.
/obj/item/nbodypart/organ/brain/proc/handle_ai(mob/living/L)
	if(AIStatus == AI_ON)
		if(L.is_concious())
			INVOKE_ASYNC(src, .proc/handle_automated_action, L)
		if(L.is_concious())
			INVOKE_ASYNC(src, .proc/handle_automated_movement, L)
		if(L.is_concious())
			INVOKE_ASYNC(src, .proc/handle_automated_speech, L)
	else if(AIStatus == AI_IDLE)
		if(L.is_concious())
			INVOKE_ASYNC(src, .proc/handle_automated_movement, L)
		if(L.is_concious())
			INVOKE_ASYNC(src, .proc/consider_wakeup, L)

/obj/item/nbodypart/organ/brain/proc/handle_automated_action(mob/living/L)
	return

/obj/item/nbodypart/organ/brain/proc/handle_automated_movement(mob/living/L)
	return

/obj/item/nbodypart/organ/brain/proc/handle_automated_speech(mob/living/L, var/override)
	return

//On AI noly brains.
/obj/item/nbodypart/organ/brain/proc/owner_moved()
	return

/obj/item/nbodypart/organ/brain/proc/consider_wakeup(mob/living/L)
	if(L.pulledby || shouldwakeup)
		toggle_ai(AI_ON)

/obj/item/nbodypart/organ/brain/proc/toggle_ai(togglestatus)
	if(!is_ai_brain)
		stack_trace("Attempted to set AI on a brain that doesn't support AI control.")
		return
	if(!owner_body?.owner)
		stack_trace("Attempted to set AI on a brain that has no mob.")
		return
	if(!can_have_ai && togglestatus != AI_OFF)
		return
	var/mob/living/owner_mob = owner_body.owner
	if (AIStatus != togglestatus)
		if (togglestatus > 0 && togglestatus < 5)
			if (togglestatus == AI_Z_OFF || AIStatus == AI_Z_OFF)
				var/turf/T = get_turf(owner_mob)
				if (AIStatus == AI_Z_OFF)
					SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= owner_mob
				else
					SSidlenpcpool.idle_mobs_by_zlevel[T.z] += owner_mob
			GLOB.npc_brains[AIStatus] -= src
			GLOB.npc_brains[togglestatus] += src
			AIStatus = togglestatus
		else
			stack_trace("Something attempted to set simple animals AI to an invalid state: [togglestatus]")

//Custom overrides for stepping towards something
/obj/item/nbodypart/organ/brain
	var/ai_autowalk_num
	var/ai_autowalk_target
	var/ai_autowalk_ignore_walls = FALSE

/obj/item/nbodypart/organ/brain/Destroy()
	. = ..()
	//Disable movement
	ai_walk_to(null)

/obj/item/nbodypart/organ/brain/removed()
	. = ..()
	//Disable movement
	ai_walk_to(null)

/obj/item/nbodypart/organ/brain/proc/ai_walk_to(mob/living/L, atom/Target, Min = 0, Lag = 0)
	//Dont wait for this, it sleeps.
	set waitfor = FALSE

	if(!Target)
		ai_autowalk_num ++
		return FALSE

	//Keep on walking
	if(Target == ai_autowalk_target)
		return

	ai_autowalk_num ++

	var/cur_autowalk = ai_autowalk_num
	while(ai_autowalk_num == cur_autowalk)
		if(QDELETED(L) || QDELETED(Target))
			return
		var/our_pos = L
		//Handle finding paths while in mechas and lockers etc.
		if(!isturf(L.loc))
			our_pos = L.loc
		var/step_pos
		if(!ai_autowalk_ignore_walls)
			//avoid walls
			step_pos = get_step_to(our_pos, get_turf(Target), Min)
		else
			//Go through walls
			step_pos = get_step_towards(our_pos, get_turf(Target))
		if(step_pos)
			ai_move(L, step_pos, get_dir(L, step_pos))
		sleep(max(Lag, 1))

//Emulates client move closely to prevent AI cheating.
/obj/item/nbodypart/organ/brain/proc/ai_move(mob/living/L, newloc, direction)
	if(!L || !L.loc)
		return
	if(L.notransform)
		return
	if(L.force_moving)
		return
	//Why would we remove control something?
	if(L.remote_control)
		return L.remote_control.relaymove(L, direction)
	//Process grab
	//Buckle
	if(L.buckled)
		return L.buckled.relaymove(L, direction)
	//Can we even move?
	if(!(L.mobility_flags & MOBILITY_MOVE))
		return FALSE
	//Handle mech and moving things we are inside
	if(isobj(L.loc) || ismob(L.loc))
		var/atom/O = L.loc
		return O.relaymove(L, direction)
	//Process space drifting
	if(!L.Process_Spacemove(direction))
		return FALSE
	//Standard mob move.
	L.Move(newloc, direction)
