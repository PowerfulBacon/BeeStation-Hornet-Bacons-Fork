/datum/nanossembly_line/berr
	var/datum/nanossembly_line/b/inbuilt_branch = new

/datum/nanossembly_line/berr/execute(datum/nanossembly_interpreter/parent)
	//Set operands
	if(!inbuilt_branch.operands)
		inbuilt_branch.operands = operands
	//Branch if the equal flag is set
	if(parent.registers[FLAG_REGISTER] & ERROR_FLAG)
		inbuilt_branch.execute(parent)
		parent.clear_error()
