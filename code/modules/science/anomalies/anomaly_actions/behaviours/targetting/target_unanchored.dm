/**
 * Target Unanchored
 * Identifies nearby unanchored objects
 */

/datum/anomaly_action/targetting/unanchored/get_targets_in_range()
	. = list()
	for (var/obj/object in view(vision_range, parent_anomaly.parent))
		if (object.anchored || object == parent_anomaly.parent)
			continue
		. += object
