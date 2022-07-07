/datum/dmscript/instruction/multiply
	//The identifier of the instruction (Not instanced)
	identifier = BYTECODE_MULTIPLY

/datum/dmscript/instruction/multiply/execute(list/data_store)
	var/first_param = data_store[parameters[1]]
	var/second_param = data_store[parameters[2]]
	data_store[result_store] = first_param * second_param
