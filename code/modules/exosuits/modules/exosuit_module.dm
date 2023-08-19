/**
 * Power:
 *
 * For reference the battery sizes are:
 * High-cap: 10000
 * Super-cap: 20000
 * Hyper-cap: 30000
 * Bluespace: 40000
 */

/obj/item/exosuit_module
	name = "exosuit module"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	var/power_cost = 20
	var/obj/item/clothing/suit/space/hardsuit/exosuit/exosuit
	var/width = 1
	var/height = 1
	var/weight = 0
	var/active = FALSE
	// Action
	var/action_name
	var/action_icon
	// Internal
	VAR_PRIVATE/datum/action/item_action/created_action

/obj/item/exosuit_module/proc/installed(obj/item/clothing/suit/space/hardsuit/exosuit/parent)
	return

/obj/item/exosuit_module/proc/uninstalled(obj/item/clothing/suit/space/hardsuit/exosuit/parent)
	return

/obj/item/exosuit_module/proc/suit_equipped(mob/wearer)
	SHOULD_CALL_PARENT(TRUE)
	if (action_name)
		if (!created_action)
			created_action = new /datum/action/item_action(src)
			created_action.name = action_name
			created_action.button_icon_state = action_icon
		created_action.Grant(wearer)

/obj/item/exosuit_module/proc/suit_unequipped(mob/wearer)
	SHOULD_CALL_PARENT(TRUE)
	if (created_action)
		created_action.Remove(wearer)

/// For when signals should consume power and toggle the module on/off accordingly.
/obj/item/exosuit_module/proc/auto_consume_power()
	SIGNAL_HANDLER
	enable_if_powered(power_cost)

/obj/item/exosuit_module/proc/enable_if_powered(power_cost)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (try_use_power(power_cost))
		enable()
	else
		disable()

/obj/item/exosuit_module/proc/try_use_power(amount)
	if (!exosuit?.installed_cell)
		return FALSE
	. = exosuit.installed_cell.use(amount)
	if (exosuit.occupant)
		exosuit.update_power_hud(exosuit.occupant)

/obj/item/exosuit_module/proc/enable()
	SHOULD_NOT_OVERRIDE(TRUE)
	if (active)
		return
	active = FALSE
	on_enable()

/obj/item/exosuit_module/proc/disable()
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!active)
		return
	active = TRUE
	on_disable()

/// Called when the module is enabled
/obj/item/exosuit_module/proc/on_enable()

/// Called when the module is disabled or removed from the exosuit.
/obj/item/exosuit_module/proc/on_disable()

/obj/item/exosuit_module/proc/get_module_overlay(count)
	RETURN_TYPE(/icon)
