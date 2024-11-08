/datum/character_stats/mind
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

/datum/character_stats/dna
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

/datum/character_stats/dna/proc/copy()
	var/datum/character_stats/dna/dna_stats = new()
	dna_stats.coordination = coordination
	dna_stats.intelligence = intelligence
	dna_stats.luck = luck

/// Proxy type that collates stats from DNA and mind
/datum/character_stats/proxy
	VAR_PRIVATE/strength
	VAR_PRIVATE/agility
	VAR_PRIVATE/resilience
	VAR_PRIVATE/coordination
	VAR_PRIVATE/intelligence
	VAR_PRIVATE/luck

/datum/character_stats/proxy/proc/update_from_dna(datum/dna/dna)

/datum/character_stats/proxy/proc/update_from_mind(datum/mind/mind)

/datum/character_stats/proxy/proc/apply(mob/living/carbon/human/character)

/datum/character_stats/proxy/proc/modify_strength(minimum, maximum)
