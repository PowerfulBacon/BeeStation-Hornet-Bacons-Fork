/obj/item/nbodypart
	//The body that we are inside of. (If we are inside of a body)
	var/datum/body/owner_body

	icon = 'icons/obj/surgery.dmi'

	//Destroy
	var/is_destroyed = FALSE
	//Health
	var/maxhealth
	var/health

	//Efficiency multipliers
	var/efficiency = 1	//Bodypart efficiency. Clamped between 0 and 1.

	//Stat factors (PROVIDES FUNCTIONALITY)
	//When damaged, these are slowly reduced to 0.
	//When removed these are taken away from the body.
	//When added these are added to the body.
	//For stuff like arms and legs that provide movement and movement cannot be performed without them.
	var/conciousness_factor = 0
	var/manipulation_factor = 0
	var/movement_factor = 0
	var/sight_factor = 0
	var/hearing_factor = 0

	//Stat detriments (DAMAGE ONLY)
	//For stuff like bones.
	//By default these will have no effect, however when damaged these will be taken away from the stats
	//of the body.
	//When removed the detriment will be reverted.
	//EG if your spin gets damaged, manipulation is slowed, however the spine doesn't give movement.
	var/conciousness_detriment = 0
	var/manipulation_detriment = 0
	var/movement_detriment = 0
	var/sight_detriment = 0
	var/hearing_detriment = 0

	//Bodyslot key
	var/bodyslot

	//Bodypart flags
	var/bodypart_flags

	//Any bodyparts we hold
	//ASSOC
	//Key: bodyslot ID
	//Value: Bodypart object
	var/list/held_bodyparts = list()

	//A list of injuries on this bodypart
	var/list/injuries = list()

/obj/item/nbodypart/Initialize()
	. = ..()
	initialize_contents()
	health = maxhealth

/obj/item/nbodypart/proc/initialize_contents()
	return

/obj/item/nbodypart/proc/life(datum/body/parentbody, mob/living/L)
	return

/obj/item/nbodypart/proc/destroy()
	//Just in case, force health to 0.
	//This calls destroy again.
	if(health)
		update_health(0)
		return
	//Bodypart is destroyed.
	is_destroyed = TRUE
	//Tell them about it
	to_chat(owner_body?.owner, "<span class='userdanger'>You feel a searing pain in your [src]!</span>")

/obj/item/nbodypart/proc/update_health(new_health)
	//Cannot effect destroyed parts.
	if(is_destroyed)
		return
	//Update health
	health = CLAMP(new_health, 0, maxhealth)
	//Update efficiency
	var/pre_efficiency = efficiency
	efficiency = health / maxhealth

	//TODO: Detriment

	//MANIPULATION EFFECT
	if(manipulation_factor)
		var/previous_manipulation_factor = pre_efficiency * manipulation_factor
		var/new_manipulation_factor = efficiency * manipulation_factor
		var/delta_manipulation_factor = new_manipulation_factor - previous_manipulation_factor
		owner_body.set_manipulation(owner_body.manipulation + delta_manipulation_factor)

	//MOVEMENT EFFECT
	if(movement_factor)
		var/previous_movement_factor = pre_efficiency * movement_factor
		var/new_movement_factor = efficiency * movement_factor
		var/delta_movement_factor = new_movement_factor - previous_movement_factor
		owner_body.set_movement(owner_body.movement + delta_movement_factor)

	//SIGHT EFFECT
	if(sight_factor)
		var/previous_sight_factor = pre_efficiency * sight_factor
		var/new_sight_factor = efficiency * sight_factor
		var/delta_sight_factor = new_sight_factor - previous_sight_factor
		owner_body.set_sight(owner_body.seeing + delta_sight_factor)

	//SIGHT EFFECT
	if(hearing_factor)
		var/previous_hearing_factor = pre_efficiency * hearing_factor
		var/new_hearing_factor = efficiency * hearing_factor
		var/delta_hearing_factor = new_hearing_factor - previous_hearing_factor
		owner_body.set_hearing(owner_body.hearing + delta_hearing_factor)

	//CONCIOUSNESS EFFECT
	if(conciousness_factor)
		var/previous_conciousness_factor = pre_efficiency * conciousness_factor
		var/new_conciousness_factor = efficiency * conciousness_factor
		var/delta_conciousness_factor = new_conciousness_factor - previous_conciousness_factor
		owner_body.set_conciousness(owner_body.conciousness + delta_conciousness_factor)

	//Destroy
	if(!health)
		destroy()

//=======================
// Injury types
//=======================

