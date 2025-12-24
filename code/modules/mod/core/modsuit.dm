
/**
 * Modsuit Core
 *
 * This datum provides all of the functionality and behaviour of a modsuit,
 * but without a concrete implementation. It is up to the concrete implementation
 * to define how the interactions with this datum occur, but this datum
 * provides all of the actual behaviours such as UI and power management.
 */

/datum/component/modsuit
	/// If the suit is ID locked.
	var/locked = FALSE
	/// If the suit is deployed and turned on.
	var/active = FALSE
	/// If the suit is currently activating/deactivating.
	var/activating = FALSE
	/// If the suit wire/module hatch is open.
	var/open = FALSE
	/// Is this suit active?
	var/active = FALSE
	/// AI or pAI mob inhabiting the suit.
	var/mob/living/silicon/ai_assistant
	/// The name of the atom that we are applied to
	var/obj/item/suit = null
	/// The core inserted into this suit. Cores define the interaction
	/// with the power mechanics of the suit.
	var/obj/item/mod/core/core = null

/datum/component/modsuit/Initialize(datum/mod_theme/theme, new_skin)
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	// Store a reference to the suit, since this is the parent
	// we will be destroyed when our parent is destroyed.
	suit = parent
	// Suit is locked if req_access is set on the parent atom
	if (suit.req_access)
		locked = TRUE
	if (ispath(theme))
		theme = GLOB.mod_themes[theme]
	theme.set_up_parts(src, new_skin)
	// Screentips
	RegisterSignal(parent, COMSIG_ATOM_ADD_CONTEXT, PROC_REF(display_screentips))
	// Core connection behaviour
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(check_core_insertion))
	// Examine overrides
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	// Tool behaviours
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(screwdriver_act))

/// Remove any references when we are destroyed
/datum/component/modsuit/Destroy(force, silent)
	. = ..()
	suit = null
	// Core gets deleted along with us
	if (core)
		QDEL_NULL(core)

/datum/component/modsuit/proc/on_examine(datum/source, mob/user, list/examine_text)
	if (active)
		if (core)
			. += "It has [get_charge_percent()]% charge remaining."
		else
			. += "It has no core inserted and will not function."

/datum/component/modsuit/proc/check_core_insertion(datum/parent, obj/item/item, mob/living/user, params)
	if (!istype(item, /obj/item/mod/core))
		return NONE
	// Already has a core inserted
	if (core)
		if (user)
			to_chat(user, span_notice("The [suit] already has a core, remove it with a crowbar!"))
			suit.balloon_alert(user, "No space")
			playsound(suit, 'sound/machines/scanbuzz.ogg', 15, FALSE, SILENCED_SOUND_EXTRARANGE)
		return COMPONENT_NO_AFTERATTACK
	// Move to nullspace
	if (!user.transferItemToLoc(item, null))
		return COMPONENT_NO_AFTERATTACK
	// Register the core
	core = item
	// Refresh screentips now that we have a core
	suit.refresh_screentips()
	if (user)
		user.visible_message(span_notice("[user] inserts \the [core] into \the [suit]."), span_notice("You insert \the [core] into \the [suit]."))
		playsound(suit, 'sound/machines/click.ogg', 15, FALSE, SILENCED_SOUND_EXTRARANGE)
	return COMPONENT_NO_AFTERATTACK

/datum/component/modsuit/proc/display_screentips(datum/source, datum/screentip_context/context, mob/user)
	// No matter what we are attached to, don't allow the cache
	context.cache_force_disabled = TRUE
	if (!core)
		context.add_left_click_item_action("Insert", /obj/item/mod/core)
	// Open / Close the suit with a screwdriver
	context.add_left_click_tool_action(open ? "Close" : "Open", TOOL_SCREWDRIVER)
	// Remove the core
	if (open && core)
		context.add_left_click_tool_action("Remove core", TOOL_CROWBAR)

/// Screwdriver can open/close the internal access hatch
/datum/component/modsuit/proc/screwdriver_act(datum/source, mob/living/user, obj/item/screwdriver, list/recipes)
	if (active || activating || suit.ai_controller)
		suit.balloon_alert(user, "Suit active")
		to_chat(user, span_warning("You try to screwdriver \the [suit] but fail, it is currently active."))
		playsound(suit, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return COMPONENT_BLOCK_TOOL_ATTACK
	if(isAI(ai_assistant) && locked && !open)
		suit.balloon_alert(user, "Remote controlled")
		to_chat(user, span_warning("You try to screwdriver \the [suit] but fail, it is locked by an installed AI unit."))
		playsound(suit, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return COMPONENT_BLOCK_TOOL_ATTACK
	if(SEND_SIGNAL(suit, COMSIG_MOD_MODULE_REMOVAL, user) & MOD_CANCEL_REMOVAL)
		playsound(suit, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return COMPONENT_BLOCK_TOOL_ATTACK
	suit.balloon_alert(user, "[open ? "closing" : "opening"]...")
	to_chat(user, span_notice("You start to screw [open ? "shut" : "open"] the internal access hatch on [suit]..."))
	screwdriver.play_tool_sound(suit, 100)
	if(screwdriver.use_tool(suit, user, 1 SECONDS))
		if(active || activating)
			suit.balloon_alert(user, "unit active!")
			return COMPONENT_BLOCK_TOOL_ATTACK
		screwdriver.play_tool_sound(suit, 100)
		open = !open
		suit.balloon_alert(user, "cover [open ? "closed" : "opened"]")
		to_chat(user, span_notice("You screw [open ? "shut" : "open"] the internal access hatch on [suit]."))
	else
		to_chat(user, span_warning("You fail to screw [open ? "shut" : "open"] the internal access hatch on [suit]!"))
	return COMPONENT_BLOCK_TOOL_ATTACK
