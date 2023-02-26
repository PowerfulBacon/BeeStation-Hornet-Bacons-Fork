
/datum/component/interaction_hint_provider
	var/group_key

/datum/component/interaction_hint_provider/Initialize(group_key)
	. = ..()
	src.group_key = group_key

	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/on_equipped)

/datum/component/interaction_hint_provider/proc/on_equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	// Check if we can display some hints that we couldn't display before
