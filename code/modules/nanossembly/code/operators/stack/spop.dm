/datum/nanossembly_line/spush/is_valid(datum/nanossembly_interpreter/parent)
	//Must have 1 register operand
	return length(operands) == 1 && operands[1][1] == "R"

/datum/nanossembly_line/spush/execute(datum/nanossembly_interpreter/parent)
	if(length(parent.stack) == 0)
		//Set the error bit
		parent.set_error()
		return
	//Get the top element
	var/top_element = length(parent.stack)
	//Get the value
	var/top_value = parent[top_element]
	//Remove from the stack
	parent.stack.Remove(top_value)
	//Put the collected value into the register
	parent.put_in_register(operands[1], top_value)
