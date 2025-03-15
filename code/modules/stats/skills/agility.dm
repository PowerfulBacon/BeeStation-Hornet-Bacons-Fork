/datum/skill/agility

/datum/skill/agility/remove_effects(mob/living/owner)
	REMOVE_TRAIT(owner, TRAIT_SKITTISH, SOURCE_STATS)

/datum/skill/agility/update_effect(mob/living/owner)
	// Agility
	if (level >= 12)
		ADD_TRAIT(owner, TRAIT_SKITTISH, SOURCE_STATS)
