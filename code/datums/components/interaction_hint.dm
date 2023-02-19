#define HAS_INTERACTION_HINT(type_path, initial_deconstruction_tool) \
	##type_path/ComponentInitialize(){\
		if (GetComponent(/datum/component/interaction_hint)) {\
			return ..();\
		};\
		var/icon/funny_icon = icon('icons/obj/tools.dmi', "wrench");\
		var/icon/funny_icon2 = icon('icons/obj/tools.dmi', "wrench");\
		AddComponent(/datum/component/interaction_hint, list(\
			new /datum/interaction_hint/construction(funny_icon),\
			new /datum/interaction_hint/deconstruction(funny_icon2)\
		));\
		SET_INTERACTION_TOOLS(null, initial_deconstruction_tool);\
		return ..();\
	}

#define INTERACTION_HINT_ENTER(type_path) \
	##type_path/MouseEntered(location, control, params) {\
		SEND_SIGNAL(src, COMSIG_INTERACTION_HINT_ENTERED, usr, location, control, params);\
	}

#define INTERACTION_HINT_EXIT(type_path) \
	##type_path/MouseExited(location, control, params) {\
		SEND_SIGNAL(src, COMSIG_INTERACTION_HINT_EXITED, usr, location, control, params);\
	}

#define SET_INTERACTION_TOOLS(construction_tool, deconstruction_tool) \
	SEND_SIGNAL(src, COMSIG_INTERACTION_TOOL_CHANGED, construction_tool, deconstruction_tool)

/datum/component/interaction_hint
	/// List of interaction hints
	var/list/current_hint = list()
	/// List of mobs who have their mouse over us
	var/list/hovered_mobs = list()
	/// List of mobs this hint is currently shown to
	var/list/shown_mobs = list()

/datum/component/interaction_hint/Initialize(list/initial_hint)
	. = ..()
	RegisterSignal(parent, COMSIG_INTERACTION_HINT_ENTERED, .proc/mouse_over)
	RegisterSignal(parent, COMSIG_INTERACTION_HINT_EXITED, .proc/mouse_exit)
	RegisterSignal(parent, COMSIG_INTERACTION_HINT_CHANGED, .proc/hint_changed)
	RegisterSignal(parent, COMSIG_INTERACTION_TOOL_CHANGED, .proc/tool_changed)
	hint_changed(initial_hint)

/datum/component/interaction_hint/RemoveComponent()
	. = ..()
	for (var/mob/user in shown_mobs)
		hide_hint(user)

/datum/component/interaction_hint/proc/mouse_over(atom/source, mob/user)
	SIGNAL_HANDLER
	// Quicker than dictionary lookup for small domain lists
	if (hovered_mobs[user])
		return
	if (get_dist(parent, user) > 1)
		return
	var/obj/item/held = user.get_active_held_item()
	var/time = 1.5 SECONDS
	if (held?.tool_behaviour)
		time = 0.2 SECONDS
	hovered_mobs[user] = addtimer(CALLBACK(src, .proc/check_hint_timer, user), time, TIMER_STOPPABLE)
	RegisterSignal(user, COMSIG_PARENT_QDELETING, .proc/mob_left)
	RegisterSignal(user, COMSIG_MOB_LOGOUT, .proc/mob_left)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/move_away)

/datum/component/interaction_hint/proc/move_away(mob/user)
	mouse_exit(parent, user)

/datum/component/interaction_hint/proc/mouse_exit(atom/source, mob/user)
	SIGNAL_HANDLER
	var/timer_id = hovered_mobs[user]
	if (user in shown_mobs)
		hide_hint(user)
		return
	if (!timer_id)
		return
	if (timer_id != -1)
		deltimer(timer_id)
	mob_left(user)

/datum/component/interaction_hint/proc/mob_left(mob/user)
	SIGNAL_HANDLER
	hovered_mobs -= user
	UnregisterSignal(user, COMSIG_PARENT_QDELETING)
	UnregisterSignal(user, COMSIG_MOB_LOGOUT)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/datum/component/interaction_hint/proc/check_hint_timer(mob/user)
	if (!hovered_mobs[user])
		return
	// Check distance
	if (get_dist(parent, user) > 1)
		return
	hovered_mobs[user] = -1
	show_hint_to(user)

/datum/component/interaction_hint/proc/tool_changed(datum/source, con_tool, decon_tool)
	SIGNAL_HANDLER
	var/list/new_hints = list()
	if (con_tool)
		new_hints += new /datum/interaction_hint/construction(get_icon(con_tool))
	if (decon_tool)
		new_hints += new /datum/interaction_hint/deconstruction(get_icon(decon_tool))
	hint_changed(new_hints)

