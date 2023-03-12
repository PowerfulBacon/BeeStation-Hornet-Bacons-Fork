/**
 * Target Humans
 * Makes it so that the anomaly will target humans.
 */

/datum/anomaly_action/targetting/humans/get_targets_in_range()
	. = list()
	for (var/mob/living/carbon/human/H in view(vision_range, parent_anomaly.parent))
		if (H == parent_anomaly.parent)
			continue
		. += H
