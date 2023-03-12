/datum/anomaly_action_result
	var/success
	var/result

/datum/anomaly_action_result/New(success, result)
	..()
	src.success = success
	src.result = result
