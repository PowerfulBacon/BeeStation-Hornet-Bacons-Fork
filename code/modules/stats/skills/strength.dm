/datum/skill/strength
	var/_steps = 0

/datum/skill/strength/remove_effects(mob/living/owner)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)
	REMOVE_TRAIT(owner, TRAIT_PUNCH_DAMAGE, SOURCE_STATS)
	REMOVE_TRAIT(owner, TRAIT_ITEM_SLOWDOWN_MULTIPLIER, SOURCE_STATS)

/datum/skill/strength/update_effect(mob/living/owner)
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(intercept_examine))
	if (level >= 19)
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(intercept_movement))
	// Strength
	ADD_MULTIPLICATIVE_TRAIT(owner, TRAIT_PUNCH_DAMAGE, SOURCE_STATS, range(1.4, 0.6))
	ADD_MULTIPLICATIVE_TRAIT(owner, TRAIT_ITEM_SLOWDOWN_MULTIPLIER, SOURCE_STATS, range(0.5, 1.5))

/datum/skill/strength/proc/intercept_movement(mob/living/source, atom/oldLoc, forced)
	SIGNAL_HANDLER
	if (_steps++%2 != 0)
		return
	for (var/mob/living/other in range(3, source))
		if (challenge(other.skills.strength, -5))
			shake_camera(other, 0.5 SECONDS, 0.3)
	playsound(source, 'sound/effects/meteorimpact.ogg', 20, TRUE, extrarange=SHORT_RANGE_SOUND_EXTRARANGE)

/datum/skill/strength/proc/intercept_examine(mob/living/source, mob/living/carbon/user, list/examine_list)
	SIGNAL_HANDLER
	if (!istype(user))
		return
	// Higher values = you are stronger
	var/strength_diff = level - user.skills.strength.level
	switch (strength_diff)
		if (-20 to -8)
			examine_list += "[source.p_they()] look[source.p_s()] significantly stronger than you."
		if (-7 to -3)
			examine_list += "[source.p_they()] look[source.p_s()] stronger than you."
		if (-2 to 2)
			examine_list += "[source.p_they()] look[source.p_s()] roughly similar in strength to you."
		if (3 to 7)
			examine_list += "[source.p_they()] look[source.p_s()] weaker than you."
		if (8 to 20)
			examine_list += "[source.p_they()] look[source.p_s()] significantly weaker than you."
