/obj/item/exosuit_module/energy_shield
	name = "energy shield"
	desc = "Creates a shield around the suit which blocks incoming attacks."
	power_cost = 200
	height = 3
	width = 2
	weight = 8

/obj/item/exosuit_module/energy_shield/installed(obj/item/clothing/suit/space/hardsuit/exosuit/parent)
	// Run this proc to activate the module on installation, if we have power
	auto_consume_power()

/obj/item/exosuit_module/energy_shield/suit_equipped(mob/wearer)
	..()
	// Consume power on move
	RegisterSignal(wearer, COMSIG_PARENT_ATTACKBY, PROC_REF(consume_if_shielded))

/obj/item/exosuit_module/energy_shield/suit_unequipped(mob/wearer)
	..()
	UnregisterSignal(wearer, COMSIG_PARENT_ATTACKBY)

/obj/item/exosuit_module/energy_shield/on_enable()
	exosuit.AddComponent(/datum/component/shielded)

/obj/item/exosuit_module/energy_shield/on_disable()
	exosuit.TakeComponent(/datum/component/shielded)

/obj/item/exosuit_module/energy_shield/proc/consume_if_shielded()
	var/datum/component/shielded/shield = exosuit.GetComponent(/datum/component/shielded)
	if (shield?.current_charges > 0)
		auto_consume_power()
