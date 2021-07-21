
/obj/item/nbodypart/organ/brain/simple_animal/hostile
	var/atom/target
	var/dodging = FALSE
	var/approaching_target = FALSE //We should dodge now
	var/in_melee = FALSE	//We should sidestep now
	var/dodge_prob = 30
	var/sidestep_per_cycle = 1 //How many sidesteps per npcpool cycle when in melee

	//Search Objects
	//Actual search object var is on the mob WTF!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Refactor!!!!!!!!!!!!!!!!!!
	var/search_objects_timer_id //Timer for regaining our old search_objects value after being attacked
	var/search_objects_regain_time = 30 //the delay between being attacked and gaining our old search_objects value back

	//Patience
	var/lose_patience_timer_id //id for a timer to call LoseTarget(), used to stop mobs fixating on a target they can't reach
	var/lose_patience_timeout = 300 //30 seconds by default, so there's no major changes to AI behaviour, beyond actually bailing if stuck forever

	//Taunting
	var/list/emote_taunt = list()
	var/taunt_chance = 0

	//Enviro Smash
	//TODO: When inserted into a hostile simple_animal, inherit smash behaviour.
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	//Is Ranged
	//TODO: When inserted into a hostile simple_animal, inherit ranged behaviour.
	var/is_ranged_mob = FALSE
	var/ranged_ignores_vision = FALSE //if it'll fire ranged attacks even if it lacks vision on its target, only works with environment smash
	var/check_friendly_fire = 0 // Should the ranged mob check for friendlies when shooting
	var/retreat_distance = null //If our mob runs from players when they're too close, set in tile distance. By default, mobs do not retreat.
	var/minimum_distance = 1 //Minimum approach distance, so ranged mobs chase targets down, but still keep their distance set in tiles to the target, set higher to make mobs keep distance

/obj/item/nbodypart/organ/brain/simple_animal/hostile/handle_automated_movement(mob/living/L)
	if(dodging && target && in_melee && isturf(L.loc) && isturf(target.loc))
		var/datum/cb = CALLBACK(src, .proc/sidestep, L)
		if(sidestep_per_cycle > 1) //For more than one just spread them equally - this could changed to some sensible distribution later
			var/sidestep_delay = SSnpcpool.wait / sidestep_per_cycle
			for(var/i in 1 to sidestep_per_cycle)
				addtimer(cb, (i - 1)*sidestep_delay)
		else //Otherwise randomize it to make the players guessing.
			addtimer(cb,rand(1,SSnpcpool.wait))

/obj/item/nbodypart/organ/brain/simple_animal/hostile/handle_automated_action(mob/living/L)
	var/list/possible_targets = ListTargets(L) //we look around for potential targets and make it a list for later use.

	if(environment_smash)
		EscapeConfinement(L)

	if(AICanContinue(L, possible_targets))
		var/atom/target_from = GET_TARGETS_FROM(L)
		if(!QDELETED(target) && !target_from.Adjacent(target))
			DestroyPathToTarget()
		if(!MoveToTarget(L, possible_targets))     //if we lose our target
			if(AIShouldSleep(L, possible_targets))	// we try to acquire a new one
				toggle_ai(AI_IDLE)			// otherwise we go idle

//===============
// AI Movement
//===============

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/Goto(mob/living/L, target, delay, minimum_distance)
	if(target == src.target)
		approaching_target = TRUE
	else
		approaching_target = FALSE
	ai_walk_to(L, target, minimum_distance, delay)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/MoveToTarget(mob/living/L, list/possible_targets)//Step 5, handle movement between us and our target
	stop_automated_movement = TRUE
	if(!target || !L.CanAiAttack(target))
		LoseTarget(L)
		return 0
	var/atom/target_from = GET_TARGETS_FROM(L)
	if(target in possible_targets)
		var/turf/T = get_turf(L)
		if(target.get_virtual_z_level() != T.get_virtual_z_level())
			LoseTarget(L)
			return 0
		var/target_distance = get_dist(target_from,target)
		if(is_ranged_mob) //We ranged? Shoot at em
			if(!target.Adjacent(target_from)) //But make sure they're not in range for a melee attack and our range attack is off cooldown
				L.ClickOn(target)
		if(!L.Process_Spacemove()) //Drifting
			ai_walk_to(L,0)
			return 1
		if(retreat_distance != null) //If we have a retreat distance, check if we need to run from our target
			if(target_distance <= retreat_distance) //If target's closer than our retreat distance, run
				ai_walk_to(L,target,retreat_distance,L.move_to_delay)
			else
				Goto(L, target,L.move_to_delay,minimum_distance) //Otherwise, get to our minimum distance so we chase them
		else
			Goto(L, target,L.move_to_delay,minimum_distance)
		if(target)
			if(isturf(target_from.loc) && target.Adjacent(target_from)) //If they're next to us, attack
				MeleeAction(L)
			else
				if(L.rapid_melee > 1 && target_distance <= L.melee_queue_distance)
					MeleeAction(L, FALSE)
				in_melee = FALSE //If we're just preparing to strike do not enter sidestep mode
			return 1
		return 0
	if(environment_smash)
		if(target.loc != null && get_dist(target_from, target.loc) <= owner_body.get_ai_vision_range()) //We can't see our target, but he's in our vision range still
			if(ranged_ignores_vision) //we can't see our target... but we can fire at them!
				//Try and shoot at the target by clicking on them.
				L.ClickOn(target)
			if((environment_smash & ENVIRONMENT_SMASH_WALLS) || (environment_smash & ENVIRONMENT_SMASH_RWALLS)) //If we're capable of smashing through walls, forget about vision completely after finding our target
				Goto(target,L.move_to_delay,minimum_distance)
				FindHidden(L)
				return 1
			else
				if(FindHidden(L))
					return 1
	LoseTarget(L)
	return 0

