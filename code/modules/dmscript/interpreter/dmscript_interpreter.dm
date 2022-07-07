GLOBAL_LIST_EMPTY(dmscript_references)

/proc/execute(datum/source, list/datum/dmscript/instruction/bytecode)
	var/local_state = list()
	for (var/datum/dmscript/instruction/instruction in bytecode)
		instruction.execute(local_state)
	message_admins("Local state after execution:")
	message_admins(json_encode(local_state))
