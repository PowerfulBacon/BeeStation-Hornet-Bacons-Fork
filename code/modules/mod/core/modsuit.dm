
/**
 * Modsuit Core
 *
 * This datum provides all of the functionality and behaviour of a modsuit,
 * but without a concrete implementation. It is up to the concrete implementation
 * to define how the interactions with this datum occur, but this datum
 * provides all of the actual behaviours such as UI and power management.
 */

/datum/component/modsuit
	/// Theme of the MOD TGUI
	var/ui_theme = "ntos"
	/// If the suit is malfunctioning.
	var/malfunctioning = FALSE
	/// How long the MOD is electrified for.
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	/// If the suit interface is broken.
	var/interface_break = FALSE
	/// How much module complexity can this MOD carry.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much module complexity this MOD is carrying.
	var/complexity = 0
	/// If the suit is ID locked.
	var/locked = FALSE
	/// If the suit is deployed and turned on.
	var/active = FALSE
	/// If the suit wire/module hatch is open.
	var/open = FALSE
	/// Is this suit active?
	var/active = FALSE
	/// Power usage of the MOD.
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when all of its pieces are deployed.
	var/slowdown_deployed = 0.50 //same as syndicate hardsuits
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Person wearing the MODsuit.
	var/mob/living/carbon/human/wearer
	/// AI or pAI mob inhabiting the suit.
	var/mob/living/silicon/ai_assistant
	/// The name of the atom that we are applied to
	var/obj/item/suit = null
	/// The core inserted into this suit. Cores define the interaction
	/// with the power mechanics of the suit.
	var/obj/item/mod/core/core = null
	/// List of MODsuit part datums.
	var/list/mod_parts = list()
	/// Modules the MOD currently possesses.
	var/list/modules = list()
	/// Currently used module.
	var/obj/item/mod/module/selected_module
	/// Extended description of the theme.
	var/extended_desc
	/// Cooldown for AI moves.
	COOLDOWN_DECLARE(cooldown_mod_move)
	/// The flags of the suit
	var/suit_flags = MODSUIT_LIGHT
	/// Delay between moves as AI.
	var/static/movedelay = 0

/datum/component/modsuit/Initialize(datum/mod_theme/theme, new_skin, obj/item/mod/core/new_core, flags = MODSUIT_LIGHT)
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(!movedelay)
		movedelay = CONFIG_GET(number/movedelay/run_delay)
	src.suit_flags = suit_flags
	// Store a reference to the suit, since this is the parent
	// we will be destroyed when our parent is destroyed.
	suit = parent
	// Suit is locked if req_access is set on the parent atom
	if (suit.req_access)
		locked = TRUE
	if (ispath(theme))
		theme = GLOB.mod_themes[theme]
	if (!theme.can_apply_to(src))
		CRASH("Modsuit theme applied to modsuit which is not capable of using that theme.")
	theme.set_up_parts(src, new_skin)
	// Setup destruction
	for(var/obj/item/part as anything in get_parts())
		RegisterSignal(part, COMSIG_ATOM_DESTRUCTION, PROC_REF(on_part_destruction))
	// Install the core
	new_core?.install(src)
	// Screentips
	RegisterSignal(parent, COMSIG_ATOM_ADD_CONTEXT, PROC_REF(display_screentips))
	// Core connection behaviour
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(check_core_insertion))
	// Examine overrides
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))
	// Tool behaviours
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(screwdriver_act))
	// Equip signals
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	// Destruction handling
	RegisterSignal(parent, COMSIG_ATOM_DESTRUCTION, PROC_REF(on_destruction))
	// Contents handling
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	// Install the modules
	for(var/obj/item/mod/module/module as anything in theme.inbuilt_modules)
		module = new module(src)
		install(module)
	// Start processing
	START_PROCESSING(SSobj, src)

/// Remove any references when we are destroyed
/datum/component/modsuit/Destroy(force, silent)
	. = ..()
	// Stop processing
	STOP_PROCESSING(SSobj, src)
	// Uninstall modules
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module, deleting = TRUE)
	// Clear up all part datums
	for(var/datum/mod_part/part_datum as anything in get_part_datums(all = TRUE))
		var/obj/item/part_item = part_datum.part_item
		part_datum.part_item = null
		part_datum.overslotting = null
		mod_parts -= part_datum
		if(!QDELING(part_item))
			qdel(part_item)
	// Clear hanging references
	suit = null
	// Core gets deleted along with us, if still present
	if (core)
		QDEL_NULL(core)

