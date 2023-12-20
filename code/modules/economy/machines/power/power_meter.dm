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
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/power_meter/LateInitialize()
	. = ..()
	update_powernets()

/obj/machinery/power/power_meter/process(delta_time)
	if (!output || !input)
		return
	// Offer all of our input's power to the output
	output.newavail += input.avail - input.load
	input.load += output.load
	power_consumed += output.load
	assigned_department.pay(SSeconomy.get_department(/datum/department/engineering), "energy bill", output.load, "Energy bill payment for the consumption of [display_power(output.load)]")

/obj/machinery/power/power_meter/proc/update_powernets()
	input = null
	output = null
	var/list/input_powernets = list()
	var/turf/stepped_turf
	var/obj/structure/cable/located_cable
	if ((stepped_turf = get_step(src, NORTH)) && (located_cable = locate() in stepped_turf) && ((located_cable.d1 & SOUTH) || (located_cable.d2 & SOUTH)))
		if (dir == NORTH)
			output = located_cable.powernet
		else
			input = located_cable.powernet
	if ((stepped_turf = get_step(src, SOUTH)) && (located_cable = locate() in stepped_turf) && ((located_cable.d1 & NORTH) || (located_cable.d2 & NORTH)))
		if (dir == SOUTH)
			output = located_cable.powernet
		else if (input)
			input = merge_powernets(input, located_cable.powernet)
		else
			input = located_cable.powernet
	if ((stepped_turf = get_step(src, EAST)) && (located_cable = locate() in stepped_turf) && ((located_cable.d1 & WEST) || (located_cable.d2 & WEST)))
		if (dir == EAST)
			output = located_cable.powernet
		else if (input)
			input = merge_powernets(input, located_cable.powernet)
		else
			input = located_cable.powernet
	if ((stepped_turf = get_step(src, WEST)) && (located_cable = locate() in stepped_turf) && ((located_cable.d1 & EAST) || (located_cable.d2 & EAST)))
		if (dir == WEST)
			output = located_cable.powernet
		else if (input)
			input = merge_powernets(input, located_cable.powernet)
		else
			input = located_cable.powernet
