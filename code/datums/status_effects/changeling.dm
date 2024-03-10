/datum/status_effect/changeling
	var/datum/antagonist/changeling/ling
	var/chem_per_tick = 1

/datum/status_effect/changeling/on_apply()
	ling = is_changeling(owner)
	if(!ling)
		return FALSE
	return TRUE

/datum/status_effect/changeling/tick()
	if(ling.chem_charges < chem_per_tick)
		qdel(src)
		return FALSE
	ling.chem_charges -= chem_per_tick
	return TRUE

// =============================
// Changeling Armblade
// =============================

/datum/status_effect/changeling/armblade
	id = "armblade"
	chem_per_tick = 1
	tick_interval = 2 SECONDS

/datum/status_effect/changeling/armblade/on_apply()
	if (!..())
		return FALSE
	return TRUE

// =============================
// Changeling Fleshmend
//
// Used by changelings to rapidly heal
// Being on fire will suppress this healing
// =============================
/datum/status_effect/changeling/fleshmend
	id = "fleshmend"
	alert_type = /atom/movable/screen/alert/status_effect/fleshmend
	chem_per_tick = 1
	tick_interval = 1 SECONDS
	var/ticks_passed = 0

/datum/status_effect/changeling/fleshmend/on_apply()
	if (!..())
		return FALSE
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACKBY, PROC_REF(stop_healing))
	return TRUE

/datum/status_effect/changeling/fleshmend/tick()
	ticks_passed ++
	if(owner.on_fire)
		linked_alert.icon_state = "fleshmend_fire"
		return
	else
		linked_alert.icon_state = "fleshmend"
	if(ticks_passed < 2)
		return
	else if(ticks_passed == 2)
		to_chat(owner, "<span class=changeling>We begin to repair our tissue damage...</span>")
	var/previous_health = owner.health
	//Heals 2 brute per second.
	owner.adjustBruteLoss(-2, FALSE, TRUE)
	//Heals 1 fireloss per second
	owner.adjustFireLoss(-1, FALSE, TRUE)
	//Heals 5 oxyloss per second
	owner.adjustOxyLoss(-5, FALSE, TRUE)
	//Heals 0.5 cloneloss per second
	owner.adjustCloneLoss(-0.5, FALSE, TRUE)
	// No change
	if (previous_health == owner.health)
		qdel(src)
		return
	// Deals 0.5 stamina damage per second
	owner.adjustStaminaLoss(0.5, TRUE, TRUE)

/datum/status_effect/changeling/fleshmend/proc/stop_healing(datum/source, mob/user, obj/item/source)
	if (!source.force || source.damtype == STAMINA)
		return
	owner.balloon_alert(owner, "Your healing was interrupted!")
	qdel(src)

/datum/status_effect/changeling/fleshmend/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_ITEM_ATTACKBY)

/atom/movable/screen/alert/status_effect/fleshmend
	name = "Fleshmend"
	desc = "Our wounds are rapidly healing. <i>This effect is prevented if we are on fire.</i>"
	icon_state = "fleshmend"

// =============================
// Changeling invisibility
// =============================

/datum/status_effect/changeling/camoflague
	id = "changelingcamo"
	alert_type = /atom/movable/screen/alert/status_effect/changeling_camoflague
	tick_interval = 5

/datum/status_effect/changeling/camoflague/tick()
	if(!..())
		return
	if(owner.on_fire)
		large_increase()
		return
	owner.alpha = max(owner.alpha - 20, 0)

/datum/status_effect/changeling/camoflague/on_apply()
	if(!..())
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(slight_increase))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(large_increase))
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(large_increase))
	RegisterSignal(owner, COMSIG_ATOM_BUMPED, PROC_REF(slight_increase))
	return TRUE

/datum/status_effect/changeling/camoflague/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_APPLY_DAMGE, COMSIG_ATOM_BUMPED))
	owner.alpha = 255

/datum/status_effect/changeling/camoflague/proc/slight_increase()
	owner.alpha = min(owner.alpha + 15, 255)

/datum/status_effect/changeling/camoflague/proc/large_increase()
	owner.alpha = min(owner.alpha + 50, 255)

/atom/movable/screen/alert/status_effect/changeling_camoflague
	name = "Camoflague"
	desc = "We have adapted our skin to refract light around us."
	icon_state = "changeling_camo"

// =============================
// Changeling mindshield
// =============================

/datum/status_effect/changeling/mindshield
	id = "changelingmindshield"
	alert_type = /atom/movable/screen/alert/status_effect/changeling_mindshield
	tick_interval = 30

/datum/status_effect/changeling/mindshield/tick()
	if(..() && owner.on_fire)
		qdel(src)

/datum/status_effect/changeling/mindshield/on_apply()
	if(!..())
		return FALSE
	ADD_TRAIT(owner, TRAIT_FAKE_MINDSHIELD, CHANGELING_TRAIT)
	owner.sec_hud_set_implants()
	return TRUE

/datum/status_effect/changeling/mindshield/on_remove()
	REMOVE_TRAIT(owner, TRAIT_FAKE_MINDSHIELD, CHANGELING_TRAIT)
	owner.sec_hud_set_implants()

/atom/movable/screen/alert/status_effect/changeling_mindshield
	name = "Fake Mindshield"
	desc = "We are emitting a signal, causing us to appear as mindshielded to security HUDs."
	icon_state = "changeling_mindshield"
