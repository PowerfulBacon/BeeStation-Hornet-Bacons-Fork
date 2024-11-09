/datum/character_stats/dna
	/// Affects item slowdown, punch, melee combat and combat arts
	/// Value between 1 and 5
	/// Transfers based on DNA
	VAR_PRIVATE/strength = 3
	/// Affects base movement speed
	/// Value between 1 and 5
	/// Transfers based on DNA
	VAR_PRIVATE/agility = 3
	/// Affects stamina resistance and health before crit
	/// Value between 1 and 5
	/// Transfers based on DNA
	VAR_PRIVATE/resilience = 3

/datum/character_stats/dna/proc/copy()
	var/datum/character_stats/dna/stats = new()
	stats.strength = strength
	stats.agility = agility
	stats.resilience = resilience
	return stats

/datum/character_stats/dna/proc/randomise_stats(total_points = 9)
	strength = 0
	agility = 0
	resilience = 0
	while (total_points-- > 0)
		switch (rand(1, 3))
			if (1)
				strength ++
			if (2)
				agility ++
			if (3)
				resilience ++

/datum/character_stats/mind
	/// Affects gun accuracy and action speed for items performed with hands
	/// Value between 1 and 5
	/// Transfers based on the mind
	VAR_PRIVATE/coordination = 3
	/// Affects hackability, unlocks unique and powerful crafting recipes
	/// Value between 1 and 5
	/// Transfers based on the mind
	VAR_PRIVATE/intelligence = 3
	/// Affects RNG from random roles
	/// Value between 1 and 5
	/// Transfers based on the mind
	VAR_PRIVATE/luck = 3

/datum/character_stats/mind/proc/copy()
	var/datum/character_stats/mind/stats = new()
	stats.coordination = coordination
	stats.intelligence = intelligence
	stats.luck = luck
	return stats

/datum/character_stats/mind/proc/randomise_stats(total_points = 9)
	coordination = 0
	intelligence = 0
	luck = 0
	while (total_points-- > 0)
		switch (rand(1, 3))
			if (1)
				coordination ++
			if (2)
				intelligence ++
			if (3)
				luck ++

/// Serves as a proxy for DNA and mind stats, so that they can be fetched without having to search
/// all over the place for them
/datum/character_stats/character
	var/mob/living/carbon/owner

/// Proxy type that collates stats from DNA and mind
/datum/character_stats/character/New(mob/living/carbon/owner)
	. = ..()
	src.owner = owner
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(intercept_examine))
	update_stats()

/datum/character_stats/character/Destroy(force, ...)
	. = ..()
	owner = null

/datum/character_stats/character/proc/adjust_strength(minimum, maximum)
	var/proportion = CLAMP01((UNLINT(owner.dna.dna_stats.strength) - 1) / 4)
	return (maximum - minimum) * proportion + minimum

/datum/character_stats/character/proc/update_stats()
	REMOVE_TRAITS_IN(owner, SOURCE_STATS)
	// === DNA Stats ===
	// Strength stat modifications
	if (owner.dna)
		ADD_MULTIPLICATIVE_TRAIT(owner, TRAIT_PUNCH_DAMAGE, SOURCE_STATS, adjust_strength(0.6, 1.4))
		ADD_MULTIPLICATIVE_TRAIT(owner, TRAIT_ITEM_SLOWDOWN_MULTIPLIER, SOURCE_STATS, adjust_strength(1.5, 0.5))
	// === Mind Stats ===

/datum/character_stats/character/proc/intercept_examine(mob/living/source, mob/living/carbon/user, list/examine_list)
	SIGNAL_HANDLER
	if (!istype(user))
		return
	// Higher values = you are stronger
	var/strength_diff = UNLINT(user.dna.dna_stats.strength) - UNLINT(owner.dna.dna_stats.strength)
	switch (strength_diff)
		if (1 to 2)
			examine_list += "[owner.p_they()] look[owner.p_s()] weaker than you."
		if (3 to 4)
			examine_list += "[owner.p_they()] look[owner.p_s()] significantly weaker than you."
		if (-2 to -1)
			examine_list += "[owner.p_they()] look[owner.p_s()] stronger than you."
		if (-4 to -3)
			examine_list += "[owner.p_they()] look[owner.p_s()] significantly stronger than you."
