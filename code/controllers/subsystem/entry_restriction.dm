
SUBSYSTEM_DEF(entry_restriction)
	name = "Entry Restriction"
	flags = SS_NO_FIRE | SS_NO_INIT

	var/restriction_enabled = FALSE
	var/list/allowed_ckeys = list()

/datum/controller/subsystem/entry_restriction/proc/join_game(key)
	// Admins automatically pass but aren't in the allowed ckey list
	if (GLOB.admin_datums[ckey(key)])
		return TRUE
	// Check clients for restrictions
	if (restriction_enabled)
		if (!(ckey(key) in allowed_ckeys))
			return FALSE
	allowed_ckeys |= restriction_enabled
	return TRUE

/client/proc/activate_lockdown()
	set name = "Activate Lockdown"
	set category = "Toolbox Games - Server"
