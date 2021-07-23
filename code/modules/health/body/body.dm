
//Stuff related to a body of a mob.
/datum/body
	//Owner of the body
	var/mob/living/owner

	//STATS!
	//Only things that will be affected by a lot is here.
	//I.E. Conciousness affects all of these while breathing is handled solely by the lungs.
	var/conciousness = 0
	var/manipulation = 0
	var/movement = 0
	var/seeing = 0
	var/hearing = 0

	//Mob stat
	var/stat = CONSCIOUS

	//Status Effects
	var/list/status_effects //a list of all status effects the mob has

	//Bodyparts
	//List of valid bodyslots
	//Needs to be set in the definition for the body.
	//Key: def_zone of bodypart
	//Value: Bodypart
	var/list/slots = list()

	//Override for brain type, since a lot of mobs change only the brain from their parent and nothing else (Dog, Corgi, Walter, Ian etc.)
	var/brain_type = /obj/item/nbodypart/organ/brain

	//Assoc list of inserted parts by slot.
	//Set by code.
	var/list/bodypart_by_slot = list()

	//Assoc list of bodyslots and what bodyslot holds them.
	var/list/bodypart_slot_holders = list()

	//Damage Handling

	//Blood Handling

/datum/body/New(mob/living/L)
	. = ..()
	owner = L

	//Set bodyslot
	set_bodyslots()

	//Init default parts
	for(var/slot in slots)
		var/obj/item/nbodypart/part = slots[slot]
		part.insert(src, L)

	//Create brain
	if(bodypart_by_slot.Find(BP_BRAIN) && bodypart_by_slot[BP_BRAIN] == BP_EMPTY)
		//Create the brain
		var/brain_holder = bodypart_slot_holders[BP_BRAIN]
		var/obj/item/nbodypart/brain_holder_object = bodypart_by_slot[brain_holder]
		var/obj/item/nbodypart/created_brain = new brain_type(L)
		brain_holder_object.held_bodyparts[BP_BRAIN] = created_brain
		created_brain.insert(src, L, brain_holder_object)

/datum/body/proc/set_bodyslots()
	slots = list(
		BODY_ZONE_HEAD = new /obj/item/nbodypart/head/organic(owner),
	)

//Get sight distance
//Based on eye efficiency
/datum/body/proc/get_ai_vision_range()
	return 9

//==================
// Injury helpers
//==================

/datum/body/proc/apply_injury(bodyslot, injury_type, injury_damage, max_damage = INFINITY)
	var/list/valid_bodyslots = islist(bodyslot) ? bodyslot : list(bodyslot)
	while(valid_bodyslots.len)
		var/picked_slot = pick(valid_bodyslots)
		var/obj/item/nbodypart/bodypart = get_bodypart(picked_slot)
		if(bodypart)
			bodypart.apply_injury(injury_type, injury_damage, max_damage)
			return
		else
			valid_bodyslots -= picked_slot

//==================
// Damage / Stat handling
//==================

/datum/body/proc/full_stat_update()
	set_movement(movement)
	set_manipulation(manipulation)
	set_sight(seeing)
	set_hearing(hearing)
	set_conciousness(conciousness)

//ALWAYS UPDATE CONCIOUSNESS LAST BECAUSE IT AFFECTS OTHER STATS.
/datum/body/proc/set_conciousness(value)
	conciousness = value
	//TODO: Since conciousness affects sight it will be bugged.
	//Sight is affected by conciousness and needs an update.
	set_sight(seeing)
	//Update stat
	update_stat(owner)

/datum/body/proc/set_movement(value)
	movement = value
	//Reset move delay so that they won't be stuck in place.
	owner.client?.move_delay = owner.movement_delay()

/datum/body/proc/set_manipulation(value)
	manipulation = value

/datum/body/proc/set_sight(value)
	var/mob/living/L = owner
	seeing = value
	var/new_actual_sight = get_sight()
	//No longer blind
	if(new_actual_sight > 0.3)
		L.cure_blind(EYE_DAMAGE)
	//Clear fullscreen effect
	L.clear_fullscreen(EYE_DAMAGE)
	//Sight stuff
	switch(new_actual_sight)
		//Blindness when below 30 sight.
		if(-INFINITY to 0.3)
			if(!HAS_TRAIT_FROM(L, BLIND, EYE_DAMAGE))
				L.become_blind(EYE_DAMAGE)
		//Poor vision when 50 or below
		if(0.3 to 0.5)
			L.overlay_fullscreen(EYE_DAMAGE, /atom/movable/screen/fullscreen/impaired, 2)
		if(0.5 to 0.8)
			L.overlay_fullscreen(EYE_DAMAGE, /atom/movable/screen/fullscreen/impaired, 1)

/datum/body/proc/set_hearing(value)
	hearing = value

/datum/body/proc/get_conciousness()
	return conciousness * 0.01

/datum/body/proc/get_movement()
	return movement * 0.01 * get_conciousness()

/datum/body/proc/get_manipulation()
	return manipulation * 0.01 * get_conciousness()

//Conciousness at 50%, lose 25% of sight.
#define CONCIOUSNESS_SIGHT_FACTOR(conciousness) (conciousness * 0.5 + 0.5)

