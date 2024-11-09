/datum/character_stats/dna
	/// Affects item slowdown, punch, melee combat and combat arts
	/// Value between 1 and 5
	/// Transfers based on DNA
	VAR_PRIVATE/strength
	/// Affects base movement speed
	/// Value between 1 and 5
	/// Transfers based on DNA
	VAR_PRIVATE/agility
	/// Affects stamina resistance and health before crit
	/// Value between 1 and 5
	/// Transfers based on DNA
	VAR_PRIVATE/resilience

/datum/character_stats/dna/proc/copy()
	var/datum/character_stats/dna/stats = new()
	stats.strength = strength
	stats.agility = agility
	stats.resilience = resilience
	return stats

/datum/character_stats/mind
	/// Affects gun accuracy and action speed for items performed with hands
	/// Value between 1 and 5
	/// Transfers based on the mind
	VAR_PRIVATE/coordination
	/// Affects hackability, unlocks unique and powerful crafting recipes
	/// Value between 1 and 5
	/// Transfers based on the mind
	VAR_PRIVATE/intelligence
	/// Affects RNG from random roles
	/// Value between 1 and 5
	/// Transfers based on the mind
	VAR_PRIVATE/luck

/datum/character_stats/mind/proc/copy()
	var/datum/character_stats/mind/stats = new()
	stats.coordination = coordination
	stats.intelligence = intelligence
	stats.luck = luck
	return stats

/// Serves as a proxy for DNA and mind stats, so that they can be fetched without having to search
/// all over the place for them
/datum/character_stats/character
	var/mob/living/carbon/owner

/// Proxy type that collates stats from DNA and mind
/datum/character_stats/character/New(mob/living/carbon/owner)
	. = ..()
	src.owner = owner

/datum/character_stats/character/proc/adjust_strength(minimum, maximum)
	var/proportion = CLAMP01(owner.dna.dna_stats.strength - 1 / 4)
	return (maximum - minimum) * proportion + minimum

/datum/character_stats/character/proc/update_stats()
	ADD_MULTIPLICATIVE_TRAIT(owner.dna.species, TRAIT_PUNCH_DAMAGE, SOURCE_STATS, adjust_strength(0.6, 1.4))
