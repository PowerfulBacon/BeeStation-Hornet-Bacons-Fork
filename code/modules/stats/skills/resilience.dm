/datum/skill/resilience

/datum/skill/resilience/remove_effects(mob/living/owner)
	owner.crit_threshold = 0
	REMOVE_TRAIT(owner, TRAIT_STUNRESISTANCE, SOURCE_STATS)
	REMOVE_TRAIT(owner, TRAIT_BLEED_RESISTANCE, SOURCE_STATS)

/datum/skill/resilience/update_effect(mob/living/owner)
	// Resilience effects
	// - Slight changes to crit thresholds
	// - Greatly increased stun resistance
	// - Bleeding rate reduced
	owner.crit_threshold = range(-18, 18)
	ADD_MULTIPLICATIVE_TRAIT(owner, TRAIT_STUNRESISTANCE, SOURCE_STATS, range(0.8, 1.5))
	ADD_MULTIPLICATIVE_TRAIT(owner, TRAIT_BLEED_RESISTANCE, SOURCE_STATS, range(0.5, 1.5))
