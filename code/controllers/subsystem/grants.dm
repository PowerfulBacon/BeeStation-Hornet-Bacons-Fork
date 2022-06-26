SUBSYSTEM_DEF(grants)
	name = "Grants"
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_GRANTS
	wait = 5 MINUTES

	/// The amount of grants generated at once
	var/max_grants = 3
	/// The currently active grants
	var/list/grants = list()

/datum/controller/subsystem/grants/Initialize(start_timeofday)
	. = ..()
	regenerate_grants()

/datum/controller/subsystem/grants/fire(resumed)
	regenerate_grants()

/datum/controller/subsystem/grants/proc/regenerate_grants()
