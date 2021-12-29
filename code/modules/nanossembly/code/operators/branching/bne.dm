/datum/nanossembly_line/bne
	var/datum/nanossembly_line/b/inbuilt_branch = new

/datum/nanossembly_line/bne/execute(datum/nanossembly_interpreter/parent)
	//Set operands
	if(!inbuilt_branch.operands)
		inbuilt_branch.operands = operands
	//Branch if the equal flag isn't set
	if(!(parent.registers[FLAG_REGISTER] & EQUAL_FLAG))
		inbuilt_branch.execute(parent)
