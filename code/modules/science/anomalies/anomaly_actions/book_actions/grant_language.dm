/datum/anomaly_action/grant_language
	action_desc = "grant_language"
	addition_details = list("unknown_lang")

/datum/anomaly_action/grant_language/trigger_action(atom/anomaly_parent, list/mob/living/trigger_mobs)
	if (!length(trigger_mobs))
		return
	var/mob/living/target = trigger_mobs[1]
	target.grant_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_ANOMALY)