/datum/component/interaction_hint/proc/get_icon(tool)
	if (isatom(tool))
		var/atom/A = tool
		return icon(A.icon, A.icon_state)
	else
		switch (tool)
			if (TOOL_CROWBAR)
				return icon('icons/obj/tools.dmi', "crowbar")
			if (TOOL_MULTITOOL)
				return icon('icons/obj/device.dmi', "multitool")
			if (TOOL_SCREWDRIVER)
				return icon('icons/obj/tools.dmi', "screwdriver_map")
			if (TOOL_WIRECUTTER)
				return icon('icons/obj/tools.dmi', "cutters_map")
			if (TOOL_WRENCH)
				return icon('icons/obj/tools.dmi', "wrench")
			if (TOOL_WELDER)
				return icon('icons/obj/tools.dmi', "welder")
			if (TOOL_ANALYZER)
				return icon('icons/obj/device.dmi', "analyzer")
			if (TOOL_MINING)
				return icon('icons/obj/mining.dmi', "pickaxe")
			if (TOOL_SHOVEL)
				return icon('icons/obj/mining.dmi', "shovel")
			if (TOOL_RETRACTOR)
				return icon('icons/obj/surgery.dmi', "retractor")
			if (TOOL_HEMOSTAT)
				return icon('icons/obj/surgery.dmi', "hemostat")
			if (TOOL_CAUTERY)
				return icon('icons/obj/surgery.dmi', "cautery")
			if (TOOL_DRILL)
				return icon('icons/obj/surgery.dmi', "drill")
			if (TOOL_SCALPEL)
				return icon('icons/obj/surgery.dmi', "scalpel")
			if (TOOL_SAW)
				return icon('icons/obj/surgery.dmi', "saw")
			if (TOOL_BLOODFILTER)
				return icon('icons/obj/surgery.dmi', "bloodfilter")
			if (TOOL_RUSTSCRAPER)
				return icon('icons/obj/tools.dmi', "wirebrush")

/datum/component/interaction_hint/proc/hint_changed(list/datum/interaction_hint/new_hints)
	SIGNAL_HANDLER
	// Remove existing hints
	var/list/shown_mobs_copy = shown_mobs.Copy()
	for (var/mob/user in shown_mobs_copy)
		hide_hint(user)
	current_hint = new_hints
	// Add new hints
	var/pixel_offset = 22
	for (var/datum/interaction_hint/hint in current_hint)
		if (hint.hint_icon)
			hint.hint_icon.pixel_x = -16
			hint.hint_icon.pixel_y = pixel_offset
			hint.hint_icon.loc = parent
		if (hint.step_icon)
			hint.step_icon.pixel_y = pixel_offset
			hint.step_icon.pixel_x = 16
			hint.step_icon.loc = parent
		pixel_offset += 16
	for (var/mob/user in shown_mobs_copy)
		show_hint_to(user)

/datum/component/interaction_hint/proc/show_hint_to(mob/user)
	shown_mobs += user
	for (var/datum/interaction_hint/hint in current_hint)
		if (hint.hint_icon)
			user.client.images += hint.hint_icon
		if (hint.step_icon)
			user.client.images += hint.step_icon

/datum/component/interaction_hint/proc/hide_hint(mob/user)
	shown_mobs -= user
	for (var/datum/interaction_hint/hint in current_hint)
		if (hint.hint_icon)
			user.client.images -= hint.hint_icon
		if (hint.step_icon)
			user.client.images -= hint.step_icon

/// Interaction hint holder
/datum/interaction_hint
	var/icon = 'icons/mob/screen_interaction_hints.dmi'
	var/icon_state
	var/image/hint_icon
	var/image/step_icon

/datum/interaction_hint/New(icon/tool_icon)
	. = ..()
	step_icon = image('icons/mob/screen_interaction_hints.dmi', "bar")
	step_icon.layer = RADIAL_LAYER
	step_icon.plane = HUD_PLANE
	var/mutable_appearance/wrench_image = mutable_appearance(tool_icon)
	wrench_image.transform = matrix(0.7, 0, -7, 0, 0.7, 0)
	step_icon.add_overlay(wrench_image)
	hint_icon = image(icon, icon_state)
	hint_icon.layer = RADIAL_LAYER
	hint_icon.plane = HUD_PLANE

/datum/interaction_hint/construction
	icon_state = "construct"

/datum/interaction_hint/deconstruction
	icon_state = "deconstruct"
