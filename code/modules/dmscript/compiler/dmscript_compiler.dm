
/proc/compile(dmscript_text)
	//Any compiler errors that occured
	var/list/compiler_errors = list()

	//Remove regular comments
	COMMENT_TRIMMER(comment)
	dmscript_text = comment.Replace(dmscript_text, "")

	//Remove block comments
	BLOCK_COMMENT_TRIMMER(block_comment)
	dmscript_text = block_comment.Replace(dmscript_text, "")

	//Literally just process each line and directly convert it
	var/list/split_text = splittext(dmscript_text, "\n")

	//Process each line individually
	//It's primitive, but it works since its a scripting language
	//The compiler does the hard regex work so the interpreter can do the simpler stuff
	for (var/text_line in split_text)
		//Determine what this line is doing

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
	recursively_process(dmscript_line, generated_groups, 0)

//I tried to do this with BNF, but that was hard as balls. Especially when I tried to implement regex into it.
/proc/recursively_process(text, list/groups, lowest_group_number)
	//Firstly, locate brackets
	if (findtext(text, "("))
		//Locate the closing bracket
		var/start_bracket_index = findtext(text, "(")
		var/close_bracket_index

		var/bracket_count = 1
		var/index = 1
		for (var/character in copytext(text, start_bracket_index))
			if (character == "(")
				bracket_count ++
			else if (character == ")")
				bracket_count --
				if(bracket_count == 0)
					close_bracket_index = start_bracket_index + index
					break
			index ++

		//Create a new group for this and replace it
		var/created_group = copytext(text, start_bracket_index, close_bracket_index)
		var/group_identifier = "_[lowest_group_number]"
		text = splicetext(text, start_bracket_index, close_bracket_index, group_identifier)
		groups[group_identifier] = created_group
		recursively_process(text, groups, lowest_group_number + 1)
		return
