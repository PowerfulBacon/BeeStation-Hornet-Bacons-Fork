/obj/item/mob_lasso
	name = "space lasso"
	desc = "Comes standard with every space-cowboy.\n" + span_notice("Can be used to tame space carp.")
	icon = 'icons/obj/carp_lasso.dmi'
	icon_state = "lasso"
	///Ref to timer
	var/timer
	///Ref to lasso'd carp
	var/mob/living/simple_animal/mob_target
	///Range we can lasso things at
	var/range = 8
	///Uses per lasso
	var/uses = 4
	///Whitelist of allowed animals
	var/list/whitelist_mobs
	///blacklist of disallowed animals
	var/list/blacklist_mobs
	///Typecache caches
	var/static/list/whitelist_mob_cache = list()
	var/static/list/blacklist_mob_cache = list()

/obj/item/mob_lasso/Initialize(mapload)
	. = ..()
	if(!whitelist_mob_cache[type] && !blacklist_mob_cache[type])
		init_whitelists()
	whitelist_mobs = whitelist_mob_cache[type]
	blacklist_mobs = blacklist_mob_cache[type]

/obj/item/mob_lasso/proc/init_whitelists()
	whitelist_mob_cache[type] = typecacheof(list(/mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/hostile/carp/megacarp, /mob/living/simple_animal/hostile/carp/lia,\
	/mob/living/simple_animal/cow, /mob/living/simple_animal/hostile/retaliate/dolphin), only_root_path = TRUE)

/obj/item/mob_lasso/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	var/failed = FALSE
	if(!isliving(target))
		failed = TRUE
	if(!check_allowed(target))
		failed = TRUE
	if(iscarbon(target) || issilicon(target))
		failed = TRUE
	if(failed)
		if(ismob(target))
			to_chat(user, span_warning("[target] seems a bit big for this..."))
		return
	if(!(locate(target) in oview(range, user)))
		if(ismob(target))
			to_chat(user, span_warning("You can't lasso [target] from here!"))
		return
	var/mob/living/simple_animal/C = target
	if(IS_DEAD_OR_INCAP(C))
		to_chat(user, span_warning("[target] is dead."))
		return
	if(!user.combat_mode && C == mob_target) //if trying to tie up previous target
		to_chat(user, span_notice("You begin to untie [C]"))
		if(proximity_flag && do_after(user, 2 SECONDS, target, timed_action_flags = IGNORE_HELD_ITEM))
			user.faction |= "carpboy_[user]"
			C.faction = list(FACTION_NEUTRAL)
			C.faction |= "carpboy_[user]"
			C.faction |= user.faction
			C.transform = transform.Turn(0)
			C.toggle_ai(AI_ON)
			var/datum/component/tamed_command/T = C.AddComponent(/datum/component/tamed_command)
			T.add_ally(user)
			to_chat(user, span_notice("[C] nuzzles you."))
			UnregisterSignal(mob_target, COMSIG_PARENT_QDELETING)
			mob_target = null
			if(timer)
				deltimer(timer)
				timer = null
			uses--
			if(!uses)
				to_chat(user, span_warning("[src] falls apart!"))
				qdel(src)
			return
	else if(timer) //if trying to add new target while old target is still flipped
		to_chat(user, span_warning("You can't do that right now!"))
		return
	//Do lasso/beam for style points
	user.Beam(BeamTarget=C,icon_state = "carp_lasso",icon='icons/effects/beam.dmi', time = 1 SECONDS)
	C.unbuckle_all_mobs()
	mob_target = C
	C.throw_at(get_turf(src), 9, 2, user, FALSE, force = 0)
	C.transform = transform.Turn(180)
	C.toggle_ai(AI_OFF)
	RegisterSignal(C, COMSIG_PARENT_QDELETING, PROC_REF(handle_hard_del), override=TRUE)
	to_chat(user, span_notice("You lasso [C]!"))
	timer = addtimer(CALLBACK(src, PROC_REF(fail_ally)), 6 SECONDS, TIMER_STOPPABLE) //after 6 seconds set the carp back

/obj/item/mob_lasso/proc/check_allowed(atom/target)
	return ((!whitelist_mobs || is_type_in_typecache(target, whitelist_mobs)) && (!blacklist_mobs || !is_type_in_typecache(target, blacklist_mobs)))

/obj/item/mob_lasso/proc/fail_ally()
	if(!mob_target)
		return
	visible_message(span_warning("[mob_target] breaks free!"))
	mob_target.transform = transform.Turn(0)
	mob_target.toggle_ai(AI_ON)
	UnregisterSignal(mob_target, COMSIG_PARENT_QDELETING)
	mob_target = null
	timer = null

/obj/item/mob_lasso/proc/handle_hard_del()
	SIGNAL_HANDLER
	mob_target = null
	timer = null

/obj/item/mob_lasso/traitor
	name = "bluespace lasso"
	desc = "Comes standard with every administrator space-cowboy!\n" + span_notice("Can be used to tame almost anything.")
	uses = INFINITY

/obj/item/mob_lasso/traitor/init_whitelists(mapload)
	blacklist_mob_cache[type] = typecacheof(list(/mob/living/simple_animal/hostile/megafauna, /mob/living/simple_animal/hostile/alien, /mob/living/simple_animal/hostile/syndicate))

/obj/item/mob_lasso/debug
	name = "debug lasso"
	desc = "Comes standard with every administrator space-cowboy!\n" + span_notice("Can be used to tame anything.")
	uses = INFINITY

/obj/item/mob_lasso/debug/init_whitelists(mapload)
	blacklist_mob_cache[type] = list() // An empty list so we know this got initialized
