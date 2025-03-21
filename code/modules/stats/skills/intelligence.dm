/datum/skill/intelligence

/datum/skill/intelligence/remove_effects(mob/living/owner)
	REMOVE_TRAIT(owner, TRAIT_LINGUIST, SOURCE_STATS)
	REMOVE_TRAIT(owner, TRAIT_SELF_AWARE, SOURCE_STATS)

/datum/skill/intelligence/update_effect(mob/living/owner)
	if (level >= 9)
		ADD_TRAIT(owner, TRAIT_SELF_AWARE, SOURCE_STATS)
	if (level >= 12)
		ADD_TRAIT(owner, TRAIT_LINGUIST, SOURCE_STATS)
