/datum/gear/donator
	sort_category = "Donator"

/datum/gear/donator/can_purchase(var/client/C)
	return cost < C.get_metabalance() && IS_PATRON(C.ckey)

/datum/gear/donator/spawn_item(location, metadata)
	var/mob/M = location
	if(istype(M) && !IS_PATRON(M.ckey))
		to_chat(M, "<span class='warning'>Unable to equip you with [display_name], you are not a patreon!</span>")
		return
	return ..()
