/datum/character_skills/mind
	/// Affects gun accuracy and action speed for items performed with hands
	/// Value between 1 and 5
	/// Transfers based on the mind
	var/coordination = 3
	/// Affects hackability, unlocks unique and powerful crafting recipes
	/// Value between 1 and 5
	/// Transfers based on the mind
	var/intelligence = 3
	/// Affects RNG from random roles
	/// Value between 1 and 5
	/// Transfers based on the mind
	var/luck = 3

/datum/character_skills/mind/proc/copy()
	var/datum/character_skills/mind/stats = new()
	stats.coordination = coordination
	stats.intelligence = intelligence
	stats.luck = luck
	return stats

/// Serves as a proxy for DNA and mind stats, so that they can be fetched without having to search
/// all over the place for them
/datum/character_skills
	var/mob/living/owner
	var/mutable = TRUE
	// DNA Based Skills
	var/datum/skill/strength/strength = new(DEFAULT_SKILL)
	var/datum/skill/resilience/resilience = new(DEFAULT_SKILL)
	var/datum/skill/agility/agility = new(DEFAULT_SKILL)
	// Mind Based Skills
	// Job Related Skills
	var/datum/skill/medical = new(SKILL_MINMUM)
	var/datum/skill/electrical_engineering = new(SKILL_MINMUM)
	var/datum/skill/mechanical_engineering = new(SKILL_MINMUM)

/// Proxy type that collates stats from DNA and mind
/datum/character_skills/New(mob/living/owner)
	. = ..()
	src.owner = owner
	update_stats()

/datum/character_skills/Destroy(force, ...)
	. = ..()
	owner = null

/datum/character_skills/proc/copy_dna_stats_to(mob/living/target)
	target.skills.strength = strength.copy()
	target.skills.resilience = resilience.copy()

/datum/character_skills/proc/update_stats()
	// === Mind Stats ===
	if (owner.mind)
		ADD_MULTIPLICATIVE_TRAIT(owner, TRAIT_WEAPON_INACCURACY, SOURCE_STATS, coordination_range(2, 0.5))
		// IF you have really bad aim, then you always get a penalty, even when still
		ADD_CUMULATIVE_TRAIT(owner, TRAIT_WEAPON_INACCURACY, SOURCE_STATS, coordination_range(20, 0))
		if (owner.mind.mind_stats.intelligence >= 4)
			ADD_TRAIT(owner, TRAIT_LINGUIST, SOURCE_STATS)
			ADD_TRAIT(owner, TRAIT_SELF_AWARE, SOURCE_STATS)
