/*
 * Allows brackets to manipulate the order of operations.
 * This is a special one that doesn't add any other operations
 */

/datum/dmscript/compiler_operation/brackets
	//The regex to check for this operation
	//Just detect any brackets anywhere
	check_regex = new /regex(@"\(.*\)")
	//The priority to check this operation
	priority = PRECEDENCE_BRACKET

/datum/dmscript/compiler_operation/brackets/process_operation(text_line, list/subparts)
	//Locate the closing bracket
	var/start_bracket_index = findtext(text_line, "(")
	var/close_bracket_index

	var/bracket_count = 0
	var/index = 1
	for (var/i in start_bracket_index to length(text_line))
		var/character = copytext(text_line, i, i+1)
		if (character == "(")
			bracket_count ++
		else if (character == ")")
			bracket_count --
			if(bracket_count == 0)
				close_bracket_index = start_bracket_index + index
				break
		index ++

	//Create a new group for this and replace it
	var/created_group = copytext(text_line, start_bracket_index + 1, close_bracket_index - 1)
	var/group_identifier = "_[length(subparts)]"
	text_line = splicetext(text_line, start_bracket_index, close_bracket_index, group_identifier)
	//We also need to recursively process the part that we just broke down
	subparts[group_identifier] = ""
	subparts[group_identifier] = recursively_process(created_group, subparts)
	return recursively_process(text_line, subparts)
