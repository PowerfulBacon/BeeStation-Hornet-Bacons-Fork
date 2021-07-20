/datum/body
	//Which organ / bodypart slots can we accept
	//Assoc list of where bodyslots are stored in the body.
	//Heart is in the bodyzone chest etc.
	var/list/accepted_bodyslots = list()

	//List calculated on creation of body. Assoc list containing a list of every bodyslot in the def_zone
	var/bodyslots_in_zone

	//A list of all bodyparts in this mob. Assoc list (key = bodyslot (Body, head etc.))
	var/list/bodyparts = list()

	//The mob that has this body
	var/mob/living/owner

	//===============
	// Total Damage
	//===============

	var/total_damage

	//===============
	// Conciousness
	//===============

	//0 to 100. Conciousness of a mob. When less than 40 a mob goes into crit, when less than 0 the mob dies.
	var/conciousness = 100

	//===============
	// Blood
	//===============
	var/has_blood = FALSE
	//Blood volumes
	var/blood_volume_maximum = BLOOD_VOLUME_MAXIMUM
	var/blood_volume_normal = BLOOD_VOLUME_NORMAL
	var/blood_volume_safe = BLOOD_VOLUME_SAFE
	var/blood_volume_death = BLOOD_VOLUME_SURVIVE
	//Amount of blood being lost per second
	var/bleed_rate = 0
	//Bloodtype of this body
	var/list/valid_blood_types = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+", "U")
	var/bloodtype

	//Flow of blood around the body.
	//Affected by breathing and heart efficiency
	//Has a minor affect on movement (Caps out at 120% bloodflow)
	//Brain will slowly gain oxygen deprivation when below 60
	var/blood_flow = 100

	//===============
	// Manipulation / Movement
	//===============

	//How effective a mob is at manipulating the world.
	var/manipulation = 100
	//How effective a mob is at moving. Default 100. Below 40 prevents walking. Below 20 prevents crawling.
	var/movement = 100

/datum/body/New(mob/living/parent)
	. = ..()
	owner = parent
	calculate_bodyparts()

/datum/body/proc/get_bodypart(bodyslot)
	return bodyparts[bodyslot] || null

/datum/body/proc/get_bodyparts()
	. = list()
	for(var/thing in bodyparts)
		. += bodyparts[thing]

/datum/body/proc/get_random_leg()
	return

//TODO Return a list of valid arms
/datum/body/proc/get_arms()
	return list()

/*
 * Returns a random bodypart in the def_zone.
 */
/datum/body/proc/get_bodypart_in_zone(def_zone, allow_organs = FALSE, removable_only = FALSE)
	//TODO: Weighting
	return pick(get_bodyparts_in_zone(def_zone, allow_organs))

/*
 * Returns a list of bodyparts that are in the set zone.
 * Doesn't return organs unless allow_organs is true.
 * If removable only is TRUE then organs that cannot be removed will not be returned.
 */
/datum/body/proc/get_bodyparts_in_zone(def_zone, allow_organs = FALSE, removable_only = FALSE)
	var/list/valid_slots = list()
	if(islist(bodyslots_in_zone[def_zone]))
		valid_slots = bodyslots_in_zone[def_zone]
	else
		//Default to chest, all mobs must have a chest.
		valid_slots = bodyslots_in_zone[BODY_ZONE_CHEST]
	. = list()
	for(var/bodyslot in valid_slots)
		var/obj/item/nbodypart/part = bodyparts[bodyslot]
		if(!part)
			continue
		if(removable_only && !(part.bodypart_flags & REMOVABLE))
			continue
		if(!allow_organs && (part.bodypart_flags & ORGAN))
			continue
		. += part

/datum/body/proc/get_bodyslots_in_zone(def_zone)
	return bodyslots_in_zone[def_zone] || list()

//TODO
/datum/body/proc/get_active_hand()
	RETURN_TYPE(/obj/item/nbodypart/arm)

/datum/body/proc/calculate_bodyparts()
	bodyslots_in_zone = list()
	for(var/accepted_bodyslot in accepted_bodyslots)
		var/def_zone = accepted_bodyslots[accepted_bodyslot]
		if(islist(bodyslots_in_zone[def_zone]))
			bodyslots_in_zone[def_zone] += accepted_bodyslot
		else
			bodyslots_in_zone[def_zone] = list(accepted_bodyslot)

/datum/body/proc/get_damage()
	return total_damage

/datum/body/proc/get_damage_from_injury_types(list/injury_types)
	. = 0
	for(var/slot in bodyparts)
		var/obj/item/nbodypart/bodypart = bodyparts[slot]
		for(var/datum/injury/injury as() in bodypart.injuries)
			if(injury.type in injury_types)
				. += injury.damage

//Returns the brain
/datum/body/proc/get_brain()
	return bodyparts[BRAIN] || null

//Updates conciousness and the stats associated to it.
/datum/body/proc/update_conciousness(var/old_conciousness)
	manipulation += (old_conciousness - conciousness) * CONCIOUSNESS_MANIPULATION_MULTIPLIER
	movement += (old_conciousness - conciousness) * CONCIOUSNESS_MOVEMENT_MULTIPLIER

//TODO Returns TRUE if the mob would be able to survive if revived
/datum/body/proc/can_revive()
	return FALSE

//TODO
/datum/body/proc/flash_act(intensity = 0)
	return

//TODO
//heals total body damage by taking the damage off of all injuries. Removes any injuries if their damage goes less than 0
/datum/body/proc/heal_total_damage(amount, allowed_bodypart_types = BODYPART_ORGANIC | BODYPART_ROBOTIC)
	return

//TODO
//heals injuries based on type until amount runs out
/datum/body/proc/heal_injuries(amount, list/valid_types)
	return

//TODO
/datum/body/proc/is_concious()
	return conciousness >= 40