//===============
// AI Find Hidden
//===============

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/FindHidden(mob/living/L)
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
		var/atom/A = target.loc
		var/atom/target_from = GET_TARGETS_FROM(L)
		Goto(L, A, L.move_to_delay, minimum_distance)
		if(A.Adjacent(target_from))
			L.ClickOn(A)
		return 1

//===============
// AI Checks
//===============

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/AIShouldSleep(mob/living/L, list/possible_targets)
	return !FindTarget(L, possible_targets, TRUE)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/AICanContinue(mob/living/L, list/possible_targets)
	switch(AIStatus)
		if(AI_ON)
			return TRUE
		if(AI_IDLE)
			if(FindTarget(L, possible_targets, TRUE))
				toggle_ai(AI_ON)
				return TRUE
			else
				return FALSE

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/FindTarget(mob/living/L, list/possible_targets, HasTargetsList = FALSE)//Step 2, filter down possible targets to things we actually care about
	. = list()
	if(!HasTargetsList)
		possible_targets = ListTargets(L)
	for(var/pos_targ in possible_targets)
		var/atom/A = pos_targ
		if(Found(A))//Just in case people want to override targetting
			. = list(A)
			break
		if(L.CanAiAttack(A))//Can we attack it?
			. += A
			continue
	var/Target = PickTarget(L, .)
	GiveTarget(L, Target)
	return Target //We now have a target

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/ListTargets(mob/living/L)
	var/atom/target_from = GET_TARGETS_FROM(L)
	if(!L.search_objects)
		var/static/target_list = typecacheof(list(/obj/machinery/porta_turret, /obj/mecha)) //mobs are handled via ismob(A)
		. = list()
		for(var/atom/A as() in dview(owner_body.get_ai_vision_range(), get_turf(target_from), SEE_INVISIBLE_MINIMUM))
			if((ismob(A) && A != L) || target_list[A.type])
				. += A
	else
		. = oview(owner_body.get_ai_vision_range(), target_from)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/PickTarget(mob/living/L, list/Targets)//Step 3, pick among us the possible, attackable targets
	if(target != null)//If we already have a target, but are told to pick again, calculate the lowest distance between all possible, and pick from the lowest distance targets
		var/atom/target_from = GET_TARGETS_FROM(L)
		for(var/pos_targ in Targets)
			var/atom/A = pos_targ
			var/target_dist = get_dist(target_from, target)
			var/possible_target_distance = get_dist(target_from, A)
			if(target_dist < possible_target_distance)
				Targets -= A
	if(!Targets.len)//We didnt find nothin!
		return
	var/chosen_target = pick(Targets)//Pick the remaining targets (if any) at random
	return chosen_target

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/GiveTarget(mob/living/L, new_target)//Step 4, give us our selected target
	add_target(new_target)
	LosePatience()
	if(target != null)
		GainPatience(L)
		Aggro(L)
		return TRUE

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/Found(mob/living/L, atom/A)
	return

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/PossibleThreats(mob/living/L)
	. = list()
	for(var/pos_targ in ListTargets(L))
		var/atom/A = pos_targ
		if(Found(L, A))
			. = list(A)
			break
		if(L.CanAiAttack(A))
			. += A
			continue

//===============
// AI Aggro
//===============

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/Aggro(mob/living/L)
	//TODO: Aggro vision range
	//vision_range = L.aggro_vision_range
	if(target && emote_taunt.len && prob(taunt_chance))
		INVOKE_ASYNC(L, /mob.proc/emote, "me", 1, "[pick(emote_taunt)] at [target].")
		taunt_chance = max(taunt_chance-7,2)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/LoseAggro(mob/living/L)
	stop_automated_movement = 0
	//TODO
	//vision_range = initial(vision_range)
	//taunt_chance = initial(taunt_chance)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/LoseTarget(mob/living/L)
	GiveTarget(L, null)
	approaching_target = FALSE
	in_melee = FALSE
	ai_walk_to(L, 0)
	LoseAggro(L)

