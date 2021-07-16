
//Mob survives the bodypart being destroeyd
#define BODYPART_DESTROY_SURVIVE 0
//Mob dies when the bodypart is destroyed.
#define BODYPART_DESTROY_KILL 1

/obj/item/nbodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	icon = 'icons/mob/human_parts.dmi'
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor

	//Flags for the bodypart
	var/bodypart_flags = NONE

	//Bodyslot of the bodypart
	//Set when inserted into someone.
	var/bodyslot

	//If the bodypart is a holder for other bodyparts.
	//E.G. The head usually holds the brain.
	//Note: For things like IPCs with a brain in the chest, checks are required to make sure duplicate organs are
	// not being added when this part is added to the new mob. Otherwise 2 brains could be inserted into a mob, causing problems.
	//WARNING: It is possible to make infinite loops from this.
	var/list/bodyslots_held = null

	//Allowed slots and the efficiency multiplier for each
	//For example left leg can be put in any leg slot, but is worse in the wrong slot
	var/list/allowed_slots = list()

	//Current efficiency of the bodypart.
	//100 to 0. Calculated based on health out of maxhealth as well as base efficiency.
	var/base_efficiency = 1
	var/efficiency

	var/cover_zone = CHEST

	//Is it destroyed?
	var/destroyed = FALSE
	//Text to display if destroyed
	var/destroy_cause

	//Owner of the bodypart.
	var/datum/body/body

	//Maxhealth of the bodypart
	var/maxHealth = 10
	//Current bodypart health. Will be destroyed if less than 0.
	var/health

	//Probability of being hit when shot
	var/bodypart_size = 0

	//A list of all injuries on this bodypart.
	var/list/injuries = list()

	//A list of all implants inside of this organ.
	var/list/implants = list()

	//Objects embedded within us
	var/list/embedded_objects = list()

/obj/item/nbodypart/proc/dismember(silent = FALSE)
	if(bodyslots_held)
		for(var/held_bodyslot in bodyslots_held)
			if(body.bodyparts[held_bodyslot])
				var/obj/item/nbodypart/part = body.bodyparts[held_bodyslot]
				//Take the part from the body
				part.dismember(TRUE)
				//Move the part inside of us
				contents += part
	//You just lost this.
	body.bodyparts[bodyslot] = null
	body = null
	return TRUE

/obj/item/nbodypart/proc/apply_damage(amount)
	health -= CLAMP(amount, 0, maxHealth)
	if(!health)
		//TODO Bodypart destroyed

/obj/item/nbodypart/proc/destroyed()
	return BODYPART_DESTROY_SURVIVE

//Returns a list of stats and what deltas to apply
//For example if a toe is destroyed it can return
//list("Movement" = -5) to take away 5 from the movement stat.
/obj/item/nbodypart/proc/return_stats()
	return list()

/obj/item/nbodypart/proc/get_damage()
	return maxHealth - health
