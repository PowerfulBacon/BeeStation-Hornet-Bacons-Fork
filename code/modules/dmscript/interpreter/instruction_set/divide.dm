/datum/dmscript/instruction/divide
	//The identifier of the instruction (Not instanced)
	identifier = BYTECODE_DIVIDE

/datum/dmscript/instruction/divide/execute(list/data_store)
	var/first_param = data_store[parameters[1]]
	var/second_param = data_store[parameters[2]]
	data_store[result_store] = first_param / second_param
