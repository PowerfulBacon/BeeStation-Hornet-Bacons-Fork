
/obj/item/clothing/suit/space/hardsuit/exosuit
	name = "exosuit base"
	icon = 'icons/mecha/exosuit.dmi'
	worn_icon = 'icons/mecha/exosuit.dmi'
	// Hide everything
	flags_inv = ALL
	// Clicking on it doesn't pick it up
	interaction_flags_item = NONE
	// Cannot be picked up, needs to be entered by dragging your sprite onto it
	w_class = WEIGHT_CLASS_GIGANTIC
	// Set the movesound
	move_sound = list('sound/mecha/mechstep.ogg')
	/// The occupant inside the suit
	var/mob/living/occupant
	/// The power cell installed in the exosuit
	var/obj/item/stock_parts/cell/installed_cell
	/// Is the exosuit currently equipped?
	var/exosuit_equipped = FALSE
	/// How long it takes to enter the exosuit
	var/enter_delay = 6 SECONDS
	/// Base weight of the suit itself
	var/base_weight = 0
	/// Current weight of the exosuit, determines mobility
	var/apparent_weight
	/// How much weight should slow us down by 1 unit
	var/weight_per_slowdown = 10

/obj/item/clothing/suit/space/hardsuit/exosuit/Initialize(mapload)
	. = ..()
	apparent_weight = base_weight
	update_weight()

//================================
// Suit Entering
//================================

/obj/item/clothing/suit/space/hardsuit/exosuit/attack_hand(mob/user)
	. = ..()
	if (. || !user)
		return
	if (!do_after(user, enter_delay, src))
		return TRUE
	equip_suit(user)

/obj/item/clothing/suit/space/hardsuit/exosuit/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	user.visible_message("<span class='notice'>[user] starts placing [M] inside of [src]!</span>", "<span class='notice'>You start placing [M] inside of [src]!</span>")
	if (!do_after(user, enter_delay, src))
		return
	equip_suit(M)

/obj/item/clothing/suit/space/hardsuit/exosuit/proc/equip_suit(mob/living/user)
	if (user.equip_to_slot_if_possible(src, ITEM_SLOT_OCLOTHING))
		return TRUE
	to_chat(user, "<span class='warning'>You cannot equip [src], the suit slot is blocked!</span>")
	playsound(src, 'sound/mecha/mechmove01.ogg', 100)
	SEND_SOUND(user, 'sound/mecha/nominal.ogg')

/obj/item/clothing/suit/space/hardsuit/exosuit/equipped(mob/user, slot)
	. = ..()
	if (slot_flags & slot)
		suit_entered(user)
	else
		suit_exited(user)

/obj/item/clothing/suit/space/hardsuit/exosuit/dropped(mob/user)
	. = ..()
	suit_exited(user)

/obj/item/clothing/suit/space/hardsuit/exosuit/proc/suit_entered(mob/living/user)
	if (exosuit_equipped)
		return
	exosuit_equipped = TRUE
	occupant = user
	RegisterSignal(user, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge_response))
	update_power_hud(user)
	for (var/obj/item/exosuit_module/module in contents)
		module.suit_equipped(user)

/obj/item/clothing/suit/space/hardsuit/exosuit/proc/suit_exited(mob/living/user)
	if (!exosuit_equipped)
		return
	exosuit_equipped = FALSE
	occupant = null
	UnregisterSignal(user, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	clear_huds(user)
	for (var/obj/item/exosuit_module/module in contents)
		module.suit_unequipped(user)

//================================
// Power Mangement
//================================

/obj/item/clothing/suit/space/hardsuit/exosuit/proc/charge_response(datum/source, charge_amount, repairs)
	SIGNAL_HANDLER
	if (!installed_cell)
		return
	installed_cell.give(charge_amount)
	if (occupant)
		update_power_hud(occupant)

//================================
// Attackby Entry
//================================

/obj/item/clothing/suit/space/hardsuit/exosuit/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/stock_parts/cell))
		if (installed_cell)
			return FALSE
		installed_cell = I
		I.forceMove(src)
		update_power_hud(occupant)
	if (istype(I, /obj/item/exosuit_module))
		install_module(I)
		return TRUE
	return ..()

//================================
// Modules
//================================

/obj/item/clothing/suit/space/hardsuit/exosuit/proc/install_module(obj/item/exosuit_module/exosuit_module)
	exosuit_module.forceMove(src)
	apparent_weight += exosuit_module.weight
	update_weight()
	exosuit_module.exosuit = src
	exosuit_module.installed(src)
	if (occupant)
		exosuit_module.suit_equipped(src)

/obj/item/clothing/suit/space/hardsuit/exosuit/proc/update_weight()
	var/weight = max(apparent_weight, 0)
	// Determine the speed
	slowdown = 1 + (weight / weight_per_slowdown)
	drag_slowdown = slowdown
	occupant?.update_movespeed()
