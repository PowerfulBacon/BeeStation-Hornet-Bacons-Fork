/datum/artifact/emp
	cooldown = 300 SECONDS
	trigger_modes = list(ARTIFACT_TRIGGER_USE_HAND)

/datum/artifact/emp/trigger_effect(atom/source)
	empulse(source, 0, rand(2, 5))
