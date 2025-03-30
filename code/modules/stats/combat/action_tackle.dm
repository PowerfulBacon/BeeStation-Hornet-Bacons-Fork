/datum/action/tackle
	requires_target = TRUE
	cooldown_time = 10 SECONDS

/datum/action/tackle/on_activate(mob/living/user, atom/target, trigger_flags)
	if (!target.loc)
		return FALSE
	start_cooldown()
	// Dash towards the target location
	var/tackle_dir = get_dir(user, target)
	var/turf/tackle_turf = get_step(user, tackle_dir)
	// Smash into the things on the turfs, damaging objects and mobs
	if (isclosedturf(tackle_turf))
		smash_into(target, user, user.skills.strength.level)
		return TRUE
	for (var/atom/content in tackle_turf.contents)
		if (!content.density && !ismob(content))
			continue
		if (smash_into(content, user, user.skills.strength.level))
			return TRUE
	if (tackle_turf.CanPass(user, tackle_dir))
		user.Move(tackle_turf)
	return TRUE

/datum/action/tackle/proc/smash_into(atom/target, mob/living/user, tackle_damage)
	if (isliving(target))
		var/mob/living/living_target = target
		living_target.adjustStaminaLoss(tackle_damage)
		// Damage required to tackle someone relates to strength difference
		var/damage_required = living_target.maxHealth - living_target.crit_threshold
		// More damage means a higher basis
		var/damage_ratio = living_target.staminaloss / damage_required
		// No damage maens a basis of -10, stam-crit means a basis of 0 and any more
		// damage over that increases the chance of a tackle being successful
		if (living_target.getStaminaLoss() >= living_target.maxHealth || user.skills.strength.challenge(living_target.skills.strength, damage_ratio * 10 - 10))
			// Successful tackle
			user.Knockdown((20 - user.skills.strength.level) * 0.4 SECONDS, ignore_canstun = TRUE)
			living_target.Knockdown((20 - living_target.skills.strength.level) * 0.4 SECONDS)
			living_target.grippedby(user, TRUE)
			// We don't want to stand up unless we explicitly demand it
			user.set_resting(TRUE)
			user.Move(get_turf(living_target))
			user.visible_message(span_warning("[user] tackles [target], pinning them down!"), span_userdanger("You pin down [target]!"))
			to_chat(target, span_userdanger("[user] pins you to the floor!"))
		else
			// Tackle fails
			user.Knockdown((20 - user.skills.strength.level) * 0.4 SECONDS, ignore_canstun = TRUE)
			living_target.Knockdown((20 - living_target.skills.strength.level) * 0.2 SECONDS)
			user.Move(get_turf(living_target))
			user.visible_message(span_warning("[user] tackles [target]!"), span_userdanger("You tackle [target] but fail to get a solid grip!"))
			to_chat(target, span_userdanger("You are thrown to the ground by [user]!"))
		return TRUE
	if (!target.uses_integrity)
		return FALSE
	target.take_damage(tackle_damage)
	return FALSE
