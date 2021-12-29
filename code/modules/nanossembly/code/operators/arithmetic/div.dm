/datum/nanossembly_line/div/is_valid(datum/nanossembly_interpreter/parent)
	return length(operands) == 3 && operands[1][1] == "R"

/datum/nanossembly_line/div/execute(datum/nanossembly_interpreter/parent)
	//Division by 0 exception
	if(parent.get_value(operands[3]) == 0)
		parent.set_error()
		return
	parent.put_in_register(operands[1], parent.get_value(operands[2]) / parent.get_value(operands[3]))
