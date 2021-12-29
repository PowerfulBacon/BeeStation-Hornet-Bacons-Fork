/datum/nanossembly_line/blt
	var/datum/nanossembly_line/b/inbuilt_branch = new

/datum/nanossembly_line/blt/execute(datum/nanossembly_interpreter/parent)
	//Set operands
	if(!inbuilt_branch.operands)
		inbuilt_branch.operands = operands
	//Branch if not greater than and not equal to
	if(!((parent.registers[FLAG_REGISTER] & GREATER_FLAG) || (parent.registers[FLAG_REGISTER] & EQUAL_FLAG)))
		inbuilt_branch.execute(parent)
