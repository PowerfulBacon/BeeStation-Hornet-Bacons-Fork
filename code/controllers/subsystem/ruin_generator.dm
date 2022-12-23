SUBSYSTEM_DEF(ruin_generator)
	name = "Ruin Generator"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RUIN_GENERATOR
	var/datum/map_generator/space_ruin/unused_ruin

/datum/controller/subsystem/ruin_generator/Initialize(start_timeofday)
	. = ..()
	//Generate the initial ruin
	generate_ruin()

/datum/controller/subsystem/ruin_generator/proc/get_ruin()
	. = unused_ruin
	//We no longer need to keep that ruin around
	SSzclear.unkeep_z(unused_ruin.center_z)
	unused_ruin = null
	generate_ruin()

/datum/controller/subsystem/ruin_generator/proc/generate_ruin()
	var/datum/space_level/target_level = SSzclear.get_free_z_level()
	unused_ruin = generate_space_ruin(world.maxx / 2, world.maxy / 2, target_level.z_value, 100, 100, null)
	SSzclear.keep_z(target_level.z_value)
