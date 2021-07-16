
/mob/living
	var/datum/body/body = /datum/body

/mob/living/Initialize()
	. = ..()
	if(!istype(body))
		body = new body()

//TODO interaction procs
/mob/living/proc/help_shake_act(mob/living/target)
	return

/mob/living/proc/grab_act(mob/living/target)
	return

/mob/living/proc/check_injuries(mob/living/target)
	return

/mob/living/proc/get_armour(def_zone, damage_flag)
	return

//======================
// Damage Procs
//======================

/mob/living/proc/apply_damage_to(damage_amount, bodypart_slot, damage_type, damage_source, allow_internal = FALSE)
	var/obj/item/nbodypart/hit_part = body.get_bodypart(bodypart_slot)
	apply_damage_to_bodypart(hit_part, damage_amount, damage_type, damage_source, allow_internal)

/mob/living/proc/apply_damage_randomly(damage_amount, damage_type, damage_source, allow_internal = FALSE)
	apply_damage(damage_amount, pick(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG), damage_type, damage_source, allow_internal)

// Applies a generic damage to an organ based off of a damage type.
// Will prefere to hit bodyparts with more health% more when the mob has taken less damage.
// If a bodypart is destroyed and more than 20% of the damage is still remaining, damage will be applied to other bodyparts
/mob/living/proc/apply_damage(damage_amount, def_zone, damage_type, damage_source, allow_internal = FALSE)
	var/datum/injury/created_injury
	var/hit_organ = FALSE
	if(allow_internal)
		hit_organ = TRUE
	else
		switch(damage_type)
			if(BULLET)
				hit_organ = TRUE
			if(SHARP)
				hit_organ = prob(30)
	var/obj/item/nbodypart/hit_part = body.get_bodypart_in_zone(def_zone, hit_organ)
	apply_damage_to_bodypart(hit_part, damage_amount, damage_type, damage_source)

/mob/living/proc/apply_damage_to_bodypart(obj/item/nbodypart/hit_part, damage_amount, damage_type, damage_source)
	switch(damage_type)
		if(BLUNT)
			created_injury = new /datum/injury/bruise(body, hit_part, damage_amount, damage_source)
		if(SHARP)
			created_injury = new /datum/injury/cut(body, hit_part, damage_amount, damage_source)
		if(BURN)
			created_injury = new /datum/injury/burn(body, hit_part, damage_amount, damage_source)
		if(BULLET)
			created_injury = new /datum/injury/cut(body, hit_part, damage_amount, damage_source)
		else
			created_injury = new /datum/injury/bruise(body, hit_part, damage_amount, damage_source)
