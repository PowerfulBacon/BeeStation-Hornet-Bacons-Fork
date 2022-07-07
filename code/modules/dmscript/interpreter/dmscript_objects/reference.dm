/datum/dmscript/reference
	var/datum/target
	var/varname
	var/stored_value

/datum/dmscript/reference/proc/put(value)
	message_admins("Value [value] inserted into [target].[varname]")
	if(target)
		target.DmScriptSetVar(value)
	else
		stored_value = value

/datum/dmscript/reference/proc/get()
	if(target)
		return target.DmScriptGetVar()
	else
		return stored_value

