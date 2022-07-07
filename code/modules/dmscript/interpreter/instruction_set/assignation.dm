/datum/dmscript/instruction/assign
	//The identifier of the instruction (Not instanced)
	identifier = BYTECODE_ASSIGN

/datum/dmscript/instruction/assign/execute(list/data_store)
	//Get the value
	var/second_param = data_store[parameters[2]]

	var/first_param_value = data_store[parameters[1]]
	if(istype(first_param_value, /datum/dmscript/reference))
		var/datum/dmscript/reference/ref = first_param_value
		ref.put(second_param)
	else
		data_store[parameters[1]] = second_param

	data_store[result_store] = parameters[1]
