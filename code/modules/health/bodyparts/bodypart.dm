/datum/bodypart
	//The body we are attached to
	var/datum/body/body
	//The parent bodypart
	var/datum/bodypart/parent
	//A list of slots that we are allowed to be inserted into
	var/list/allowed_slots
	//The current health
	var/health
	//Maximum health
	var/max_health
	//All bodyparts that are contained within this one
	//Associative slot -> bodypart
	var/list/contained_parts
	//A list of injuries applied to this bodypart
	var/list/applied_injuries = list()
	//The stat values provided by having this bodypart
	var/list/associative_stat_values

/datum/bodypart/New(datum/body/body, datum/bodypart/parent, inserted_slot)
	. = ..()
	src.body = body
	src.parent = parent
	//Set the max health
	health = max_health
	//Create contained path
	for(var/slot in contained_parts)
		var/type = contained_parts[slot]
		if(ispath(type))
			contained_parts[slot] = new type(body, src, slot)

/datum/bodypart/proc/apply_injury(datum/injury/injury)
	//No body, no damage
	if(!body)
		CRASH("Apply injury called on a bodypart not inserted into a body!")
	//Update pain
	var/pain_amount = injury.damage * injury.pain_multiplier
	body.adjust_pain(pain_amount)
