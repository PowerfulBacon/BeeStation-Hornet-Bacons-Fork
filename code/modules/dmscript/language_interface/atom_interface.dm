/datum
	/// Procs defined by DMscripts
	var/list/dmscript_procs = null
	/// Variables defined by dmscript. Lazylist,
	var/list/dmscript_vars = null

/datum/proc/DmScriptGetVar(varname)
	//DMscript > DM since we can search it faster
	if(dmscript_vars[varname])
		return dmscript_vars[varname]
	return vars[varname]

/datum/proc/DmScriptSetVar(varname, newvalue)
	//DMscript > DM since we can search it faster
	if(dmscript_vars[varname])
		dmscript_vars[varname] = newvalue
		return
	vars[varname] = newvalue

/datum/proc/DmScriptCall(function_name, ...)
	var/datum/dmscript/procedure/located_proc = dmscript_procs[function_name]
	//DMscript > DM since we can search it faster
	if(located_proc)
		return located_proc.do_call(src, args)
	else
		return call(src, function_name)(arglist(args))
