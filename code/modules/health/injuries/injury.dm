/datum/injury
	//Name of the injury
	var/name
	//Does the injury stack
	var/can_stack = FALSE
	//Damage applied
	var/applied_damage = 0
	//The scar damage amount
	var/scar_damage_amount = 0
	//=============
	// Injury Type Helpers
	// Required since byond doesn't support static procs
	//=============
	//Injury severity
	var/minor_severity_type
	var/major_severity_type
	var/critical_severity_type
