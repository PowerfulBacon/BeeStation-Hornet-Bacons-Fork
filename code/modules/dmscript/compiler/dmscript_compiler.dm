GLOBAL_LIST_EMPTY(dmscript_recent)

/client/verb/print_dmscript()
	set name = "print recent dmscript"
	set category = "dmscript"

	if(!check_rights(R_DMSCRIPT))
		to_chat(usr, "<span class='warning'>You do not have permissions to use this verb!</span>")
		return

	var/i = 1
	for (var/datum/dmscript/instruction/instruction in GLOB.dmscript_recent)
		message_admins("[i++]:\t[instruction.identifier] [instruction.result_store] {[instruction.parameters.Join(",")]}")

/client/verb/run_script_verb()
	set name = "execute dmscript"
	set category = "dmscript"

	if(!check_rights(R_DMSCRIPT))
		to_chat(usr, "<span class='warning'>You do not have permissions to use this verb!</span>")
		return

	var/input = capped_multiline_input(usr, "Enter your script code:", "DMScript Code")
	if(!input)
		return

	//Run and execute
	var/list/compiled = compile("temp", input)
	execute(null, compiled)

/proc/compile(filename, dmscript_text)
	//Remove regular comments
	var/regex/comment = new(@"\/\*(?:.|\n|\r)*\*/", "g")
	dmscript_text = comment.Replace(dmscript_text, "")

	//Remove block comments
	var/regex/block_comment = new(@"^\s*?\/\/", "gm")
	dmscript_text = block_comment.Replace(dmscript_text, "")

	//Literally just process each line and directly convert it
	var/list/split_text = splittext(dmscript_text, "\n")

	//The output bytecode
	var/list/output = list()

	//Process each line individually
	//It's primitive, but it works since its a scripting language
	//The compiler does the hard regex work so the interpreter can do the simpler stuff
	for (var/text_line in split_text)
		//Determine what this line is doing
		var/list/bytecode = process_dmscript_line(text_line)
		for (var/register in bytecode)
			//Convert the output lines into DMscript instructions
			var/instruction_type = /datum/dmscript/instruction
			//Find the correct instruction type
			var/bytecode_line = bytecode[register]
			for (var/datum/dmscript/instruction/type as() in subtypesof(instruction_type))
				if (findtext(bytecode_line, initial(type.identifier)))
					instruction_type = type
					break
			//Calculate the parameters
			var/list/params = splittext(bytecode_line, " ")
			var/list/param_types = list()
			if(length(params) > 1)
				params.Remove(params[1])
			//Calculate the parameter type
			for (var/param in params)
				if(findtext(param, "%"))
					param_types["[param]"] = PARAMETER_REFERENCE
				else if(findtext(param, "_"))
					param_types["[param]"] = PARAMETER_REGISTER
				else
					param_types["[param]"] = PARAMETER_VALUE
			//Do it
			output += new instruction_type(param_types, register)

	//For debugging
	GLOB.dmscript_recent = output
	return output

	//Actually, its easier to not do it to files, since we need to cache it anyway
/*
	//Write to a file
	var/path = "[DMSCRIPT_DIRECTORY][DMSCRIPT_COMPILED]/[filename][DMSCRIPT_BYTECODE_EXTENSION]"
	fdel(path)
	message_admins("Successfully compiled [path]")
	text2file(output.Join("\n"), path)
*/

///Processes a dmscript line and returns a list of bytecode instructions
/proc/process_dmscript_line(dmscript_line)
	//Subdivide the line into simpler mathematical blocks
	//var/A=(B*(C-D))/E
	//Will be gradually divided down into base expressions:
	//A base expression contains only a single operation
	//==============
	//var/A = _1/E
	//_1: B*(C-D)
	//==============
	//_2 = _3
	//_1: B*(C-D)
	//_2: var/A		(Base)
	//_3: _1/E		(Base)
	//==============
	//_2 = _3
	//_1: B*_4		(Base)
	//_2: var/A		(Base)
	//_3: _1/E		(Base)
	//_4: C-D		(Base)
	//==============
	//Order the operations by their usage
	//_4: C-D		(Base)
	//_1: B*_4		(Base)
	//_3: _1/E		(Base)
	//_2: var/A		(Base)
	//_2 = _3
	//==============
	//Convert to bytecode
	//SUBTRACT _4 C D
	//MULTIPLY _1 B _4
	//DIVIDE _3 _1 E
	//CREATE_VAR _2 'A'
	//ASSIGN _2 _3
	//==============
	var/list/generated_groups = list()
	var/processed = recursively_process(dmscript_line, generated_groups)
	//Reorder the groups
	generated_groups = recalculate_order(generated_groups)
	//Add on the final command
	generated_groups["_"] = processed
	return generated_groups

///Recalculate the order of the groups. If _1 calls _0, _0 should be calculated first
/proc/recalculate_order(list/groups)
	//Regex to identify groups
	var/regex/group_identifier_regex = new(@"_\d+", "gm")
	var/list/group_dictionary = list()
	//Build a list of groups and what groups they depend upon
	for (var/group_identifier in groups)
		var/list/matches = list()
		while(group_identifier_regex.Find(groups[group_identifier]))
			matches += group_identifier_regex.match
		group_dictionary[group_identifier] = matches
	//This contains a list of safe groups
	var/list/safe_groups = list()
	var/list/output = list()
	while (length(groups))
		for (var/group_id in groups)
			var/list/dependant_groups = group_dictionary[group_id]
			//Check if the group is fine to insert
			var/valid = TRUE
			for (var/dependant_group in dependant_groups)
				if(!safe_groups[dependant_group])
					valid = FALSE
					break
			if(!valid)
				continue
			//Add it to the output
			output[group_id] = groups[group_id]
			//Remove the group
			groups -= group_id
			//Mark the group as safe
			safe_groups[group_id] = TRUE
	return output

//I tried to do this with BNF, but that was hard as balls. Especially when I tried to implement regex into it.
//Instead we just have regex instructions that we check in order. Its way simpler.
/// Processes the line, finds the instruction it should handle first, parses it which then will call this again to handle its subgroups
/proc/recursively_process(text, list/subparts)
	//Locate all compiler operations
	var/static/list/datum/dmscript/compiler_operation/compiler_operations
	//Haven't been loaded yet
	if(isnull(compiler_operations))
		compiler_operations = list()
		for (var/path in subtypesof(/datum/dmscript/compiler_operation))
			compiler_operations += new path()
		compiler_operations = sortList(compiler_operations, /proc/cmp_compiler_operation)
	//Run through the list
	for (var/datum/dmscript/compiler_operation/operation as() in compiler_operations)
		if (operation.is_valid(text))
			return operation.process_operation(text, subparts)
	return text

/proc/cmp_compiler_operation(datum/dmscript/compiler_operation/A, datum/dmscript/compiler_operation/B)
	return A.priority - B.priority
