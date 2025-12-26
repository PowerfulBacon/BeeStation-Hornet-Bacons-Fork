/// MODsuits, trade-off between armor and utility
/obj/item/mod
	name = "Base MOD"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'

/obj/item/mod/lightsuit
	name = "\improper MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments."
	icon_state = "standard-control"
	inhand_icon_state = "mod_control"
	base_icon_state = "control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_STORAGE_UNIT
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
	/// Are we currently in the process of activating?
	var/activating = FALSE
	/// The MOD's theme, decides on some stuff like armor and statistics.
	var/datum/mod_theme/theme = /datum/mod_theme
	/// Looks of the MOD.
	var/skin = "standard"

/obj/item/mod/lightsuit/Initialize(mapload, datum/mod_theme/new_theme, new_skin, obj/item/mod/core/new_core)
	. = ..()
	AddComponent(src, /datum/component/modsuit, new_theme || theme, new_skin)
	wires = new /datum/wires/mod(src)
	update_speed()
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, PROC_REF(on_potion))

/obj/item/mod/lightsuit/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/item/mod/lightsuit/item_action_slot_check(slot)
	if(slot & slot_flags)
		return TRUE

/obj/item/mod/lightsuit/Exited(atom/movable/part, direction)
	. = ..()
	// Handle losing the actual parts of the modsuit itself
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

// Grant pinned actions to pin owners, gives AI pinned actions to the AI and not the wearer
/obj/item/mod/lightsuit/grant_action_to_bearer(datum/action/action)
	if (!istype(action, /datum/action/item_action/mod/pinned_module))
		return ..()
	var/datum/action/item_action/mod/pinned_module/pinned = action
	give_item_action(action, pinned.pinner, slot_flags)

/obj/item/mod/lightsuit/Moved(atom/old_loc, movement_dir, forced = FALSE, list/old_locs)
	. = ..()
	if(!wearer || old_loc != wearer || loc == wearer)
		return
	clean_up()

/obj/item/mod/lightsuit/allow_attack_hand_drop(mob/user)
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

/obj/item/mod/lightsuit/MouseDrop(atom/over_object)
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

/obj/item/mod/lightsuit/wrench_act(mob/living/user, obj/item/wrench)
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

/obj/item/mod/lightsuit/crowbar_act(mob/living/user, obj/item/crowbar)
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

/obj/item/mod/lightsuit/attackby(obj/item/attacking_item, mob/living/user, params)
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

/obj/item/mod/lightsuit/get_cell()
	if(!open)
		return
	var/obj/item/stock_parts/cell/cell = get_charge_source()
	if(!istype(cell))
		return
	return cell

/obj/item/mod/lightsuit/GetAccess()
	if(ai_controller)
		if(req_access)
			return req_access.Copy()
		else
			return ..()
	else
		return ..()

/obj/item/mod/lightsuit/on_emag(mob/user)
	..()
	locked = !locked
	balloon_alert(user, "access [locked ? "locked" : "unlocked"]")

/obj/item/mod/lightsuit/emp_act(severity)
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

/obj/item/mod/lightsuit/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	//if(visuals_only)
	//	set_wearer(outfit_wearer) //we need to set wearer manually since it doesnt call equipped
	quick_activation()

/obj/item/mod/lightsuit/doStrip(mob/stripper, mob/owner)
	if(active && !toggle_activate(stripper, force_deactivate = TRUE))
		return
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		retract(null, part)
	return ..()

/obj/item/mod/lightsuit/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		var/list/module_icons = module.generate_worn_overlay(standing)
		if(!length(module_icons))
			continue
		. += module_icons

/obj/item/mod/lightsuit/update_icon_state()
	icon_state = "[skin]-[base_icon_state][active ? "-sealed" : ""]"
	return ..()

/obj/item/mod/lightsuit/proc/quick_module(mob/user)
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

/obj/item/mod/lightsuit/proc/get_visor_overlay(mutable_appearance/standing)
	var/list/overrides = list()
	SEND_SIGNAL(src, COMSIG_MOD_GET_VISOR_OVERLAY, standing, overrides)
	if (length(overrides))
		return overrides[1]
	return mutable_appearance(worn_icon, "[skin]-helmet-visor", layer = standing.layer + 0.5)

/obj/item/mod/lightsuit/relaymove(mob/user, direction)
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

/obj/item/mod/lightsuit/proc/generate_suit_mask()
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
