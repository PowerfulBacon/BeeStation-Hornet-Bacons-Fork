/// Interaction hint holder.
/// This component indicates that something has interaction hints on a certain
/// interaction group.
///
/// The below defines provide simplifications for construction hints, simply
/// add HAS_CONSTRUCTION_HINT(typepath, TOOL_WELDER) to give a component a
/// construction hint.
///
/// SET_INTERACTION_TOOLS define can be used to modify the construction tools
/// that will display.
///
/// group_key indicates the group that this hint should display to. For example,
/// the construction tool group will only display to clients that are holding
/// any tool used for construction.
///
/// Note that when setting the interaction tool, any icon can be provided, but
/// providing a tool_behaviour will automatically draw the appropriate icon.
///
/// Author: @PowerfulBacon 2023

#define HAS_CONSTRUCTION_HINT(type_path, initial_deconstruction_tool) \
	##type_path/ComponentInitialize(){\
		// Ensure that we only draw the interaction hint for the
		// parent-most type.
		if (GetComponent(/datum/component/interaction_hint)) {\
			return ..();\
		};\
		AddComponent(/datum/component/interaction_hint, INTERACTION_GROUP_CONSTRUCTION, list());\
		SET_INTERACTION_TOOLS(null, initial_deconstruction_tool);\
		return ..();\
	}

#define SET_INTERACTION_TOOLS(construction_tool, deconstruction_tool) \
	SEND_SIGNAL(src, COMSIG_INTERACTION_TOOL_CHANGED, INTERACTION_GROUP_CONSTRUCTION, construction_tool, deconstruction_tool)

/datum/component/interaction_hint
	dupe_mode = COMPONENT_DUPE_ALLOWED
	// The group that we are acting on
	var/group_key
	// The hints provided
	var/list/interaction_hints = list()
	// The stored hint locations
	var/stored_x
	var/stored_y

/datum/component/interaction_hint/Initialize(group_key, list/initial_hint)
	. = ..()

	var/atom/parent_atom = parent
	if (!istype(parent_atom))
		return COMPONENT_INCOMPATIBLE

	src.group_key = group_key
	// When the interaction tool changes we need to update
	RegisterSignal(parent, COMSIG_INTERACTION_TOOL_CHANGED, .proc/tool_changed)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/tool_changed)
	// Change the hint
	hint_changed(initial_hint)

/datum/component/interaction_hint/proc/on_moved(datum/source, atom/oldLoc, dir, forced)
	var/datum/spatial_tree/spatial_tree = SSinteraction_hints.get_map(group_key)

	// Remove the old hint
	if (stored_x && stored_y)
		var/list/old_list = spatial_tree.get(stored_x, stored_y)
		for (var/hint in interaction_hints)
			old_list -= hint
		if (!length(old_list))
			spatial_tree.take(stored_x, stored_y)

	var/atom/parent_atom = parent
	// Invalid location
	if (!parent_atom.loc)
		check_hint_render()
		return

	// Get our hint location
	stored_x = parent_atom.x
	stored_y = parent_atom.y

	// Register the hint
	var/list/located = spatial_tree.get(stored_x, stored_y)
	if (!located)
		located = list()
		spatial_tree.put(stored_x, stored_y, located)
	// Add our new hints
	located += interaction_hints
	check_hint_render()

/datum/component/interaction_hint/proc/tool_changed(datum/source, group, con_tool, decon_tool)
	SIGNAL_HANDLER
	// This doesn't affect our hint
	if (group_key != group)
		return
	var/list/new_hints = list()
	if (con_tool)
		new_hints += new /datum/interaction_hint/construction(parent, group_key, get_icon(con_tool))
	if (decon_tool)
		new_hints += new /datum/interaction_hint/deconstruction(parent, group_key, get_icon(decon_tool))
	hint_changed(new_hints)

/datum/component/interaction_hint/proc/hint_changed(list/new_hints)
	SIGNAL_HANDLER
	update_hint_datums()
	check_hint_render()

/datum/component/interaction_hint/proc/update_hint_datums()
	var/datum/spatial_tree/spatial_tree = SSinteraction_hints.get_map(group_key)

	// Remove the old hint
	if (stored_x && stored_y)
		var/list/old_list = spatial_tree.get(stored_x, stored_y)
		for (var/hint in interaction_hints)
			old_list -= hint
		if (!length(old_list))
			spatial_tree.take(stored_x, stored_y)

	// Update the interaction hints
	interaction_hints = new_hints

	var/atom/parent_atom = parent
	// Invalid location
	if (!parent_atom.loc)
		return

	// Get our hint location
	stored_x = parent_atom.x
	stored_y = parent_atom.y

	// Register the hint
	var/list/located = spatial_tree.get(stored_x, stored_y)
	if (!located)
		located = list()
		spatial_tree.put(stored_x, stored_y, located)
	// Add our new hints
	located += interaction_hints

/datum/component/interaction_hint/proc/check_hint_render()

/datum/component/interaction_hint/proc/start_render_to(client/target)

/datum/component/interaction_hint/proc/stop_rendering_from(client/target)

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
