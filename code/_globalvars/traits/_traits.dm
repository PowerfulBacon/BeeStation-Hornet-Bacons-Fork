/*
	FUN ZONE OF ADMIN LISTINGS
	Try to keep this in sync with __DEFINES/traits.dm
	quirks have it's own panel so we don't need them here.
*/
GLOBAL_LIST_INIT(traits_by_type, list(
	/mob = list(
		"TRAIT_KNOCKEDOUT" = TRAIT_KNOCKEDOUT,
		"TRAIT_IMMOBILIZED" = TRAIT_IMMOBILIZED,
		"TRAIT_FLOORED" = TRAIT_FLOORED,
		"TRAIT_FORCED_STANDING" = TRAIT_FORCED_STANDING,
		"TRAIT_HANDS_BLOCKED" = TRAIT_HANDS_BLOCKED,
		"TRAIT_UI_BLOCKED" = TRAIT_UI_BLOCKED,
		"TRAIT_PULL_BLOCKED" = TRAIT_PULL_BLOCKED,
		"TRAIT_RESTRAINED" = TRAIT_RESTRAINED,
		"TRAIT_INCAPACITATED" = TRAIT_INCAPACITATED,
		"TRAIT_CRITICAL_CONDITION" = TRAIT_CRITICAL_CONDITION,
		"TRAIT_BLIND" = TRAIT_BLIND,
		"TRAIT_MUTE" = TRAIT_MUTE,
		"TRAIT_EMOTEMUTE" = TRAIT_EMOTEMUTE,
		"TRAIT_DEAF" = TRAIT_DEAF,
		"TRAIT_NEARSIGHT" = TRAIT_NEARSIGHT,
		"TRAIT_FAT" = TRAIT_FAT,
		"TRAIT_HUSK" = TRAIT_HUSK,
		"TRAIT_BADDNA" = TRAIT_BADDNA,
		"TRAIT_CLUMSY" = TRAIT_CLUMSY,
		"TRAIT_DUMB" = TRAIT_DUMB,
		"TRAIT_DISCOORDINATED" = TRAIT_DISCOORDINATED,
		"TRAIT_PACIFISM" = TRAIT_PACIFISM,
		"TRAIT_IGNORESLOWDOWN" = TRAIT_IGNORESLOWDOWN,
		"TRAIT_IGNOREDAMAGESLOWDOWN" = TRAIT_IGNOREDAMAGESLOWDOWN,
		"TRAIT_DEATHCOMA" = TRAIT_DEATHCOMA,
		"TRAIT_REGEN_COMA" = TRAIT_REGEN_COMA,
		"TRAIT_FAKEDEATH" = TRAIT_FAKEDEATH,
		"TRAIT_DISFIGURED" = TRAIT_DISFIGURED,
		"TRAIT_XENO_HOST" = TRAIT_XENO_HOST,
		"TRAIT_STUNIMMUNE" = TRAIT_STUNIMMUNE,
		"TRAIT_STUNRESISTANCE" = TRAIT_STUNRESISTANCE,
		"TRAIT_CONFUSEIMMUNE" = TRAIT_CONFUSEIMMUNE,
		"TRAIT_SLEEPIMMUNE" = TRAIT_SLEEPIMMUNE,
		"TRAIT_PUSHIMMUNE" = TRAIT_PUSHIMMUNE,
		"TRAIT_SHOCKIMMUNE" = TRAIT_SHOCKIMMUNE,
		"TRAIT_STABLEHEART" = TRAIT_STABLEHEART,
		"TRAIT_STABLELIVER" = TRAIT_STABLELIVER,
		"TRAIT_NOVOMIT" = TRAIT_NOVOMIT,
		"TRAIT_RESISTHEAT" = TRAIT_RESISTHEAT,
		"TRAIT_RESISTHEATHANDS" = TRAIT_RESISTHEATHANDS,
		"TRAIT_RESISTCOLD" = TRAIT_RESISTCOLD,
		"TRAIT_RESISTHIGHPRESSURE" = TRAIT_RESISTHIGHPRESSURE,
		"TRAIT_RESISTLOWPRESSURE" = TRAIT_RESISTLOWPRESSURE,
		"TRAIT_RADIMMUNE" = TRAIT_RADIMMUNE,
		"TRAIT_VIRUSIMMUNE" = TRAIT_VIRUSIMMUNE,
		"TRAIT_PIERCEIMMUNE" = TRAIT_PIERCEIMMUNE,
		"TRAIT_NODISMEMBER" = TRAIT_NODISMEMBER,
		"TRAIT_NOFIRE" = TRAIT_NOFIRE,
		"TRAIT_NOGUNS" = TRAIT_NOGUNS,
		"TRAIT_NOHUNGER" = TRAIT_NOHUNGER,
		"TRAIT_NOMETABOLISM" = TRAIT_NOMETABOLISM,
		"TRAIT_POWERHUNGRY" = TRAIT_POWERHUNGRY,
		"TRAIT_NOCLONELOSS" = TRAIT_NOCLONELOSS,
		"TRAIT_TOXIMMUNE" = TRAIT_TOXIMMUNE,
		"TRAIT_EASYDISMEMBER" = TRAIT_EASYDISMEMBER,
		"TRAIT_LIMBATTACHMENT" = TRAIT_LIMBATTACHMENT,
		"TRAIT_NOLIMBDISABLE" = TRAIT_NOLIMBDISABLE,
		"TRAIT_EASYLIMBDISABLE" = TRAIT_EASYLIMBDISABLE,
		"TRAIT_TOXINLOVER" = TRAIT_TOXINLOVER,
		"TRAIT_NOHAIRLOSS" = TRAIT_NOHAIRLOSS,
		"TRAIT_NOBREATH" = TRAIT_NOBREATH,
		"TRAIT_SEE_ANTIMAGIC" = TRAIT_SEE_ANTIMAGIC,
		"TRAIT_DEPRESSION" = TRAIT_DEPRESSION,
		"TRAIT_JOLLY" = TRAIT_JOLLY,
		"TRAIT_NOCRITDAMAGE" = TRAIT_NOCRITDAMAGE,
		"TRAIT_NOSLIPWATER" = TRAIT_NOSLIPWATER,
		"TRAIT_NOSLIPALL" = TRAIT_NOSLIPALL,
		"TRAIT_NODEATH" = TRAIT_NODEATH,
		"TRAIT_NOHARDCRIT" = TRAIT_NOHARDCRIT,
		"TRAIT_NOSOFTCRIT" = TRAIT_NOSOFTCRIT,
		"TRAIT_NOSTAMCRIT" = TRAIT_NOSTAMCRIT,
		"TRAIT_MINDSHIELD" = TRAIT_MINDSHIELD,
		"TRAIT_FAKE_MINDSHIELD" = TRAIT_FAKE_MINDSHIELD,
		"TRAIT_DISSECTED" = TRAIT_DISSECTED,
		"TRAIT_SIXTHSENSE" = TRAIT_SIXTHSENSE,
		"TRAIT_FEARLESS" = TRAIT_FEARLESS,
		"TRAIT_PARALYSIS_L_ARM" = TRAIT_PARALYSIS_L_ARM,
		"TRAIT_PARALYSIS_R_ARM" = TRAIT_PARALYSIS_R_ARM,
		"TRAIT_PARALYSIS_L_LEG" = TRAIT_PARALYSIS_L_LEG,
		"TRAIT_PARALYSIS_R_LEG" = TRAIT_PARALYSIS_R_LEG,
		"TRAIT_CANNOT_OPEN_PRESENTS" = TRAIT_CANNOT_OPEN_PRESENTS,
		"TRAIT_PRESENT_VISION" = TRAIT_PRESENT_VISION,
		"TRAIT_DISK_VERIFIER" = TRAIT_DISK_VERIFIER,
		"TRAIT_MULTILINGUAL" = TRAIT_MULTILINGUAL,
		"TRAIT_LINGUIST" = TRAIT_LINGUIST,
		"TRAIT_NOMOBSWAP" = TRAIT_NOMOBSWAP,
		"TRAIT_XRAY_VISION" = TRAIT_XRAY_VISION,
		"TRAIT_THERMAL_VISION" = TRAIT_THERMAL_VISION,
		"TRAIT_ABDUCTOR_TRAINING" = TRAIT_ABDUCTOR_TRAINING,
		"TRAIT_ABDUCTOR_SCIENTIST_TRAINING" = TRAIT_ABDUCTOR_SCIENTIST_TRAINING,
		"TRAIT_SURGEON" = TRAIT_SURGEON,
		"TRAIT_ABDUCTOR_SURGEON" = TRAIT_ABDUCTOR_SURGEON,
		"TRAIT_STRONG_GRABBER" = TRAIT_STRONG_GRABBER,
		"TRAIT_CALCIUM_HEALER" = TRAIT_CALCIUM_HEALER,
		"TRAIT_MAGIC_CHOKE" = TRAIT_MAGIC_CHOKE,
		"TRAIT_SOOTHED_THROAT" = TRAIT_SOOTHED_THROAT,
		"TRAIT_LAW_ENFORCEMENT_METABOLISM" = TRAIT_LAW_ENFORCEMENT_METABOLISM,
		"TRAIT_MEDICAL_METABOLISM" = TRAIT_MEDICAL_METABOLISM,
		"TRAIT_ALWAYS_CLEAN" = TRAIT_ALWAYS_CLEAN,
		"TRAIT_BOOZE_SLIDER" = TRAIT_BOOZE_SLIDER,
		"TRAIT_QUICK_CARRY" = TRAIT_QUICK_CARRY,
		"TRAIT_QUICKER_CARRY" = TRAIT_QUICKER_CARRY,
		"TRAIT_UNINTELLIGIBLE_SPEECH" = TRAIT_UNINTELLIGIBLE_SPEECH,
		"TRAIT_UNSTABLE" = TRAIT_UNSTABLE,
		"TRAIT_OIL_FRIED" = TRAIT_OIL_FRIED,
		"TRAIT_XENO_IMMUNE" = TRAIT_XENO_IMMUNE,
		"TRAIT_NECROPOLIS_INFECTED" = TRAIT_NECROPOLIS_INFECTED,
		"TRAIT_BEEFRIEND" = TRAIT_BEEFRIEND,
		"TRAIT_MEDICAL_HUD" = TRAIT_MEDICAL_HUD,
		"TRAIT_SECURITY_HUD" = TRAIT_SECURITY_HUD,
		"TRAIT_DIAGNOSTIC_HUD" = TRAIT_DIAGNOSTIC_HUD,
		"TRAIT_MEDIBOTCOMINGTHROUGH" = TRAIT_MEDIBOTCOMINGTHROUGH,
		"TRAIT_PASSTABLE" = TRAIT_PASSTABLE,
		"TRAIT_BLUSHING" = TRAIT_BLUSHING,
		"TRAIT_CRYING" = TRAIT_CRYING,
		"TRAIT_NOBLOCK" = TRAIT_NOBLOCK,
		"TRAIT_NANITECOMPATIBLE" = TRAIT_NANITECOMPATIBLE,
		"TRAIT_WARDED" = TRAIT_WARDED,
		"TRAIT_NONECRODISEASE" = TRAIT_NONECRODISEASE,
		"TRAIT_NICE_SHOT" = TRAIT_NICE_SHOT,
		"TRAIT_ALWAYS_STUBS" = TRAIT_ALWAYS_STUBS,
		"TRAIT_NAIVE" = TRAIT_NAIVE,
		"TRAIT_DROPS_ITEMS_ON_DEATH" = TRAIT_DROPS_ITEMS_ON_DEATH,
		"TRAIT_DRINKSBLOOD" = TRAIT_DRINKSBLOOD,
		"TRAIT_MINDSWAPPED" = TRAIT_MINDSWAPPED,
		"TRAIT_SOMMELIER" = TRAIT_SOMMELIER,
		"TRAIT_BARMASTER" = TRAIT_BARMASTER,
		"TRAIT_HIVE_BURNT" = TRAIT_HIVE_BURNT,
		"TRAIT_MOTH_BURNT" = TRAIT_MOTH_BURNT,
		"TRAIT_SPECIAL_TRAUMA_BOOST" = TRAIT_SPECIAL_TRAUMA_BOOST,
		"TRAIT_METALANGUAGE_KEY_ALLOWED" = TRAIT_METALANGUAGE_KEY_ALLOWED,
		"TRAIT_HYPERSPACED" = TRAIT_HYPERSPACED,
		"TRAIT_FREE_HYPERSPACE_MOVEMENT" = TRAIT_FREE_HYPERSPACE_MOVEMENT,
		"TRAIT_FAST_CUFF_REMOVAL" = TRAIT_FAST_CUFF_REMOVAL,
		"TRAIT_BLEED_HELD" = TRAIT_BLEED_HELD,
		"TRAIT_NO_BLOOD" = TRAIT_NO_BLOOD,
		"TRAIT_NO_BLEEDING" = TRAIT_NO_BLEEDING,
		"TRAIT_BLOOD_COOLANT" = TRAIT_BLOOD_COOLANT,
		"TRAIT_MADNESS_IMMUNE" = TRAIT_MADNESS_IMMUNE,
		"TRAIT_ALCOHOL_TOLERANCE" = TRAIT_ALCOHOL_TOLERANCE,
		"TRAIT_AGEUSIA" = TRAIT_AGEUSIA,
		"TRAIT_HEAVY_SLEEPER" = TRAIT_HEAVY_SLEEPER,
		"TRAIT_NIGHT_VISION" = TRAIT_NIGHT_VISION,
		"TRAIT_LIGHT_STEP" = TRAIT_LIGHT_STEP,
		"TRAIT_SPIRITUAL" = TRAIT_SPIRITUAL,
		"TRAIT_VORACIOUS" = TRAIT_VORACIOUS,
		"TRAIT_SELF_AWARE" = TRAIT_SELF_AWARE,
		"TRAIT_FREERUNNING" = TRAIT_FREERUNNING,
		"TRAIT_SKITTISH" = TRAIT_SKITTISH,
		"TRAIT_POOR_AIM" = TRAIT_POOR_AIM,
		"TRAIT_PROSOPAGNOSIA" = TRAIT_PROSOPAGNOSIA,
		"TRAIT_NEET" = TRAIT_NEET,
		"TRAIT_DRUNK_HEALING" = TRAIT_DRUNK_HEALING,
		"TRAIT_TAGGER" = TRAIT_TAGGER,
		"TRAIT_PHOTOGRAPHER" = TRAIT_PHOTOGRAPHER,
		"TRAIT_MUSICIAN" = TRAIT_MUSICIAN,
		"TRAIT_LIGHT_DRINKER" = TRAIT_LIGHT_DRINKER,
		"TRAIT_EMPATH" = TRAIT_EMPATH,
		"TRAIT_FRIENDLY" = TRAIT_FRIENDLY,
		"TRAIT_GRABWEAKNESS" = TRAIT_GRABWEAKNESS,
		"TRAIT_BRAIN_TUMOR" = TRAIT_BRAIN_TUMOR,
		"TRAIT_PROSKATER" = TRAIT_PROSKATER,
		"TRAIT_PLUSHIELOVER" = TRAIT_PLUSHIELOVER,
		"TRAIT_CAN_USE_NUKE" = TRAIT_CAN_USE_NUKE,
		"TRACKED_SENSORS_TRAIT" = TRACKED_SENSORS_TRAIT,
		"TRAIT_SUIT_SENSORS" = TRAIT_SUIT_SENSORS,
		"TRAIT_NANITE_SENSORS" = TRAIT_NANITE_SENSORS,
		"TRAIT_PSYCHIC_SENSE" = TRAIT_PSYCHIC_SENSE,
		"TRAIT_PLANTHEALING" = TRAIT_PLANTHEALING,
		"TRAIT_NORADDAMAGE" = TRAIT_NORADDAMAGE,
		"TRAIT_MOBILE" = TRAIT_MOBILE
	),
	/obj/item/integrated_circuit = list(
		"TRAIT_COMPONENT_MMI" = TRAIT_COMPONENT_MMI,
	),
	/obj/item/bodypart = list(
		"TRAIT_PARALYSIS" = TRAIT_PARALYSIS,
		"TRAIT_DISABLED_BY_WOUND" = TRAIT_DISABLED_BY_WOUND
	),
	/obj/item = list(
		"TRAIT_NODROP" = TRAIT_NODROP,
		"TRAIT_NO_STORAGE_INSERT" = TRAIT_NO_STORAGE_INSERT,
		"TRAIT_SPRAYPAINTED" = TRAIT_SPRAYPAINTED,
		"TRAIT_T_RAY_VISIBLE" = TRAIT_T_RAY_VISIBLE,
		"TRAIT_FOOD_FRIED" = TRAIT_FOOD_FRIED,
		"TRAIT_NO_TELEPORT" = TRAIT_NO_TELEPORT,
		"TRAIT_STARGAZED" = TRAIT_STARGAZED,
		"TRAIT_DOOR_PRYER" = TRAIT_DOOR_PRYER,
		"TRAIT_FISH_SAFE_STORAGE" = TRAIT_FISH_SAFE_STORAGE,
		"TRAIT_FISH_CASE_COMPATIBILE" = TRAIT_FISH_CASE_COMPATIBILE,
		"TRAIT_NEEDS_TWO_HANDS" = TRAIT_NEEDS_TWO_HANDS,
		"TRAIT_AI_BAGATTACK" = TRAIT_AI_BAGATTACK,
		"TRAIT_ALLOW_HERETIC_CASTING" = TRAIT_ALLOW_HERETIC_CASTING,
		"TRAIT_LIVING_HEART" = TRAIT_LIVING_HEART,
		"TRAIT_NO_STRIP" = TRAIT_NO_STRIP,
		"TRAIT_DRYABLE" = TRAIT_DRYABLE,
		"TRAIT_DRIED" = TRAIT_DRIED,
		"TRAIT_CUSTOMIZABLE_REAGENT_HOLDER" = TRAIT_CUSTOMIZABLE_REAGENT_HOLDER,
		"TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT" = TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT,
	),
	/obj = list(
		"TRAIT_FROZEN" = TRAIT_FROZEN
	),
	/atom/movable = list(
		"TRAIT_AREA_SENSITIVE" = TRAIT_AREA_SENSITIVE,
		"TRAIT_HEARING_SENSITIVE" = TRAIT_HEARING_SENSITIVE,
		"TRAIT_MOVE_GROUND" = TRAIT_MOVE_GROUND,
		"TRAIT_MOVE_FLYING" = TRAIT_MOVE_FLYING,
		"TRAIT_MOVE_VENTCRAWLING" = TRAIT_MOVE_VENTCRAWLING,
		"TRAIT_MOVE_FLOATING" = TRAIT_MOVE_FLOATING,
		"TRAIT_MOVE_PHASING" = TRAIT_MOVE_PHASING,
		"TRAIT_NO_FLOATING_ANIM" = TRAIT_NO_FLOATING_ANIM
	),
	/atom = list(
		"TRAIT_KEEP_TOGETHER" = TRAIT_KEEP_TOGETHER,
		"TRAIT_NO_IMMOBILIZE" = TRAIT_NO_IMMOBILIZE,
	),
	/turf = list(
		"TRAIT_FIREDOOR_STOP" = TRAIT_FIREDOOR_STOP,
		"TURF_Z_TRANSPARENT_TRAIT" = TURF_Z_TRANSPARENT_TRAIT
	),
	/datum/controller/subsystem/processing/station = list(
		"STATION_TRAIT_BANANIUM_SHIPMENTS" = STATION_TRAIT_BANANIUM_SHIPMENTS,
		"STATION_TRAIT_CARP_INFESTATION" = STATION_TRAIT_CARP_INFESTATION,
		"STATION_TRAIT_PREMIUM_INTERNALS" = STATION_TRAIT_PREMIUM_INTERNALS,
		"STATION_TRAIT_LATE_ARRIVALS" = STATION_TRAIT_LATE_ARRIVALS,
		"STATION_TRAIT_RANDOM_ARRIVALS" = STATION_TRAIT_RANDOM_ARRIVALS,
		"STATION_TRAIT_HANGOVER" = STATION_TRAIT_HANGOVER,
		"STATION_TRAIT_FILLED_MAINT" = STATION_TRAIT_FILLED_MAINT,
		"STATION_TRAIT_EMPTY_MAINT" = STATION_TRAIT_EMPTY_MAINT,
		"STATION_TRAIT_PDA_GLITCHED" = STATION_TRAIT_PDA_GLITCHED,
		"STATION_TRAIT_DISTANT_SUPPLY_LINES" = STATION_TRAIT_DISTANT_SUPPLY_LINES,
		"STATION_TRAIT_STRONG_SUPPLY_LINES" = STATION_TRAIT_STRONG_SUPPLY_LINES,
		"STATION_TRAIT_UNITED_BUDGET" = STATION_TRAIT_UNITED_BUDGET
	)
	))

/// value -> trait name, generated on use from trait_by_type global
GLOBAL_LIST(trait_name_map)

/proc/generate_trait_name_map()
	. = list()
	for(var/key in GLOB.traits_by_type)
		for(var/tname in GLOB.traits_by_type[key])
			var/val = GLOB.traits_by_type[key][tname]
			.[val] = tname


GLOBAL_LIST_INIT(movement_type_trait_to_flag, list(
	TRAIT_MOVE_GROUND = GROUND,
	TRAIT_MOVE_FLYING = FLYING,
	TRAIT_MOVE_VENTCRAWLING = VENTCRAWLING,
	TRAIT_MOVE_FLOATING = FLOATING,
	TRAIT_MOVE_PHASING = PHASING
	))

GLOBAL_LIST_INIT(movement_type_addtrait_signals, set_movement_type_addtrait_signals())
GLOBAL_LIST_INIT(movement_type_removetrait_signals, set_movement_type_removetrait_signals())

/proc/set_movement_type_addtrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_ADDTRAIT(trait)

/proc/set_movement_type_removetrait_signals(signal_prefix)
	. = list()
	for(var/trait in GLOB.movement_type_trait_to_flag)
		. += SIGNAL_REMOVETRAIT(trait)
