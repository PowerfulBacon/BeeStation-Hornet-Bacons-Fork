/datum/mutation/human/nyagger

	name = "Nyagger"
	desc = "Turns a person into a Nyagger. They deserve it though."
	quality = NEGATIVE
	locked = TRUE
	text_gain_indication = "<span class='danger'>You feel like your brain is a pile of goop!.</span>"
	var/given_pacifism = FALSE

/datum/mutation/human/nyagger/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	if(iscatperson(owner))
		if(HAS_TRAIT(owner, TRAIT_PACIFISM))
			return
		ADD_TRAIT(owner, TRAIT_PACIFISM, GENETIC_MUTATION)
		given_pacifism = TRUE

/datum/mutation/human/nyagger/on_life(mob/living/carbon/human/owner)
	owner.adjustOxyLoss(-1)
	if(prob(15))
		owner.emote("gasp")

/datum/mutation/human/nyagger/on_losing(mob/living/carbon/human/owner)
	if(!given_pacifism)
		return
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, GENETIC_MUTATION)
