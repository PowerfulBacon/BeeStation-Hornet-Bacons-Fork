/*
 * The equal operator
 * var/a = b
 * Has the lowest precedence
 */

/datum/dmscript/compiler_operation/subtract
	//The regex to check for this operation
	//Just detect any brackets anywhere
	check_regex = new /regex(@"^(.+[^-])\-([^-].+)$", "m")
	//The priority to check this operation
	priority = PRECEDENCE_ADDITIVE

/datum/dmscript/compiler_operation/subtract/process_operation(text_line, list/subparts)
	var/regex/sample_regex = new(check_regex.name, check_regex.flags)
	sample_regex.Find(text_line)
	var/left_side = trim_right(sample_regex.group[1])
	var/right_side = trim(sample_regex.group[2])
	var/left_group_identifier = "_[length(subparts)]"
	subparts[left_group_identifier] = ""
	subparts[left_group_identifier] = recursively_process(left_side, subparts)
	var/right_group_identifier = "_[length(subparts)]"
	subparts[right_group_identifier] = ""
	subparts[right_group_identifier] = recursively_process(right_side, subparts)
	return "[BYTECODE_SUBTRACT] [left_group_identifier] [right_group_identifier]"
