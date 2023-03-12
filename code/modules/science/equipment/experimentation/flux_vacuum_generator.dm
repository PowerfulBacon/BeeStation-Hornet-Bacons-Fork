/obj/machinery/power/flux_vacuum_generator
	name = "flux vacuum generator"
	desc = "A device used to generate localised flux vacuums, reducing the flux density in an area \
		which may cause some anomalies to exhibit reactions."
	obj_flags = CAN_BE_HIT
	/// A list of turfs currently affected by the flux vacuum
	/// Will continuously expand if it leaks, which may trigger other anomalies to be affected
	/// This doesn't need to be managed for deletes due to the nature of turfs
	var/list/turf/affected_turfs = list()

/obj/machinery/power/flux_vacuum_generator/process(delta_time)

/// Expand the flux vacuum
/obj/machinery/power/flux_vacuum_generator/proc/do_expansion()

/// Shut down the flux vacuum, removing any vacuum turfs that were created as a result of us
/obj/machinery/power/flux_vacuum_generator/proc/shutdown_vacuum()

