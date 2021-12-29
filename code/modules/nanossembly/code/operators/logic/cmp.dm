/datum/nanossembly_line/cmp/is_valid(datum/nanossembly_interpreter/parent)
	return length(operands) == 2

/datum/nanossembly_line/cmp/execute(datum/nanossembly_interpreter/parent)
	parent.reset_comparision_flags()
	var/value_1 = parent.get_value(operands[1])
	var/value_2 = parent.get_value(operands[2])
	if(value_1 == value_2)
		parent.set_equal()
	if(value_1 > value_2)
		parent.set_greater()
