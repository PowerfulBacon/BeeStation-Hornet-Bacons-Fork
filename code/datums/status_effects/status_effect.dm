//Status effects are used to apply temporary or permanent effects to mobs. Mobs are aware of their status effects at all times.
//This file contains their code, plus code for applying and removing them.
//When making a new status effect, add a define to status_effects.dm in __DEFINES for ease of use!

/datum/status_effect
	var/id = "effect" //Used for screen alerts.
	var/duration = -1 //How long the status effect lasts in DECISECONDS. Enter -1 for an effect that never ends unless removed through some means.
	var/tick_interval = 10 //How many deciseconds between ticks, approximately. Leave at 10 for every second. Setting this to -1 will stop processing if duration is also unlimited.
	var/mob/living/owner //The mob affected by the status effect.
	var/status_type = STATUS_EFFECT_UNIQUE //How many of the effect can be on one mob, and what happens when you try to add another
	var/on_remove_on_mob_delete = FALSE //if we call on_remove() when the mob is deleted
	var/examine_text //If defined, this text will appear when the mob is examined - to use he, she etc. use "SUBJECTPRONOUN" and replace it in the examines themselves
	var/alert_type = /atom/movable/screen/alert/status_effect //the alert thrown by the status effect, contains name and description
	var/atom/movable/screen/alert/status_effect/linked_alert = null //the alert itself, if it exists

/datum/status_effect/New(list/arguments)
	on_creation(arglist(arguments))

/datum/status_effect/proc/on_creation(mob/living/new_owner, ...)
	if(new_owner)
		owner = new_owner
	if(owner)
		owner.body.add_status_effect(src)
	if(!owner || !on_apply())
		qdel(src)
		return
	if(duration != -1)
		duration = world.time + duration
	tick_interval = world.time + tick_interval
	if(alert_type)
		var/atom/movable/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
		A.attached_effect = src //so the alert can reference us, if it needs to
		linked_alert = A //so we can reference the alert, if we need to
	if(duration > 0 || initial(tick_interval) > 0) //don't process if we don't care
		START_PROCESSING(SSfastprocess, src)
	return TRUE

/datum/status_effect/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		linked_alert = null
		owner.clear_alert(id)
		owner.body.clear_status_effect(src)
		on_remove()
		owner = null
	return ..()

/datum/status_effect/process()
	if(!owner)
		qdel(src)
		return
	if(tick_interval < world.time)
		tick()
		tick_interval = world.time + initial(tick_interval)
	if(duration != -1 && duration < world.time)
		qdel(src)

/datum/status_effect/proc/on_apply() //Called whenever the buff is applied; returning FALSE will cause it to autoremove itself.
	return TRUE
/datum/status_effect/proc/tick() //Called every tick.
/datum/status_effect/proc/on_remove() //Called whenever the buff expires or is removed; do note that at the point this is called, it is out of the owner's status_effects but owner is not yet null
/datum/status_effect/proc/be_replaced() //Called instead of on_remove when a status effect is replaced by itself or when a status effect with on_remove_on_mob_delete = FALSE has its mob deleted
	owner.clear_alert(id)
	owner.body.clear_status_effect(src)
	owner = null
	qdel(src)

/datum/status_effect/proc/refresh()
	var/original_duration = initial(duration)
	if(original_duration == -1)
		return
	duration = world.time + original_duration

//clickdelay/nextmove modifiers!
/datum/status_effect/proc/nextmove_modifier()
	return 1

/datum/status_effect/proc/nextmove_adjust()
	return 0

////////////////
// ALERT HOOK //
////////////////

/atom/movable/screen/alert/status_effect
	name = "Curse of Mundanity"
	desc = "You don't feel any different..."
	var/datum/status_effect/attached_effect

/atom/movable/screen/alert/status_effect/Destroy()
	attached_effect = null //Don't keep a ref now
	return ..()
