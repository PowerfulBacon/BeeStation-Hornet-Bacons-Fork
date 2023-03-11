/datum/component/anomaly_base
	/// Anomaly effect structure
	var/datum/anomaly_action/base_action

/datum/component/anomaly_base/Initialize(anomaly_tag)
	. = ..()
	base_action = SSanomaly_science.create_anomaly_effect(src, anomaly_tag)
	if (isobj(parent))
		var/obj/O = parent
		// Anomalies need to be able to be hit
		O.obj_flags |= CAN_BE_HIT

/datum/component/anomaly_base/UnregisterFromParent()
	base_action.deactive_anomaly(src)


