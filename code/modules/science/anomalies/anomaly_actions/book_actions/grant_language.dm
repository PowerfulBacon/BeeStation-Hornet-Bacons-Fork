/datum/anomaly_action/grant_language
	action_desc = "grant_language"
	addition_details = list("unknown_lang")

/datum/anomaly_action/grant_language/trigger_action(list/atom/trigger_atoms, list/extra_data)
	if (!length(trigger_atoms))
		return
	var/mob/living/target = trigger_atoms[1]
	if (!ismob(target))
		return
	target.grant_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_ANOMALY)
