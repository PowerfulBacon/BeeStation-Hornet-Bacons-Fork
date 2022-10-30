/datum/component/anomaly_base
	/// Anomaly effect structure
	var/datum/anomaly_action/base_action

/datum/component/anomaly_base/Initialize(anomaly_tag)
	. = ..()
	base_action = SSanomaly_science.create_anomaly_effect(src, anomaly_tag)
