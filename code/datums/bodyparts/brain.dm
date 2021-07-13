
//===================
// Generic Brain
//===================

/obj/item/nbodypart/brain
	name = "brain"

	//Squishy
	maxHealth = 15

	//Brain is inside the head
	bodypart_internal = TRUE
	//Brain is pretty small.
	bodypart_size = 4
	//Does the brain feel pain?
	var/feels_pain = TRUE
	//Amount of pain on the mob. Affects conciousness.
	var/pain = 0

	//Name of conciousness. Changes the name of the conciousness stat on health analysers.
	var/conciousness_name = "Conciousness"

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

//Destroying the brain kills the owner.
/obj/item/nbodypart/brain/destroyed()
	return BODYPART_DESTROY_KILL

//===================
// Robotic Brain
//===================

/obj/item/nbodypart/brain/robotic
	name = "artifical processing unit"
	conciousness_name = "Processing"
	feels_pain = FALSE
	//Deciseconds of stun when hit by a heavy EMP.
	var/emp_vulnerability = 200

/obj/item/nbodypart/brain/robotic/emp_act(severity)
	. = ..()
	if(owner)
		to_chat(owner, "<span class='warning'>Electronic Pulse D[scramble_message_replace_chars("etected.", 70)]</span>")
		owner.Stun(emp_vulnerability / EMP_HEAVY)
