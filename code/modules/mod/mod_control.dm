/// MODsuits, trade-off between armor and utility
/obj/item/mod
	name = "Base MOD"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'

/obj/item/mod/control
	name = "\improper MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments."
	icon_state = "standard-control"
	inhand_icon_state = "mod_control"
	base_icon_state = "control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	strip_delay = 10 SECONDS
	armor_type = /datum/armor/none
	actions_types = list(
		/datum/action/item_action/mod/deploy,
		/datum/action/item_action/mod/activate,
		/datum/action/item_action/mod/panel,
		/datum/action/item_action/mod/module,
		/datum/action/item_action/mod/deploy/ai,
		/datum/action/item_action/mod/activate/ai,
		/datum/action/item_action/mod/panel/ai,
		/datum/action/item_action/mod/module/ai,
	)
	resistance_flags = NONE
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	siemens_coefficient = 0.5
	alternate_worn_layer = HANDS_LAYER+0.1 //we want it to go above generally everything, but not hands
	/// The MOD's theme, decides on some stuff like armor and statistics.
	var/datum/mod_theme/theme = /datum/mod_theme
	/// Looks of the MOD.
	var/skin = "standard"

/obj/item/mod/control/Initialize(mapload, datum/mod_theme/new_theme, new_skin, obj/item/mod/core/new_core)
	. = ..()
	AddComponent(src, /datum/component/modsuit, new_theme || theme, new_skin)
	for(var/obj/item/part as anything in get_parts())
		RegisterSignal(part, COMSIG_ATOM_DESTRUCTION, PROC_REF(on_part_destruction))
	wires = new /datum/wires/mod(src)
	update_speed()
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, PROC_REF(on_potion))

/obj/item/mod/control/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/item/mod/control/item_action_slot_check(slot)
	if(slot & slot_flags)
		return TRUE

// Grant pinned actions to pin owners, gives AI pinned actions to the AI and not the wearer
/obj/item/mod/control/grant_action_to_bearer(datum/action/action)
	if (!istype(action, /datum/action/item_action/mod/pinned_module))
		return ..()
	var/datum/action/item_action/mod/pinned_module/pinned = action
	give_item_action(action, pinned.pinner, slot_flags)

/obj/item/mod/control/Moved(atom/old_loc, movement_dir, forced = FALSE, list/old_locs)
	. = ..()
	if(!wearer || old_loc != wearer || loc == wearer)
		return
	clean_up()

