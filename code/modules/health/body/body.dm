
//Stuff related to a body of a mob.
/datum/body
	//Owner of the body
	var/mob/living/owner

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

	//Assoc list of inserted parts by slot.
	//Set by code.
	var/list/bodypart_by_slot = list()

	//Damage Handling

	//Blood Handling

/datum/body/New(mob/living/L)
	. = ..()
	owner = L
	
	slots = list(
		BODY_ZONE_HEAD = new /obj/item/nbodypart/head/human(owner),
	)
	
	for(var/slot in slots)
		var/obj/item/nbodypart/part = slots[slot]
		part.init_body(src)

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

//=============
//Life of the mob.
//Called every X seconds by the mob subsystem.
//Handles stuff that needs doing constantly.
//=============

/datum/body/proc/life(seconds_elapsed, times_fired)
	if(!has_status_effect(STATUS_EFFECT_STASIS))
		if(stat != DEAD)
			handle_status_effects()
