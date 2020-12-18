#define ARTIFACT_POWER_PROBABILITY 40

/obj/item/artifact
	name = "artifact"
	desc = "A relic of a forgotten era, it's original purpose unknown."
	var/datum/artifact/power
	var/list/trigger_modes
	var/purpose_unlocked

/obj/item/artifact/examine(mob/user)
	. = ..()
	if(!purpose_unlocked)
		. += "Perhaps science could do something with it."
	else if(power)
		. += "It pulses with a strange energy, it looks like it would do something."
	else
		. += "It seems inert."

/obj/item/artifact/proc/unlock_power()
	purpose_unlocked = TRUE
	if(prob(ARTIFACT_POWER_PROBABILITY))
		power = pick(subtypesof(/datum/artifact))
		trigger_modes = power.trigger_modes
		if(ARTIFACT_TRIGGER_TIME in trigger_modes)
			addtimer(CALLBACK(src, .proc/trigger_power), 600, 6000)

/obj/item/artifact/proc/trigger_power()
	return power.try_trigger(src)

/obj/item/artifact/attack_hand(mob/user)
	if(ARTIFACT_TRIGGER_USE_HAND in trigger_modes)
		return power.try_trigger(user)
	. = ..()

/obj/item/artifact/attack(mob/living/M, mob/living/user)
	if(ARTIFACT_TRIGGER_ATTACK in trigger_modes)
		return power.try_trigger(M)
	. = ..()

/obj/item/artifact/Crossed(atom/movable/AM, oldloc)
	if(ARTIFACT_TRIGGER_CROSS in trigger_modes)
		return power.try_trigger(user)
	. = ..()

/obj/item/artifact/pickup(mob/user)
	if(ARTIFACT_TRIGGER_PICKUP in trigger_modes)
		return power.try_trigger(user)
	. = ..()

//Artifact effects

/datum/artifact
	var/list/trigger_modes
	var/cooldown = 60 SECONDS
	var/next_use_world_time = 0

/datum/artifact/proc/try_trigger(atom/source)
	if(world.time > next_use_world_time)
		trigger_effect(source)
		next_use_world_time = world.time + cooldown

/datum/artifact/proc/trigger_effect(atom/source)
	return
