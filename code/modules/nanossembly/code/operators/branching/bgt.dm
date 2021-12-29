/datum/nanossembly_line/bgt
	var/datum/nanossembly_line/b/inbuilt_branch = new

/datum/nanossembly_line/bgt/execute(datum/nanossembly_interpreter/parent)
	//Set operands
	if(!inbuilt_branch.operands)
		inbuilt_branch.operands = operands
	//Branch if greater than
	if(parent.registers[FLAG_REGISTER] & GREATER_FLAG)
		inbuilt_branch.execute(parent)