/datum/component/modsuit/process(delta_time)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(!active)
		return
	if(!get_charge() && active)
		power_off()
		return
	var/malfunctioning_charge_drain = 0
	if(malfunctioning)
		malfunctioning_charge_drain = rand(1,20)
	subtract_charge((charge_drain + malfunctioning_charge_drain)*delta_time)
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		if(malfunctioning && module.active && DT_PROB(5, delta_time))
			module.deactivate(display_message = TRUE)
		module.on_process(delta_time)

/// Called when the atom is destroyed through damage (and not through deletion)
/datum/component/modsuit/proc/on_destruction(datum/source, damage_flag)
	SIGNAL_HANDLER
	var/atom/visible_atom = wearer || src
	if(wearer)
		clean_up()
	visible_atom.visible_message(span_bolddanger("[src] fall[p_s()] apart, completely destroyed!"), vision_distance = COMBAT_MESSAGE_RANGE)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module)
	if(ai_assistant)
		if(ispAI(ai_assistant))
			// async to appease spaceman DMM because the branch we don't run has a do_after
			INVOKE_ASYNC(src, PROC_REF(remove_pai), /* user = */ null, /* forced = */ TRUE)
		else
			for(var/datum/action/action as anything in actions)
				if(action.owner == ai_assistant)
					action.Remove(ai_assistant)
			new /obj/item/mod/ai_minicard(suit.drop_location(), ai_assistant)

/datum/component/modsuit/proc/on_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(slot & suit.slot_flags)
		set_wearer(user)
	else if(wearer)
		unset_wearer()

/datum/component/modsuit/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!wearer)
		return
	clean_up()

/// Called when someone examines the parent
/datum/component/modsuit/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if (active)
		if (core)
			. += "It has [get_charge_percent()]% charge remaining."
		else
			. += "It has no core inserted and will not function."
		. += "Selected module: [selected_module || "None"]."
	if(!open && !active)
		if(!wearer)
			. += "You could equip it to turn it on."
		. += "You could open the cover with a <b>screwdriver</b>."
	else if(open)
		. += "You could close the cover with a <b>screwdriver</b>."
		. += "You could use <b>modules</b> on it to install them."
		. += "You could remove modules with a <b>crowbar</b>."
		. += "You could update the access lock with an <b>ID</b>."
		. += "You could access the wire panel with a <b>wire tool</b>."
		if(core)
			. += "You could remove [core] with a <b>wrench</b>."
		else
			. += "You could use a <b>MOD core</b> on it to install one."
		if(isnull(ai_assistant))
			. += "You could install an AI or pAI using their <b>storage card</b>."
		else if(isAI(ai_assistant))
			. += "You could remove [ai_assistant] with an <b>intellicard</b>."
	. += "<i>You could examine it more thoroughly...</i>"

/datum/component/modsuit/proc/on_examine_more(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += "<i>[extended_desc]</i>"

/// Called when we want to get the screentips for the parent
/datum/component/modsuit/proc/display_screentips(datum/source, datum/screentip_context/context, mob/user)
	SIGNAL_HANDLER
	// No matter what we are attached to, don't allow the cache
	context.cache_force_disabled = TRUE
	if (!core)
		context.add_left_click_item_action("Insert", /obj/item/mod/core)
	// Open / Close the suit with a screwdriver
	context.add_left_click_tool_action(open ? "Close" : "Open", TOOL_SCREWDRIVER)
	// Remove the core
	if (open && core)
		context.add_left_click_tool_action("Remove core", TOOL_CROWBAR)

/datum/component/modsuit/proc/on_exit(datum/source, atom/movable/part, direction)
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

/datum/component/modsuit/proc/set_wearer(mob/living/carbon/human/user)
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

/datum/component/modsuit/proc/unset_wearer()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	UnregisterSignal(wearer, list(COMSIG_ATOM_EXITED, COMSIG_SPECIES_GAIN))
	wearer.clear_alert("mod_charge")
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_UNSET, wearer)
	wearer = null

