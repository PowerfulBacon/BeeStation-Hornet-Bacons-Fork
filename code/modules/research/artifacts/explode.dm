/datum/artifact/explode
	cooldown = 300 SECONDS
	trigger_modes = list(ARTIFACT_TRIGGER_USE_HAND)

/datum/artifact/explode/trigger_effect(atom/source)
	explosion(source, 0, rand(1, 3), rand(3, 5), 0)