//Applies an injury with damage damage and type injury_type
/obj/item/nbodypart/proc/apply_injury(injury_type, damage, max_damage = INFINITY)
	var/current_damage = maxhealth - health
	if(current_damage + damage > max_damage)
		//Reduce damage
		damage = max_damage - current_damage
		if(damage <= 0)
			return
	var/datum/injury/initial_type = injury_type
	if(initial(initial_type.unique))
		//Make a new one
		injuries += new injury_type(src, damage)
	else
		//Update existing one
		var/datum/injury/existing = get_injury_type(injury_type)
		if(existing)
			//More damage.
			existing.update_damage(existing.damage + damage)
		else
			//Make a new one
			injuries += new injury_type(src, damage)

//Heals an injury for the provided amount of damage.
/obj/item/nbodypart/proc/heal_injury(injury_type, amount)
	var/list/to_heal = get_injuries_type(injury_type)
	for(var/datum/injury/I as() in to_heal)
		var/amount_used = min(amount, I.damage)
		I.update_damage(I.damage - amount_used)
		amount -= amount_used
		if(amount <= 0)
			return

/obj/item/nbodypart/proc/get_injury_type(injury_type)
	for(var/datum/injury/I as() in injuries)
		if(I.type == injury_type)
			return I

/obj/item/nbodypart/proc/get_injuries_type(injury_type)
	. = list()
	for(var/datum/injury/I as() in injuries)
		if(I.type == injury_type)
			. += I

//TODO
//Needs tending item as param
/obj/item/nbodypart/proc/tend_injury(injury_type)

/obj/item/nbodypart/proc/insert(datum/body/parentbody, mob/living/L, obj/item/nbodypart/parent_part)
	if(owner_body)
		return FALSE

	//Insert ourselves
	owner_body = parentbody
	owner_body.bodypart_slot_holders[bodyslot] = parent_part?.bodyslot || BP_EMPTY
	owner_body.bodypart_by_slot[bodyslot] = src

	//Apply base stats
	owner_body.conciousness += conciousness_factor
	owner_body.manipulation += manipulation_factor
	owner_body.movement += movement_factor
	owner_body.seeing += sight_factor
	owner_body.hearing += hearing_factor

	owner_body.full_stat_update()

	//Insert our held parts
	for(var/obj/item/nbodypart/contained_part in contents)
		contained_part.insert(parentbody, L, src)

	//Update any nulls in the held bodyparts section
	for(var/bodypart_held in held_bodyparts)
		var/thing = held_bodyparts[bodypart_held]
		if(thing == BP_EMPTY)
			owner_body.bodypart_slot_holders[bodypart_held] = bodyslot
			owner_body.bodypart_by_slot[bodypart_held] = BP_EMPTY

	//Give actions
	for(var/datum/action/A as() in actions)
		A.Grant(L)

	//Move inside
	moveToNullspace()
	return TRUE

/obj/item/nbodypart/proc/removed(datum/body/parentbody, mob/living/L)
	if(!owner_body)
		return FALSE

	//Set our slot to be empty.
	owner_body.bodypart_by_slot[bodyslot] = BP_EMPTY
	//Remove any slots we held.
	for(var/bodyslot_held in held_bodyparts)
		//If something was in the slot we held, remove that too.
		var/obj/item/nbodypart/held_part = owner_body.bodypart_by_slot[bodyslot_held]
		//Remove the part before removing the slot.
		if(held_part)
			held_part.removed(parentbody, L)
		//Remove the slot from the bodypart by slot list.
		owner_body.bodypart_by_slot.Remove(bodyslot_held)
		//Remove the slot from the bodypart slot holders list.
		owner_body.bodypart_slot_holders.Remove(bodyslot_held)

	//Since its removed, apply max damage.
	owner_body.conciousness -= conciousness_factor
	owner_body.manipulation -= manipulation_factor
	owner_body.movement -= movement_factor
	owner_body.seeing -= sight_factor
	owner_body.hearing -= hearing_factor

	owner_body.full_stat_update()

	//Move to parent loc.
	loc = L.loc

	//Revoke Actions
	for(var/datum/action/A as() in actions)
		A.Remove(L)

	//Check death
	if((bodypart_flags & BP_FLAG_CRITICAL) && !(L.status_flags & GODMODE))
		L.death()

	//Send removal signal
	//TODO SEND_SIGNAL(L, COMSIG_CARBON_LOSE_ORGAN, src)

	//Null our body.
	owner_body = null
	return TRUE

/obj/item/nbodypart/proc/dismember()
	var/mob/living/L = owner_body.owner
	if(removed(owner_body, L))
		L.emote("scream")
		to_chat(L, "<span class'userdanger>Your [src] is torn free from its socket!</span>")
		SpinAnimation(5, 1)
