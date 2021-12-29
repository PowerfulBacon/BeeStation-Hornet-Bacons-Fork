/datum/nanossembly_line/b/is_valid(datum/nanossembly_interpreter/parent)
	return length(operands) == 1

/datum/nanossembly_line/b/execute(datum/nanossembly_interpreter/parent)
	var/destination = -1
	//Check if parameter is a number or a label
	if(operands[1][1] == "R" || operands[1][1] == "#")
		destination = parent.get_value(operands[1])
	else
		//Compilation error if label is not present
		if(!(operands[1] in parent.program.labels))
			parent.compiler_error("Branch failed: Destination label ([operands[1]]) not found!")
			return
		//Set destination
		destination = parent.program.labels[operands[1]]
	if(destination == -1)
		parent.compiler_error("Branch failed: Could not find destination label (destination label unknown)")
		return
	//Branch to this position, subtract 1 as completing execution increments the program counter
	parent.put_in_register(PROGRAM_REGISTER, destination - 1)