/// Finishes the suit's activation
/datum/component/modsuit/proc/set_active(is_on)
	active = is_on
	if(active)
		for(var/obj/item/mod/module/module as anything in modules)
			if(module.part_activated || !module.has_required_parts(mod_parts, need_active = TRUE))
				continue
			module.on_part_activation()
			module.part_activated = TRUE
	else
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.part_activated)
				continue
			module.on_part_deactivation()
			module.part_activated = FALSE
			if(!module.active || (module.allow_flags & MODULE_ALLOW_INACTIVE))
				continue
			module.deactivate(display_message = FALSE)
	update_charge_alert()
	suit.update_appearance(UPDATE_ICON_STATE)
	generate_suit_mask()
	wearer.update_clothing(suit.slot_flags)

/datum/component/modsuit/proc/clean_up()
	if(QDELING(src))
		unset_wearer()
		return
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
		set_active(is_on = FALSE)
	var/mob/old_wearer = wearer
	unset_wearer()
	old_wearer.temporarilyRemoveItemFromInventory(src)

/datum/component/modsuit/proc/get_parts(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part.part_item

/datum/component/modsuit/proc/get_part_datums(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part

/datum/component/modsuit/proc/get_part_datum(obj/item/part)
	RETURN_TYPE(/datum/mod_part)
	var/datum/mod_part/potential_part = mod_parts["[part.slot_flags]"]
	if(potential_part?.part_item == part)
		return potential_part
	for(var/datum/mod_part/mod_part in get_part_datums())
		if(mod_part.part_item == part)
			return mod_part
	CRASH("get_part_datum called with incorrect item [part] passed.")

/datum/component/modsuit/proc/get_part_from_slot(slot)
	var/datum/mod_part/part = mod_parts["[slot]"]
	return part?.part_item

/datum/component/modsuit/proc/get_part_datum_from_slot(slot)
	return mod_parts["[slot]"]

/datum/component/modsuit/proc/get_sealed_slots(list/parts)
	var/covered_slots = NONE
	for(var/obj/item/part as anything in parts)
		if(!get_part_datum(part).sealed)
			parts -= part
			continue
		covered_slots |= part.slot_flags
	return covered_slots

/datum/component/modsuit/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER

	for(var/obj/item/part in get_parts(all = TRUE))
		if(!(new_species.no_equip_flags & part.slot_flags) || is_type_in_list(new_species, part.species_exception))
			continue
		if (wearer)
			suit.forceMove(wearer.drop_location())
		else
			suit.forceMove(suit.drop_location())
		return

/datum/component/modsuit/proc/on_part_destruction(obj/item/part, damage_flag)
	SIGNAL_HANDLER

	if(QDELING(src))
		return
	suit.atom_destruction(damage_flag)

/datum/component/modsuit/proc/set_mod_color(new_color)
	for(var/obj/item/part as anything in get_parts(all = TRUE))
		part.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		part.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	wearer?.regenerate_icons()

/datum/component/modsuit/proc/update_speed()
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


/// Intended for callbacks, don't use normally, just get wearer by itself.
/datum/component/modsuit/proc/get_wearer()
	return wearer

/datum/component/modsuit/proc/update_access(mob/user, obj/item/card/id/card)
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	req_access = card.access.Copy()
	balloon_alert(user, "access updated")

/datum/component/modsuit/proc/on_overslot_exit(obj/item/part, atom/movable/overslot, direction)
	SIGNAL_HANDLER

	var/datum/mod_part/part_datum = get_part_datum(part)
	if(overslot != part_datum.overslotting)
		return
	UnregisterSignal(part, COMSIG_ATOM_EXITED)
	part_datum.overslotting = null

/datum/component/modsuit/proc/on_potion(atom/movable/source, obj/item/slimepotion/speed/speed_potion, mob/living/user)
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


/datum/component/modsuit/proc/shock(mob/living/user)
	if(!istype(user) || get_charge() < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, get_charge_source(), src, 0.7, check_range)

/datum/component/modsuit/proc/install(obj/item/mod/module/new_module, mob/user)
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

/datum/component/modsuit/proc/uninstall(obj/item/mod/module/old_module, deleting = FALSE)
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