//===============
// AI Target Handling
//===============

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/GainPatience(mob/living/L)
	if(lose_patience_timeout)
		LosePatience()
		lose_patience_timer_id = addtimer(CALLBACK(src, .proc/LoseTarget, L), lose_patience_timeout, TIMER_STOPPABLE)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/LosePatience()
	deltimer(lose_patience_timer_id)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/handle_target_del(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = null
	LoseTarget(owner_body.owner)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/add_target(new_target)
	if(target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = new_target
	if(target)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/handle_target_del)

//===============
// AI Mob Actions
//===============

//Combat
/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/MeleeAction(mob/living/L, patience = TRUE)
	if(L.rapid_melee > 1)
		var/datum/callback/cb = CALLBACK(src, .proc/CheckAndAttack, L)
		var/delay = SSnpcpool.wait / L.rapid_melee
		for(var/i in 1 to L.rapid_melee)
			addtimer(cb, (i - 1)*delay)
	else
		if(target)
			L.ClickOn(target)
	if(patience)
		GainPatience(L)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/CheckAndAttack(mob/living/L)
	var/atom/target_from = GET_TARGETS_FROM(L)
	if(target && isturf(target_from.loc) && target.Adjacent(target_from) && !L.incapacitated())
		L.ClickOn(target)

//Moving towards target
/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/DestroyPathToTarget(mob/living/L)
	if(environment_smash)
		EscapeConfinement()
		var/atom/target_from = GET_TARGETS_FROM(L)
		var/dir_to_target = get_dir(target_from, target)
		var/dir_list = list()
		if(dir_to_target in GLOB.diagonals) //it's diagonal, so we need two directions to hit
			for(var/direction in GLOB.cardinals)
				if(direction & dir_to_target)
					dir_list += direction
		else
			dir_list += dir_to_target
		for(var/direction in dir_list) //now we hit all of the directions we got in this fashion, since it's the only directions we should actually need
			DestroyObjectsInDirection(direction)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/DestroyObjectsInDirection(mob/living/L, direction)
	var/atom/target_from = GET_TARGETS_FROM(L)
	var/turf/T = get_step(target_from, direction)
	if(QDELETED(T))
		return
	if(T.Adjacent(target_from))
		if(CanSmashTurfs(T))
			L.ClickOn(T)
			return
	for(var/obj/O in T.contents)
		if(!O.Adjacent(target_from))
			continue
		if((ismachinery(O) || isstructure(O)) && O.density && environment_smash >= ENVIRONMENT_SMASH_STRUCTURES && !O.IsObscured())
			L.ClickOn(O)
			return

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/CanSmashTurfs(turf/T)
	return iswallturf(T) || ismineralturf(T)

//Escape confinement
/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/EscapeConfinement(mob/living/L)
	var/atom/target_from = GET_TARGETS_FROM(L)
	if(L.buckled)
		L.ClickOn(L.buckled)
	else if(!isturf(target_from.loc) && target_from.loc != null)
		var/atom/A = target_from.loc
		L.ClickOn(A)

//Perform sidestep dodging.
/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/sidestep(mob/living/L)
	if(!target || !isturf(target.loc) || !isturf(L.loc) || L.is_dead())
		return
	var/target_dir = get_dir(L, target)

	var/static/list/cardinal_sidestep_directions = list(-90,-45,0,45,90)
	var/static/list/diagonal_sidestep_directions = list(-45,0,45)

	var/chosen_dir = 0
	if (target_dir & (target_dir - 1))
		chosen_dir = pick(diagonal_sidestep_directions)
	else
		chosen_dir = pick(cardinal_sidestep_directions)

	if(chosen_dir)
		chosen_dir = turn(target_dir,chosen_dir)
		ai_move(L, get_step(L, chosen_dir), chosen_dir)
		L.face_atom(target)

//=====================
// Wake up. Wake up. Wake up.
//=====================

/obj/item/nbodypart/organ/brain/simple_animal/hostile/consider_wakeup(mob/living/L)
	..()
	var/list/tlist
	var/turf/T = get_turf(L)

	if (!T)
		return

	if (!length(SSmobs.clients_by_zlevel[T.z])) // It's fine to use .len here but doesn't compile on 511
		toggle_ai(AI_Z_OFF)
		return

	var/cheap_search = isturf(T) && !is_station_level(T.z)
	if (cheap_search)
		tlist = ListTargetsLazy(L, T.z)
	else
		tlist = ListTargets(L)

	if(AIStatus == AI_IDLE && FindTarget(L, tlist, 1))
		if(cheap_search) //Try again with full effort
			FindTarget(L)
		toggle_ai(AI_ON)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/proc/ListTargetsLazy(mob/living/L, var/_Z)//Step 1, find out what we can see
	var/static/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/mecha))
	. = list()
	for (var/I in SSmobs.clients_by_zlevel[_Z])
		var/mob/M = I
		if (get_dist(M, L) < owner_body.get_ai_vision_range())
			if (isturf(M.loc))
				. += M
			else if (M.loc.type in hostile_machines)
				. += M.loc
