/datum/nanossembly_line
	//The operands
	var/list/operands

///Checks if the code line is valid (good number of ops etc.)
/datum/nanossembly_line/proc/is_valid(datum/nanossembly_interpreter/parent)
	return FALSE

///Execute the line
/datum/nanossembly_line/proc/execute(datum/nanossembly_interpreter/parent)
	return
