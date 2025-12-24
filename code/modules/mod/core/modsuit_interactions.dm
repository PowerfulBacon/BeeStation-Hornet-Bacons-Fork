/// Called when someone uses an item on the parent
/datum/component/modsuit/proc/on_item_attack(datum/parent, obj/item/item, mob/living/user, params)
	SIGNAL_HANDLER
	if (istype(item, /obj/item/mod/core))
		return check_core_insertion(parent, item, user, params)
	return NONE

/// Called when someone uses a mod core on the suit
/datum/component/modsuit/proc/check_core_insertion(datum/parent, obj/item/item, mob/living/user, params)
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

/// Called when someone uses a PAI card on the suit
/datum/component/modsuit/proc/check_pai_insertion(datum/parent, obj/item/item, mob/living/user, params)

/// Screwdriver can open/close the internal access hatch
/datum/component/modsuit/proc/screwdriver_act(datum/source, mob/living/user, obj/item/screwdriver, list/recipes)
	SIGNAL_HANDLER
	INVOKE_ASYNC(CALLBACK(src, PROC_REF(screwdriver_act_async), source, user, screwdriver, recipes))
	return COMPONENT_BLOCK_TOOL_ATTACK

/datum/component/modsuit/proc/screwdriver_act_async(datum/source, mob/living/user, obj/item/screwdriver, list/recipes)
	if (active || activating || suit.ai_controller)
		suit.balloon_alert(user, "Suit active")
		to_chat(user, span_warning("You try to screwdriver \the [suit] but fail, it is currently active."))
		playsound(suit, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(isAI(ai_assistant) && locked && !open)
		suit.balloon_alert(user, "Remote controlled")
		to_chat(user, span_warning("You try to screwdriver \the [suit] but fail, it is locked by an installed AI unit."))
		playsound(suit, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(SEND_SIGNAL(suit, COMSIG_MOD_MODULE_REMOVAL, user) & MOD_CANCEL_REMOVAL)
		playsound(suit, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	suit.balloon_alert(user, "[open ? "closing" : "opening"]...")
	to_chat(user, span_notice("You start to screw [open ? "shut" : "open"] the internal access hatch on [suit]..."))
	screwdriver.play_tool_sound(suit, 100)
	if(screwdriver.use_tool(suit, user, 1 SECONDS))
		if(active || activating)
			suit.balloon_alert(user, "unit active!")
			return
		screwdriver.play_tool_sound(suit, 100)
		open = !open
		suit.balloon_alert(user, "cover [open ? "closed" : "opened"]")
		to_chat(user, span_notice("You screw [open ? "shut" : "open"] the internal access hatch on [suit]."))
	else
		to_chat(user, span_warning("You fail to screw [open ? "shut" : "open"] the internal access hatch on [suit]!"))
