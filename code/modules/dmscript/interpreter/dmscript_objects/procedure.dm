/datum/dmscript/procedure
	var/list/datum/dmscript/instruction/bytecode

/datum/dmscript/procedure/proc/do_call(datum/source, ...)
	execute(source, bytecode)
