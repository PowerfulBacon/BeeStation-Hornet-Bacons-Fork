/datum/body/human
	//The accepted type (and subtypes) of blood for this body
	accepted_blood_type
	//The maximum amount of blood
	maximum_blood = BLOOD_VOLUME_MAXIMUM
	//The default amount of blood
	default_blood = BLOOD_VOLUME_NORMAL
	//The minimum amount of blood that a mob needs to stay alive
	minimum_safe_blood = BLOOD_VOLUME_BAD
	//The pain threshold for soft-crit
	pain_crit = 100
	//The root bodypart component
	root = /datum/bodypart/body/human
