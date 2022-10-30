#define ANOMALY_FILEPATH "config/science/"

SUBSYSTEM_DEF(anomaly_science)
	name = "Anomaly Science"
	flags = SS_NO_FIRE
	///Assoc list of all loaded anomalies by key
	var/list/loaded_anomalies

/datum/controller/subsystem/anomaly_science/Initialize(start_timeofday)
	. = ..()
	//Load all anomaly data files
	loaded_anomalies = list()
	for (var/filepath in flist(ANOMALY_FILEPATH))
		//Read the file
		var/list/grouped_anomalies = parse_anomdat("[ANOMALY_FILEPATH][filepath]")
		for (var/anomaly_key in grouped_anomalies)
			loaded_anomalies[anomaly_key] = grouped_anomalies[anomaly_key]

/datum/controller/subsystem/anomaly_science/proc/create_anomaly_effect(datum/component/anomaly_base/anomaly, anomaly_tag)
	if (!loaded_anomalies[anomaly_tag])
		CRASH("Unknown anomaly effect tag: '[anomaly_tag]'")
	var/datum/parsed_anomaly_data/located_anomaly = loaded_anomalies[anomaly_tag]
	//Create the anomaly action tree
	var/datum/anomaly_action/created = located_anomaly.create()
	//Run initialisation action
	created.initialise_anomaly(anomaly)
	return created
