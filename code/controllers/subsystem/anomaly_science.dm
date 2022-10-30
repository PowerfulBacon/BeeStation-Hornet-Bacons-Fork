#define ANOMALY_FILEPATH "/config/science/"

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
		
