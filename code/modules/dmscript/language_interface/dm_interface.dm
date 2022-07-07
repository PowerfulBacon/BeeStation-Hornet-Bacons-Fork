
/// Global lookup of function lookups
/// Type.Name
GLOBAL_LIST_EMPTY(dmscript_function_lookup)

/proc/DmScriptCall(function_name, ...)
	//Locate the function we are calling
	var/datum/dmscript/procedure/located_proc = GLOB.dmscript_function_lookup[function_name]
	if (!located_proc)
		CRASH("Unable to locate DMscript proc with the name [function_name]")
	located_proc.do_call(null, args)
