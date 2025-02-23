
SUBSYSTEM_DEF(gateway)
	name = "Gateway"
	flags = NONE

/datum/controller/subsystem/gateway/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/gateway/proc/generate_gateway_mission()
	message_admins("Generating gateway mission")
	var/datum/space_level/gateway_level = SSzclear.get_free_z_level()
