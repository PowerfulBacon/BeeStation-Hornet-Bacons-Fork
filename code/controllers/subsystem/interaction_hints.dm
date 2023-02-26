SUBSYSTEM_DEF(interaction_hints)
	name = "Interaction Hints"

	var/list/interaction_hint_maps = list()

/datum/controller/subsystem/interaction_hints/proc/get_map(map_key)
	. = interaction_hint_maps[map_key]
	if (!.)
		. = new /datum/spatial_tree()
		interaction_hint_maps[map_key] = .
