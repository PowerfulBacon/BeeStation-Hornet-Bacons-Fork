/// Serves as a proxy for DNA and mind stats, so that they can be fetched without having to search
/// all over the place for them
/datum/character_skills
	var/mob/living/owner
	var/mutable = TRUE
	var/total_points = SKILL_POINTS
	// DNA Based Skills
	var/datum/skill/strength/strength = new(DEFAULT_SKILL)
	var/datum/skill/resilience/resilience = new(DEFAULT_SKILL)
	var/datum/skill/agility/agility = new(DEFAULT_SKILL)
	// Mind Based Skills
	var/datum/skill/intelligence/intelligence = new(DEFAULT_SKILL)
	var/datum/skill/coordination/coordination = new(DEFAULT_SKILL)

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

/datum/character_skills/proc/copy_mind_stats_to(mob/living/target)

/datum/character_skills/proc/update_stats()
	strength.remove_effects(owner)
	resilience.remove_effects(owner)
	agility.remove_effects(owner)
	intelligence.remove_effects(owner)
	coordination.remove_effects(owner)

	strength.update_effect(owner)
	resilience.update_effect(owner)
	agility.update_effect(owner)
	intelligence.update_effect(owner)
	coordination.update_effect(owner)
