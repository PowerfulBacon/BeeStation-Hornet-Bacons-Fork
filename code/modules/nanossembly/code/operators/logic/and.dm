/datum/nanossembly_line/and/is_valid(datum/nanossembly_interpreter/parent)
	return length(operands) == 3 && operands[1][1] == "R"

/datum/nanossembly_line/and/execute(datum/nanossembly_interpreter/parent)
	parent.put_in_register(operands[1], parent.get_value(operands[2]) & parent.get_value(operands[3]))
