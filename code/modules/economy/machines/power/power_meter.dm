/obj/machinery/power/power_meter
	icon_state = "power_meter"
	var/power_consumed = 0
	var/datum/powernet/input
	var/datum/powernet/output
	var/datum/department/assigned_department

/obj/machinery/power/power_meter/Initialize(mapload, list/building_parts)
	. = ..()
	if (ispath(assigned_department))
		assigned_department = SSeconomy.get_department(assigned_department)
	GLOB.power_meters += src

/obj/machinery/power/power_meter/Destroy()
	GLOB.power_meters -= src
	. = ..()

/obj/machinery/power/power_meter/process(delta_time)
	if (!output || !input)
		return
	// Offer all of our input's power to the output
	output.newavail += input.avail - input.load
	input.load += output.load
	power_consumed += output.load

/obj/machinery/power/power_meter/proc/update_powernets()
	input = null
	output = null
	var/turf/stepped_turf
	if ((stepped_turf = get_step(src, NORTH)))
		for (var/obj/structure/cable/located_cable in stepped_turf)
			if ((located_cable.d1 & SOUTH) || (located_cable.d2 & SOUTH))
				if (dir == NORTH)
					output = located_cable.powernet
				else
					input = located_cable.powernet
				break
	if ((stepped_turf = get_step(src, SOUTH)))
		for (var/obj/structure/cable/located_cable in stepped_turf)
			if ((located_cable.d1 & NORTH) || (located_cable.d2 & NORTH))
				if (dir == SOUTH)
					output = located_cable.powernet
				else if (input)
					input = merge_powernets(input, located_cable.powernet)
				else
					input = located_cable.powernet
				break
	if ((stepped_turf = get_step(src, EAST)))
		for (var/obj/structure/cable/located_cable in stepped_turf)
			if ((located_cable.d1 & WEST) || (located_cable.d2 & WEST))
				if (dir == EAST)
					output = located_cable.powernet
				else if (input)
					input = merge_powernets(input, located_cable.powernet)
				else
					input = located_cable.powernet
				break
	if ((stepped_turf = get_step(src, WEST)))
		for (var/obj/structure/cable/located_cable in stepped_turf)
			if ((located_cable.d1 & EAST) || (located_cable.d2 & EAST))
				if (dir == WEST)
					output = located_cable.powernet
				else if (input)
					input = merge_powernets(input, located_cable.powernet)
				else
					input = located_cable.powernet
				break
