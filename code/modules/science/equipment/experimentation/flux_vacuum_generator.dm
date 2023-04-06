/obj/machinery/power/flux_vacuum_generator
	name = "flux vacuum generator"
	desc = "A device used to generate localised flux vacuums, reducing the flux density in an area \
		which may cause some anomalies to exhibit reactions."
	icon_state = "cablerelay"
	obj_flags = CAN_BE_HIT

/obj/machinery/power/flux_vacuum_generator/process(delta_time)

/// Expand the flux vacuum
/obj/machinery/power/flux_vacuum_generator/proc/perform_effect()
	// Compile a list of the turfs we effect
	var/list/edge_turfs = list()
	var/list/affected_turfs = list()
	edge_turfs += get_turf(src)
	affected_turfs[get_turf(src)] = TRUE
	// Affect 1000 turfs max
	while (length(edge_turfs) && length(affected_turfs) < 1000)
		var/turf/current = edge_turfs[length(edge_turfs)]
		edge_turfs.len --
		var/is_dense = FALSE
		for (var/obj/O in current)
			SEND_SIGNAL(O, COMSIG_ANOMALY_FLUX_VACUUM_INTERACTION)
			if (O.density)
				is_dense = TRUE
				break
		if (is_dense)
			continue
		new /obj/effect/temp_visual/emp/pulse(current)
		// Expansion
		if (current.x > 1)
			var/turf/left = locate(current.x - 1, current.y, current.z)
			if (!left.density && !affected_turfs[left])
				affected_turfs[left] = TRUE
				edge_turfs += left
		if (current.x < world.maxx)
			var/turf/right = locate(current.x + 1, current.y, current.z)
			if (!right.density && !affected_turfs[right])
				affected_turfs[right] = TRUE
				edge_turfs += right
		if (current.y > 1)
			var/turf/down = locate(current.x, current.y - 1, current.z)
			if (!down.density && !affected_turfs[down])
				affected_turfs[down] = TRUE
				edge_turfs += down
		if (current.y < world.maxy)
			var/turf/up = locate(current.x, current.y + 1, current.z)
			if (!up.density && !affected_turfs[up])
				affected_turfs[up] = TRUE
				edge_turfs += up
	if (length(edge_turfs))
		// Blow up
		return
