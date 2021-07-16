/datum/injury
	//Shared
	var/name
	var/pain_per_damage
	var/bleedrate = 0
	var/blunt_type = null		//The blunt version of this injury.
	//Instanced
	var/source_text
	var/damage
	var/pain
	var/tended = FALSE

/datum/injury/New(datum/body/victim, obj/item/nbodypart/target_bodypart, damage, source_text)
	. = ..()
	src.damage = damage
	src.source_text = source_text
	pain = damage * pain_per_damage
	victim.bleed_rate += bleedrate
	target_bodypart.apply_damage(damage)
	victim.get_brain()?.adjust_pain(pain)

/datum/injury/proc/can_tend(obj/item/stack/medical/tending)
	if(tended)
		return FALSE
	if(type in tending.valid_injuries)
		return TRUE
	return FALSE

/datum/injury/proc/tend(datum/body/victim, obj/item/nbodypart/target_bodypart, obj/item/stack/medical/tending)
	tended = TRUE
	victim.bleed_rate -= bleedrate
	target_bodypart.apply_damage(-damage * (1 - tending.tended_damage_multiplier))
	victim.get_brain()?.adjust_pain(-pain * (1 - tending.tended_pain_multiplier))
