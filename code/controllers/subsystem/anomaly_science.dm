#define ANOMALY_FILEPATH "config/science/"

PROCESSING_SUBSYSTEM_DEF(anomaly_science)
	name = "Anomaly Science"
	wait = 1 SECONDS
	flags = NONE

	/// The global flux entropy level (Per-z group)
	var/list/flux_entropy = list()

	/// Assoc list of all loaded anomalies by key
	var/list/loaded_anomalies

/datum/controller/subsystem/processing/anomaly_science/Initialize(start_timeofday)
	. = ..()
	// Create flux levels
	create_flux_levels()
	load_anomalies()

/datum/controller/subsystem/processing/anomaly_science/proc/load_anomalies()
	// Load all anomaly data files
	loaded_anomalies = list()
	for (var/filepath in flist(ANOMALY_FILEPATH))
		//Read the file
		var/list/grouped_anomalies = parse_anomdat("[ANOMALY_FILEPATH][filepath]")
		for (var/anomaly_key in grouped_anomalies)
			loaded_anomalies[anomaly_key] = grouped_anomalies[anomaly_key]

/datum/controller/subsystem/processing/anomaly_science/proc/create_anomaly_effect(datum/component/anomaly_base/anomaly, anomaly_tag)
	if (!loaded_anomalies[anomaly_tag])
		CRASH("Unknown anomaly effect tag: '[anomaly_tag]'")
	var/datum/parsed_anomaly_data/located_anomaly = loaded_anomalies[anomaly_tag]
	//Create the anomaly action tree
	var/datum/anomaly_action/created = located_anomaly.create()
	//Run initialisation action
	created.initialise_anomaly(anomaly)
	return created

/datum/controller/subsystem/processing/anomaly_science/fire(resumed)
	// Processing
	..()
	// Update global flux levels, they get less fluxy over
	// time, which promotes spawning behaviours
	if (ticks % 6 == 0)
		// This is measured in minutes
		var/proportion = (6 * wait) / 1 MINUTES
		var/multiplication_amount = 0.5 ** (proportion / FLUX_HALF_LIFE)
		for (var/group in flux_entropy)
			if (!group)
				for (var/z_level in flux_entropy["[group]"])
					flux_entropy["[group]"]["[z_level]"] *= multiplication_amount
			else
				flux_entropy["[group]"] *= multiplication_amount

/datum/controller/subsystem/processing/anomaly_science/proc/MaxZChanged()
	create_flux_levels()

/// Create any missing z-levels
/datum/controller/subsystem/processing/anomaly_science/proc/create_flux_levels()
	for (var/z in 1 to world.maxz)
		var/flux_group = SSmapping.level_trait(z, ZTRAIT_FLUX_GROUP)
		if (!flux_entropy)
			var/list/independent_flux = flux_entropy["[0]"]
			if (!independent_flux["[z]"])
				independent_flux["[z]"] = DEFAULT_FLUX_VALUE
		else
			if (!flux_entropy["[flux_group]"])
				flux_entropy["[flux_group]"] = DEFAULT_FLUX_VALUE

/datum/controller/subsystem/processing/anomaly_science/proc/get_flux_level(z_value)
	var/flux_group = SSmapping.level_trait(z_value, ZTRAIT_FLUX_GROUP)
	if (!flux_entropy)
		var/list/independent_flux = flux_entropy["[0]"]
		return independent_flux["[z_value]"]
	return flux_entropy["[flux_group]"]

/datum/controller/subsystem/processing/anomaly_science/proc/set_flux_level(z_value, new_value)
	var/flux_group = SSmapping.level_trait(z_value, ZTRAIT_FLUX_GROUP)
	if (!flux_entropy)
		var/list/independent_flux = flux_entropy["[0]"]
		independent_flux["[z_value]"] = new_value
		return
	flux_entropy["[flux_group]"] = new_value

/datum/controller/subsystem/processing/anomaly_science/proc/check_anomaly_appearance(z_level)
	// Anomalies cannot spawn here
	if (!SSmapping.level_trait(z_level, ZTRAIT_ANOMALY_SPAWNING))
		return FALSE
	// Check anomaly spawn probability


/datum/controller/subsystem/processing/anomaly_science/get_metrics()
	. = ..()
	.["flux_levels"] = flux_entropy
