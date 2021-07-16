
//===================
// Generic Brain
//===================

/obj/item/nbodypart/brain
	name = "brain"

	//Squishy
	maxHealth = 15

	//Brain is inside the head
	bodypart_flags = PROTECTED | ORGAN | CRITICAL
	//Brain is pretty small.
	bodypart_size = 4
	//Does the brain feel pain?
	var/feels_pain = TRUE
	//Amount of pain on the mob. Affects conciousness.
	var/pain = 0

	//Name of conciousness. Changes the name of the conciousness stat on health analysers.
	var/conciousness_name = "Conciousness"

	//A mob that represents the person in this brain
	var/mob/living/brainmob

//AI is handled in the brain.
//If you transplant a mechanical brain into a different mob, the new mob will act like the old one.
//Returns a string of the action the mob wants to perform.
/obj/item/nbodypart/brain/proc/handle_ai(mob/living/ourmob)
	return

/obj/item/nbodypart/brain/proc/adjust_pain(mob/living/victim, delta = 0)
	//Store previous pain
	var/previous_pain = pain
	//Add on the delta
	pain += delta

	var/prev_conciousness = victim.conciousness
	//Set new conciousness.
	victim.conciousness += (previous_pain - pain) * PAIN_CONCIOUSNESS_MULTIPLIER
	//Update the conciousness and effecting stats
	victim.update_conciousness(prev_conciousness)

//Gets the amount of pain
/obj/item/nbodypart/brain/proc/get_pain()
	if(feels_pain)
		return pain
	else
		return 0
