
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

	//Current efficiency of the bodypart.
	//100 to 0. Calculated based on health out of maxhealth as well as base efficiency.
	var/base_efficiency = 1
	var/efficiency

	//Is it destroyed?
	var/destroyed = FALSE
	//Text to display if destroyed
	var/destroy_cause

	//Owner of the bodypart.
	var/mob/living/owner

	//Maxhealth of the bodypart
	var/maxHealth = 10
	//Current bodypart health. Will be destroyed if less than 0.
	var/health

	//Where is this bodypart located in the body.
	var/bodypart_zone = null
	//Probability of being hit when shot
	var/bodypart_size = 0
	//Is the bodypart internal or external?
	//Internal bodyparts wont take damage from non-penetrating weapons
	//Internal bodyparts cannot be easilly tended without drugs / surgery.
	var/bodypart_internal = FALSE

	//A list of all injuries on this bodypart.
	var/list/injuries = list()

/obj/item/nbodypart/proc/destroyed()
	return BODYPART_DESTROY_SURVIVE

/obj/item/nbodypart/proc/return_stats()
	return list()

//Apply injury and update health of affected mob.
/obj/item/nbodypart/proc/apply_injury()
	return
