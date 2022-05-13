/datum/body
	//Our mob
	var/mob/mob
	//Our manipulation actionspeed modifier
	var/datum/actionspeed_modifier/manipulation_actionspeed_modifier/manipulation
	//The accepted type (and subtypes) of blood for this body
	var/accepted_blood_type
	//The maximum amount of blood
	var/maximum_blood
	//The default amount of blood
	var/default_blood
	//The minimum amount of blood that a mob needs to stay alive
	var/minimum_safe_blood
	//Pain amount
	var/pain_amount
	//The pain threshold for soft-crit
	var/pain_crit
	//The root bodypart component
	var/datum/bodypart/root
	//The current mob stats
	var/list/functional_stats = list(
		STAT_CONCIOUSNESS = 0,
		STAT_MOVEMENT = 0,
		STAT_MANIPULATION = 0,
		STAT_SIGHT = 0,
		STAT_HEARING = 0,
	)
	var/list/cumulative_stats = list(
		STAT_CONCIOUSNESS = 0,
		STAT_MOVEMENT = 0,
		STAT_MANIPULATION = 0,
		STAT_SIGHT = 0,
		STAT_HEARING = 0,
	)

/datum/body/New(mob/mob)
	. = ..()
	src.mob = mob

/datum/body/proc/adjust_pain(add_amount)
	//Calculate conciousness affect on pain
	//At the pain crit level, conciousness should be ~40
	//Conciousness gets reduced by a percentage from pain
	pain_amount += add_amount
	recalculate_conciousness_multiplier()

/// Recalculates the conciousnes multiplier caused by pain
/datum/body/proc/recalculate_conciousness_multiplier()
	//Multiply conciousness stat by pain
	functional_stats[STAT_CONCIOUSNESS] = cumulative_stats[STAT_CONCIOUSNESS] * ((1 - min(pain_amount / pain_crit, 1)) * 0.8 + 0.2)
	//Update conciousness value
	update_conciousnses()

/// Called in reaction to conciousness being updated
/datum/body/proc/update_conciousnses()
	//Other stats are multiplied by conciousness
	functional_stats[STAT_MOVEMENT] = cumulative_stats[STAT_MOVEMENT] * functional_stats[STAT_CONCIOUSNESS]
	functional_stats[STAT_MANIPULATION] = cumulative_stats[STAT_MANIPULATION] * functional_stats[STAT_CONCIOUSNESS]
	functional_stats[STAT_SIGHT] = cumulative_stats[STAT_SIGHT] * functional_stats[STAT_CONCIOUSNESS]
	functional_stats[STAT_HEARING] = cumulative_stats[STAT_HEARING] * functional_stats[STAT_CONCIOUSNESS]
	//Update movespeed modifiers
	on_movement_updated()
	//Update actionspeed modifiers
	on_manipulation_updated()
	//Update sight
	on_sight_updated()

/datum/body/proc/on_sight_updated()
	//Clear sight modifier
	if(functional_stats[STAT_SIGHT] >= 100)
		clear_fullscreen("crit")
		return
	if(functional_stats[STAT_SIGHT] <= 0)
		//Full blindness
		overlay_fullscreen("crit", /atom/movable/screen/fullscreen/blind)
		return
	var/severity = round((100 - functional_stats[STAT_SIGHT]) * 0.1)
	overlay_fullscreen("crit", /atom/movable/screen/fullscreen/crit, severity)

/// Called when the movement stat is updated
/datum/body/proc/on_movement_updated()
	if(functional_stats[STAT_MOVEMENT] == 100 || HAS_TRAIT(mob, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN)
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING)
		return
	var/slowdown_amount = (100 - functional_stats[STAT_MOVEMENT]) / 75
	add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN, override = TRUE, multiplicative_slowdown = slowdown_amount, blacklisted_movetypes = FLOATING|FLYING)
	add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING, override = TRUE, multiplicative_slowdown = slowdown_amount / 3, movetypes = FLOATING)

/// Called when the manipulation stat is updated
/datum/body/proc/on_manipulation_updated()
	if(!manipulation)
		manipulation = new()
		mob.add_actionspeed_modifier(manipulation, FALSE)
	manipulation.multiplicative_slowdown = (100 - functional_stats[STAT_MANIPULATION]) / 75
	mob.update_actionspeed()
