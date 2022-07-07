/*
 * The equal operator
 * var/a = b
 * Has the lowest precedence
 */

/datum/dmscript/compiler_operation/variable_creation
	//The regex to check for this operation
	//Just detect any brackets anywhere
	check_regex = new /regex(@"var\/(\w+)", "m")
	//The priority to check this operation
	priority = PRECEDENCE_PRIMARY

/datum/dmscript/compiler_operation/variable_creation/process_operation(text_line, list/subparts)
	var/regex/sample_regex = new(check_regex.name, check_regex.flags)
	sample_regex.Find(text_line)
	var/variable_identifier = trim_right(sample_regex.group[1])

	//Create the local variable
	var/group1 = "_[length(subparts)]"
	subparts[group1] = "0"
	var/left_group_identifier = "_[length(subparts)]"
	subparts[left_group_identifier] = "[BYTECODE_ASSIGN] %[variable_identifier]% [group1]"

	text_line = replacetext(text_line, "var/[variable_identifier]", left_group_identifier)

	return recursively_process(text_line, subparts)
