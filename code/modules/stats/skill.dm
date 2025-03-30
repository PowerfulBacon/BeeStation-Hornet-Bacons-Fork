/datum/skill
	var/level = 0

/datum/skill/New(level)
	. = ..()
	src.level = level

/datum/skill/proc/update_effect(mob/living/owner)
	return

/datum/skill/proc/remove_effects(mob/living/owner)
	return

/datum/skill/proc/copy()
	var/datum/skill/copy = new type()
	copy.level = level
	return copy

/datum/skill/proc/linear_range(minimum, maximum)
	var/proportion = CLAMP01((level - SKILL_MINMUM) / (SKILL_MAXIMUM - SKILL_MINMUM))
	return (maximum - minimum) * proportion + minimum

/datum/skill/proc/linear_bonus(bonus_level, minimum, maximum)
	if (level <= bonus_level)
		return minimum
	var/proportion = CLAMP01((level - bonus_level) / (SKILL_MAXIMUM - bonus_level))
	return (maximum - minimum) * proportion + minimum

/datum/skill/proc/skill_check_easy(critical = FALSE, bias = 0)
	var/dice = rand(1, 20)
	var/roll = dice + level + bias
	if (roll > 8)
		if (dice == 20 && critical)
			return CRITICAL_SUCCESS
		return SUCCESS
	else
		if (dice == 1 && level <= 4 && critical)
			return CRITICAL_FAILURE
		return FAILURE

/datum/skill/proc/skill_check_medium(critical = FALSE, bias = 0)
	var/dice = rand(1, 20)
	var/roll = dice + level + bias
	if (roll > 14)
		if (dice == 20 && critical)
			return CRITICAL_SUCCESS
		return SUCCESS
	else
		if (dice == 1 && level <= 8 && critical)
			return CRITICAL_FAILURE
		return FAILURE

/datum/skill/proc/skill_check_hard(critical = FALSE, bias = 0)
	var/dice = rand(1, 20)
	var/roll = dice + level + bias
	if (roll > 20)
		if (dice == 20 && critical)
			return CRITICAL_SUCCESS
		return SUCCESS
	else
		if (dice == 1 && level <= 14 && critical)
			return CRITICAL_FAILURE
		return FAILURE

/datum/skill/proc/skill_check_very_hard(critical = FALSE, bias = 0)
	var/dice = rand(1, 20)
	var/roll = dice + level + bias
	if (roll > 26)
		if (dice == 20 && critical)
			return CRITICAL_SUCCESS
		return SUCCESS
	else
		if (dice == 1 && level <= 18 && critical)
			return CRITICAL_FAILURE
		return FAILURE

/datum/skill/proc/challenge(datum/skill/other, basis = 0)
	var/our_dice = rand(1, 20) + level + basis
	var/their_dice = rand(1, 20) + other.level
	return our_dice > their_dice
