/mob/living/carbon/var/temporary_pain = 0

/mob/living/carbon/proc/pain_life()
	// Temporary pain
	if (temporary_pain)
		temporary_pain = max(0, temporary_pain - PAIN_TEMPORARY_DISSIPATION * 2)
		update_pain()
	// If we are actively in combat, then start releasing adrenaline

	// Some pain, but nothing major
	if (pain < 5)
		return
	// Your limbs start to hurt
	if (pain < 20)
		if (prob(20))
			// Pain message
			var/list/hurt_limbs = list()
			for (var/obj/item/bodypart/part in bodyparts)
				if (part.feels_pain && part.get_damage(TRUE) <= 0)
					continue
				hurt_limbs += part
			to_chat(src, "<span class='danger'>Your [pick(hurt_limbs)] aches...</span>")
		return
	if (pain < 60)
	// Flash the screen read occassionally
	if (pain < 100)

/mob/living/carbon/proc/update_pain()
	var/damage_loss = max((maxHealth - health), staminaloss)
	// Damage loss calculated on body parts that feel pain
	pain = damage_loss * DAMAGE_TO_PAIN_RATE
	// Calculate damage slowdown amount
	if(HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)
		return
	var/pain_slowdown = CLAMP01(pain / PAIN_CRIT_AMOUNT) * MAX_PAIN_SLOWDOWN
	if(pain_slowdown >= 0)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, TRUE, multiplicative_slowdown = pain_slowdown)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying, TRUE, multiplicative_slowdown = pain_slowdown * 0.33)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)

/mob/living/carbon/proc/is_pain_crit()
	return pain > PAIN_CRIT_AMOUNT

/// Puts temporary pain on a mob
/mob/living/carbon/proc/give_temporary_pain(pain_amount, pain_location = BODY_ZONE_CHEST)
	var/obj/item/bodypart/part = get_bodypart(pain_location)
	if (!part || !part.feels_pain)
		return
	if (prob(pain_amount * 3))
		INVOKE_ASYNC(src, PROC_REF(emote), "scream")
		to_chat(src, "<span class='danger'>You feel a sharp sting of pain in your [pain_location].</span>")
	temporary_pain += pain_amount