/obj/item/mod/control/allow_attack_hand_drop(mob/user)
	if(user != wearer)
		return ..()
	if(active)
		balloon_alert(wearer, "unit active!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
		return
	for(var/obj/item/part as anything in get_parts())
		if(part.loc != src)
			balloon_alert(user, "parts extended!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return FALSE

/obj/item/mod/control/MouseDrop(atom/over_object)
	if(usr != wearer || !istype(over_object, /atom/movable/screen/inventory/hand))
		return ..()
	if(active)
		balloon_alert(wearer, "unit active!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
		return
	for(var/obj/item/part as anything in get_parts())
		if(part.loc != src)
			balloon_alert(wearer, "parts extended!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return
	if(!wearer.incapacitated())
		var/atom/movable/screen/inventory/hand/ui_hand = over_object
		if(wearer.putItemFromInventoryInHandIfPossible(src, ui_hand.held_index))
			add_fingerprint(usr)
			return ..()

/obj/item/mod/control/wrench_act(mob/living/user, obj/item/wrench)
	if(..())
		return TRUE
	if(seconds_electrified && get_charge() && shock(user))
		return TRUE
	if(open)
		if(!core)
			balloon_alert(user, "no core!")
			return TRUE
		balloon_alert(user, "removing core...")
		wrench.play_tool_sound(src, 100)
		if(!wrench.use_tool(src, user, 3 SECONDS) || !open)
			balloon_alert(user, "interrupted!")
			return TRUE
		wrench.play_tool_sound(src, 100)
		balloon_alert(user, "core removed")
		core.forceMove(drop_location())
		update_charge_alert()
		return TRUE
	return ..()

/obj/item/mod/control/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()
	if(!open)
		balloon_alert(user, "cover closed!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(length(modules))
		var/list/removable_modules = list()
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.removable)
				continue
			removable_modules += module
		var/obj/item/mod/module/module_to_remove = tgui_input_list(user, "Which module to remove?", "Module Removal", removable_modules)
		if(!module_to_remove?.mod)
			return FALSE
		uninstall(module_to_remove)
		module_to_remove.forceMove(drop_location())
		crowbar.play_tool_sound(src, 100)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVED, user)
		return TRUE
	balloon_alert(user, "no modules!")
	playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/obj/item/mod/control/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/paicard))
		if(!open)
			balloon_alert(user, "cover closed!")
			return FALSE
		insert_pai(user, attacking_item)
		return TRUE
	if(istype(attacking_item, /obj/item/mod/module))
		if(!open)
			balloon_alert(user, "cover closed!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		install(attacking_item, user)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_ADDED, user)
		return TRUE
	else if(istype(attacking_item, /obj/item/mod/core))
		if(!open)
			balloon_alert(user, "cover closed!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		if(core)
			balloon_alert(user, "already has core!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		var/obj/item/mod/core/attacking_core = attacking_item
		attacking_core.install(src)
		balloon_alert(user, "core installed")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		update_charge_alert()
		return TRUE
	else if(is_wire_tool(attacking_item) && open)
		wires.interact(user)
		return TRUE
	else if(open && attacking_item.GetID())
		update_access(user, attacking_item.GetID())
		return TRUE
	return ..()

/obj/item/mod/control/get_cell()
	if(!open)
		return
	var/obj/item/stock_parts/cell/cell = get_charge_source()
	if(!istype(cell))
		return
	return cell

/obj/item/mod/control/GetAccess()
	if(ai_controller)
		if(req_access)
			return req_access.Copy()
		else
			return ..()
	else
		return ..()

/obj/item/mod/control/on_emag(mob/user)
	..()
	locked = !locked
	balloon_alert(user, "access [locked ? "locked" : "unlocked"]")

/obj/item/mod/control/emp_act(severity)
	. = ..()
	if(!active || !wearer)
		return
	to_chat(wearer, span_notice("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!"))
	if(. & EMP_PROTECT_CONTENTS)
		return
	selected_module?.deactivate(display_message = TRUE)
	wearer.apply_damage(5 / severity, BURN)
	to_chat(wearer, span_danger("You feel [src] heat up from the EMP, burning you slightly."))
	if(wearer.stat < UNCONSCIOUS && prob(10))
		wearer.emote("scream")

/obj/item/mod/control/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	//if(visuals_only)
	//	set_wearer(outfit_wearer) //we need to set wearer manually since it doesnt call equipped
	quick_activation()

/obj/item/mod/control/doStrip(mob/stripper, mob/owner)
	if(active && !toggle_activate(stripper, force_deactivate = TRUE))
		return
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		retract(null, part)
	return ..()

/obj/item/mod/control/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		var/list/module_icons = module.generate_worn_overlay(standing)
		if(!length(module_icons))
			continue
		. += module_icons

/obj/item/mod/control/update_icon_state()
	icon_state = "[skin]-[base_icon_state][active ? "-sealed" : ""]"
	return ..()

/obj/item/mod/control/proc/get_parts(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part.part_item

/obj/item/mod/control/proc/get_part_datums(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part

/obj/item/mod/control/proc/get_part_datum(obj/item/part)
	RETURN_TYPE(/datum/mod_part)
	var/datum/mod_part/potential_part = mod_parts["[part.slot_flags]"]
	if(potential_part?.part_item == part)
		return potential_part
	for(var/datum/mod_part/mod_part in get_part_datums())
		if(mod_part.part_item == part)
			return mod_part
	CRASH("get_part_datum called with incorrect item [part] passed.")

/obj/item/mod/control/proc/get_part_from_slot(slot)
	var/datum/mod_part/part = mod_parts["[slot]"]
	return part?.part_item

/obj/item/mod/control/proc/get_part_datum_from_slot(slot)
	return mod_parts["[slot]"]

/obj/item/mod/control/proc/set_wearer(mob/living/carbon/human/user)
	if(wearer == user)
		CRASH("set_wearer() was called with the new wearer being the current wearer: [wearer]")
	else if(!isnull(wearer))
		stack_trace("set_wearer() was called with a new wearer without unset_wearer() being called")

	wearer = user
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_SET, wearer)
	RegisterSignal(wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(wearer, COMSIG_SPECIES_GAIN, PROC_REF(on_species_gain))
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_equip()

/obj/item/mod/control/proc/unset_wearer()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	UnregisterSignal(wearer, list(COMSIG_ATOM_EXITED, COMSIG_SPECIES_GAIN))
	wearer.clear_alert("mod_charge")
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_UNSET, wearer)
	wearer = null

/obj/item/mod/control/proc/get_sealed_slots(list/parts)
	var/covered_slots = NONE
	for(var/obj/item/part as anything in parts)
		if(!get_part_datum(part).sealed)
			parts -= part
			continue
		covered_slots |= part.slot_flags
	return covered_slots

/obj/item/mod/control/proc/generate_suit_mask()
	var/list/parts = get_parts(all = TRUE)
	var/covered_slots = get_sealed_slots(parts)
	if(GLOB.mod_masks[skin])
		if(GLOB.mod_masks[skin]["[covered_slots]"])
			return GLOB.mod_masks[skin]["[covered_slots]"]
	else
		GLOB.mod_masks[skin] = list()
	var/icon/slot_mask = icon('icons/blanks/32x32.dmi', "nothing")
	for(var/obj/item/part as anything in parts)
		slot_mask.Blend(icon(part.worn_icon, part.icon_state), ICON_OVERLAY)
	slot_mask.Blend("#fff", ICON_ADD)
	GLOB.mod_masks[skin]["[covered_slots]"] = slot_mask
	return GLOB.mod_masks[skin]["[covered_slots]"]

/obj/item/mod/control/proc/clean_up()
	if(QDELING(src))
		unset_wearer()
		return
	if(active || activating)
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.active)
				continue
			module.deactivate(display_message = FALSE)
		for(var/obj/item/part as anything in get_parts())
			seal_part(part, is_sealed = FALSE)
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		INVOKE_ASYNC(src, PROC_REF(retract), wearer, part, /* instant = */ TRUE) // async to appease spaceman DMM because the branch we don't run has a do_after
	if(active)
		control_activation(is_on = FALSE)
	var/mob/old_wearer = wearer
	unset_wearer()
	old_wearer.temporarilyRemoveItemFromInventory(src)

/obj/item/mod/control/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER

	for(var/obj/item/part in get_parts(all = TRUE))
		if(!(new_species.no_equip_flags & part.slot_flags) || is_type_in_list(new_species, part.species_exception))
			continue
		forceMove(drop_location())
		return

/obj/item/mod/control/proc/quick_module(mob/user)
	if(!length(modules))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.module_type == MODULE_PASSIVE)
			continue
		display_names[module.name] = REF(module)
		var/image/module_image = image(icon = module.icon, icon_state = module.icon_state)
		if(module == selected_module)
			module_image.underlays += image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "module_selected")
		else if(module.active)
			module_image.underlays += image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "module_active")
		if(!COOLDOWN_FINISHED(module, cooldown_timer))
			module_image.add_overlay(image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "module_cooldown"))
		items += list(module.name = module_image)
	if(!length(items))
		return
	var/radial_anchor = src
	if(istype(user.loc, /obj/effect/dummy/phased_mob))
		radial_anchor = get_turf(user.loc) //they're phased out via some module, anchor the radial on the turf so it may still display
	var/pick = show_radial_menu(user, radial_anchor, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/module_reference = display_names[pick]
	var/obj/item/mod/module/picked_module = locate(module_reference) in modules
	if(!istype(picked_module))
		return
	picked_module.on_select()

/obj/item/mod/control/proc/shock(mob/living/user)
	if(!istype(user) || get_charge() < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, get_charge_source(), src, 0.7, check_range)

/obj/item/mod/control/proc/install(obj/item/mod/module/new_module, mob/user)
	for(var/obj/item/mod/module/old_module as anything in modules)
		if(is_type_in_list(new_module, old_module.incompatible_modules) || is_type_in_list(old_module, new_module.incompatible_modules))
			if(user)
				balloon_alert(user, "incompatible with [old_module]!")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return
	var/complexity_with_module = complexity
	complexity_with_module += new_module.complexity
	if(complexity_with_module > complexity_max)
		if(user)
			balloon_alert(user, "above complexity max!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(!new_module.has_required_parts(mod_parts))
		if(user)
			balloon_alert(user, "lacking required parts!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	new_module.forceMove(src)
	modules += new_module
	complexity += new_module.complexity
	new_module.mod = src
	new_module.on_install()
	if(wearer)
		new_module.on_equip()
		var/datum/action/item_action/mod/pinned_module/action = new_module.pinned_to[REF(wearer)]
		if(action)
			action.Grant(wearer)
	if(active && new_module.has_required_parts(mod_parts, need_active = TRUE))
		new_module.on_part_activation()
		new_module.part_activated = TRUE
	if(user)
		balloon_alert(user, "[new_module] added")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/uninstall(obj/item/mod/module/old_module, deleting = FALSE)
	modules -= old_module
	complexity -= old_module.complexity
	if(wearer)
		old_module.on_unequip()
	if(active)
		old_module.on_part_deactivation(deleting = deleting)
		if(old_module.active)
			old_module.deactivate(display_message = !deleting, deleting = deleting)
	old_module.on_uninstall(deleting = deleting)
	QDEL_LIST_ASSOC_VAL(old_module.pinned_to)
	old_module.mod = null

/// Intended for callbacks, don't use normally, just get wearer by itself.
/obj/item/mod/control/proc/get_wearer()
	return wearer

/obj/item/mod/control/proc/update_access(mob/user, obj/item/card/id/card)
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	req_access = card.access.Copy()
	balloon_alert(user, "access updated")

/obj/item/mod/control/proc/update_speed()
	var/total_slowdown = 0
	var/prevent_slowdown = HAS_TRAIT(src, TRAIT_SPEED_POTIONED)
	if (!prevent_slowdown)
		total_slowdown += slowdown_deployed

	var/list/module_slowdowns = list()
	SEND_SIGNAL(src, COMSIG_MOD_UPDATE_SPEED, module_slowdowns, prevent_slowdown)
	for (var/module_slow in module_slowdowns)
		total_slowdown += module_slow

	for(var/datum/mod_part/part_datum as anything in get_part_datums(all = TRUE))
		var/obj/item/part = part_datum.part_item
		part.slowdown = total_slowdown / length(mod_parts)
		if (!part_datum.sealed)
			part.slowdown = max(part.slowdown, 0)
	wearer?.update_equipment_speed_mods()

/obj/item/mod/control/proc/set_mod_color(new_color)
	for(var/obj/item/part as anything in get_parts(all = TRUE))
		part.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		part.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(part.loc == src)
		return
	if(part == core)
		core.uninstall()
		update_charge_alert()
		return
	if(part.loc == wearer)
		return
	if(part in modules)
		uninstall(part)
		return
	if(part in get_parts())
		if(QDELING(part) && !QDELING(src))
			qdel(src)
			return
		var/datum/mod_part/part_datum = get_part_datum(part)
		if(part_datum.sealed)
			seal_part(part, is_sealed = FALSE)
		if(isnull(part.loc))
			return
		if(!wearer)
			part.forceMove(src)
			return
		INVOKE_ASYNC(src, PROC_REF(retract), wearer, part, /* instant = */ TRUE) // async to appease spaceman DMM because the branch we don't run has a do_after

/obj/item/mod/control/proc/on_part_destruction(obj/item/part, damage_flag)
	SIGNAL_HANDLER

	if(QDELING(src))
		return
	atom_destruction(damage_flag)

/obj/item/mod/control/proc/on_overslot_exit(obj/item/part, atom/movable/overslot, direction)
	SIGNAL_HANDLER

	var/datum/mod_part/part_datum = get_part_datum(part)
	if(overslot != part_datum.overslotting)
		return
	UnregisterSignal(part, COMSIG_ATOM_EXITED)
	part_datum.overslotting = null

/obj/item/mod/control/proc/on_potion(atom/movable/source, obj/item/slimepotion/speed/speed_potion, mob/living/user)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_SPEED_POTIONED))
		to_chat(user, span_warning("[src] has already been coated with red, that's as fast as it'll go!"))
		return SPEED_POTION_STOP

	if(active)
		to_chat(user, span_warning("It's too dangerous to smear [speed_potion] on [src] while it's active!"))
		return SPEED_POTION_STOP

	to_chat(user, span_notice("You slather the red gunk over [src], making it faster."))
	set_mod_color("#FF0000")
	ADD_TRAIT(src, TRAIT_SPEED_POTIONED, SLIME_POTION_TRAIT)
	update_speed()
	qdel(speed_potion)
	return SPEED_POTION_STOP

/obj/item/mod/control/proc/get_visor_overlay(mutable_appearance/standing)
	var/list/overrides = list()
	SEND_SIGNAL(src, COMSIG_MOD_GET_VISOR_OVERLAY, standing, overrides)
	if (length(overrides))
		return overrides[1]
	return mutable_appearance(worn_icon, "[skin]-helmet-visor", layer = standing.layer + 0.5)

/obj/item/mod/control/relaymove(mob/user, direction)
	if((!active && wearer) || get_charge() < CHARGE_PER_STEP || user != ai_assistant || !COOLDOWN_FINISHED(src, cooldown_mod_move) || (wearer?.pulledby?.grab_state > GRAB_PASSIVE))
		return FALSE
	var/datum/mod_part/legs_to_move = get_part_datum_from_slot(ITEM_SLOT_FEET)
	if(wearer && (!legs_to_move || !legs_to_move.sealed))
		return FALSE
	var/timemodifier = MOVE_DELAY * (ISDIAGONALDIR(direction) ? sqrt(2) : 1) * (wearer ? WEARER_DELAY : LONE_DELAY)
	if(wearer && !wearer.Process_Spacemove(direction))
		return FALSE
	else if(!wearer && (!has_gravity() || !isturf(loc)))
		return FALSE
	COOLDOWN_START(src, cooldown_mod_move, movedelay * timemodifier + slowdown_deployed)
	subtract_charge(CHARGE_PER_STEP)
	playsound(src, 'sound/mecha/mechmove01.ogg', 25, TRUE)
	if(ismovable(wearer?.loc))
		return wearer.loc.relaymove(wearer, direction)
	else if(wearer)
		ADD_TRAIT(wearer, TRAIT_FORCED_STANDING, REF(src))
		addtimer(CALLBACK(src, PROC_REF(ai_fall)), AI_FALL_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	var/atom/movable/mover = wearer || src
	return step(mover, direction)
