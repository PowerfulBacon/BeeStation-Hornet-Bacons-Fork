/datum/dmscript/compiler_operation
	//The regex to check for this operation
	var/regex/check_regex
	//The priority to check this operation
	var/priority = 0

/datum/dmscript/compiler_operation/proc/is_valid(text_line)
	return check_regex?.Find(text_line)

/datum/dmscript/compiler_operation/proc/process_operation(text_list, list/subparts)
	return
