/datum/nanossembly_line/mov/is_valid(datum/nanossembly_interpreter/parent)
	//Must have 1 register operand
	return length(operands) == 2 && operands[1][1] == "R"

/datum/nanossembly_line/mov/execute(datum/nanossembly_interpreter/parent)
	parent.put_in_register(operands[1], parent.get_value(operands[2]))
