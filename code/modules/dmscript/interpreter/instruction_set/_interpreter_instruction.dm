/datum/dmscript/instruction
	//The identifier of the instruction (Not instanced)
	var/identifier
	//The parameters
	//Associative, FALSE for value, TRUE for reference
	var/list/parameters
	//The result store
	var/result_store

/datum/dmscript/instruction/New(list/params, result)
	. = ..()
	parameters = params
	result_store = result

/datum/dmscript/instruction/proc/execute(list/data_store)
	//Default: Directly store
	var/first_param = parameters[1]
	var/is_reference = parameters[first_param]
	if(is_reference)
		data_store[result_store] = data_store[first_param]
	else
		data_store[result_store] = text2num(first_param)
