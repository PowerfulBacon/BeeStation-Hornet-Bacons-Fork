/datum/injury
	//Name of the injury
	var/name
	//Does the injury stack? If not unique the injury will not be created again if already existing
	var/unique = TRUE
	//Damage
	var/damage = 0
	//Pain
	var/pain_per_damage = 1.2
	//Part
	var/obj/item/nbodypart/part

/datum/injury/New(obj/item/nbodypart/part, damage)
	. = ..()
	src.part = part
	update_damage(damage)

/datum/injury/proc/update_damage(new_damage)
	var/old_damage = damage
	damage = new_damage
	if(damage < 0)
		//Restore damage
		part.update_health(part.health + old_damage)
		//Remove injury
		qdel(src)
		return
	//Restore damage and apply new damage.
	part.update_health(part.health + old_damage - damage)
