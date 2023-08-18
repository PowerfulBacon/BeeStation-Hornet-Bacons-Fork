/obj/item/exosuit_module/hydraulic_leg
	name = "hydraulic leg"
	desc = "A hydraulic system that spans the limbs of the exosuit, resulting in the apparent weight of the suit being much lower. Uses a small amount of power when moving."
	// We need 20 power per step
	power_cost = 20
	height = 3
	width = 1
	weight = 4

/obj/item/exosuit_module/hydraulic_leg/installed(obj/item/clothing/suit/space/hardsuit/exosuit/parent)
	// Run this proc to activate the module on installation, if we have power
	auto_consume_power()

/obj/item/exosuit_module/hydraulic_leg/suit_equipped(mob/wearer)
	..()
	// Consume power on move
	RegisterSignal(wearer, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/obj/item/exosuit_module, auto_consume_power))

/obj/item/exosuit_module/hydraulic_leg/suit_unequipped(mob/wearer)
	..()
	UnregisterSignal(wearer, COMSIG_MOVABLE_MOVED)

/obj/item/exosuit_module/hydraulic_leg/on_enable()
	exosuit.apparent_weight -= 10
	exosuit.update_weight()

/obj/item/exosuit_module/hydraulic_leg/on_disable()
	exosuit.apparent_weight += 10
	exosuit.update_weight()
