/datum/skill/coordination

/datum/skill/coordination/remove_effects(mob/living/owner)
	REMOVE_TRAIT(owner, TRAIT_WEAPON_INACCURACY, SOURCE_STATS)

/datum/skill/coordination/update_effect(mob/living/owner)
	ADD_MULTIPLICATIVE_TRAIT(owner, TRAIT_WEAPON_INACCURACY, SOURCE_STATS, range(2, 0.5))
	ADD_CUMULATIVE_TRAIT(owner, TRAIT_WEAPON_INACCURACY, SOURCE_STATS, range(20, 0))