/datum/body/proc/get_sight()
	return seeing * 0.01 * CONCIOUSNESS_SIGHT_FACTOR(get_conciousness())

/datum/body/proc/get_hearing()
	return hearing * 0.01 * get_conciousness()

//Updates on damage
/datum/body/proc/update_stat()
	var/mob/living/L = owner
	if(L.status_flags & GODMODE)
		return
	var/final_conciousness = get_conciousness()
	if(stat != DEAD)
		if(final_conciousness <= CONCIOUSNESS_THRESHOLD_DEAD && !HAS_TRAIT(L, TRAIT_NODEATH))
			L.death()
			return
		if(L.IsUnconscious() || L.IsSleeping() || L.getOxyLoss() > 50 || (HAS_TRAIT(L, TRAIT_DEATHCOMA)) || (final_conciousness <= CONCIOUSNESS_THRESHOLD_FULLCRIT && !HAS_TRAIT(L, TRAIT_NOHARDCRIT)))
			L.set_stat(UNCONSCIOUS)
			L.blind_eyes(1)
			if(CONFIG_GET(flag/near_death_experience) && final_conciousness <= CONCIOUSNESS_THRESHOLD_NEARDEATH && !HAS_TRAIT(L, TRAIT_NODEATH))
				ADD_TRAIT(L, TRAIT_SIXTHSENSE, "near-death")
			else
				REMOVE_TRAIT(L, TRAIT_SIXTHSENSE, "near-death")
		else
			if(conciousness <= CONCIOUSNESS_THRESHOLD_CRIT && !HAS_TRAIT(L, TRAIT_NOSOFTCRIT))
				L.set_stat(SOFT_CRIT)
			else
				L.set_stat(CONSCIOUS)
			L.adjust_blindness(-1)
			REMOVE_TRAIT(L, TRAIT_SIXTHSENSE, "near-death")
		L.update_mobility()
	L.update_damage_hud()
	L.update_health_hud()
	L.med_hud_set_status()

//==================
//Bodypart stuff
//==================

//Returns true if the slot is empty.
/datum/body/proc/remove_part_in_slot(bodyslot, force = FALSE)
	var/obj/item/nbodypart/part = get_bodypart(bodyslot)
	if(!part)
		return TRUE
	if(force || (part.bodypart_flags & BP_FLAG_REMOVABLE))
		part.removed(src, owner)
		qdel(part)
		return TRUE
	return FALSE

/datum/body/proc/insert_part(obj/item/nbodypart/part_to_insert)
	var/obj/item/nbodypart/part = get_bodypart(part_to_insert.bodyslot)
	if(part)
		return FALSE
	part_to_insert.loc = owner
	part_to_insert.insert(src, owner)
	return TRUE

//==================
// Status Effect Wrappers
//==================

/datum/body/proc/get_status_effects()
	return status_effects || list()

/datum/body/proc/add_status_effect(effect, ...)
	if(!status_effects)
		status_effects = list()
	//Ew
	var/list/arguments = args.Copy()
	arguments[1] = src
	//Add it
	var/datum/status_effect/datum_type = effect
	if(islist(status_effects[initial(datum_type.id)]))
		var/list/current_effects = status_effects[initial(datum_type.id)]
		for(var/datum/status_effect/S in current_effects)
			switch(initial(datum_type.status_type))
				if(STATUS_EFFECT_UNIQUE)
					return S
				if(STATUS_EFFECT_REPLACE)
					S.be_replaced()
				if(STATUS_EFFECT_REFRESH)
					S.refresh()
					return S
				else
					//Just add it
					var/datum/status_effect/created_effect = new effect(arguments)
					current_effects += created_effect
					return created_effect
	var/datum/status_effect/created_effect = new effect(arguments)
	status_effects[created_effect.id] = list(created_effect)
	return created_effect

/datum/body/proc/clear_status_effect(datum/status_effect/effect)
	LAZYREMOVE(status_effects, effect)

/datum/body/proc/apply_status_effect(effect, ...)

/datum/body/proc/remove_status_effect(effect_id)
	if(!status_effects)
		return
	status_effects.Remove(effect_id)

/datum/body/proc/has_status_effect(effect_id)
	if(!status_effects)
		return FALSE
	if(status_effects[effect_id])
		return TRUE
	return FALSE

/datum/body/proc/has_status_effect_list(effect_id)
	if(!status_effects)
		return list()
	return status_effects[effect_id] || list()

/datum/body/proc/handle_status_effects()
	//TODO Handle stuff like drunkness on the brain.
	var/obj/item/nbodypart/organ/brain/brain = get_bodypart(BP_BRAIN)
	if(brain)
		brain.handle_status_effects()

//Returns a bodypart in the BP slot.
/datum/body/proc/get_bodypart(bp_slot)
	return bodypart_by_slot[bp_slot]


//=============
//Life of the mob.
//Called every X seconds by the mob subsystem.
//Handles stuff that needs doing constantly.
//=============

/datum/body/proc/life(seconds_elapsed, times_fired)
	if(!has_status_effect(STATUS_EFFECT_STASIS))
		if(stat != DEAD)
			handle_status_effects()
