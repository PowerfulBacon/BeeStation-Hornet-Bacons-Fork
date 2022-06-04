/// Gets an injury type from a provided basetype, sharpness and severity
/proc/get_injury_type(datum/injury/base_type, severity)
	return initial(base_type.severity)
