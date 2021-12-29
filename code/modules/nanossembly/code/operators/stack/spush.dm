/datum/nanossembly_line/spush/is_valid(datum/nanossembly_interpreter/parent)
	//Must have 1 operand
	return length(operands) == 1

/datum/nanossembly_line/spush/execute(datum/nanossembly_interpreter/parent)
	if(length(parent.stack) >= MAXIMUM_STACK_SIZE)
		//Set the error bit
		parent.set_error()
		return
	parent.stack.Add(operands[1])
