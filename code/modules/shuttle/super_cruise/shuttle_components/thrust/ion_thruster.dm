
/obj/machinery/shuttle/engine/ion
	name = "ion thruster"
	desc = "A thruster that expells ions in order to generate thrust. Weak, but easy to maintain."
	icon_state = "ion_thruster"
	icon_state_open = "ion_thruster_open"
	icon_state_off = "ion_thruster_off"

	idle_power_usage = 0
	circuit = /obj/item/circuitboard/machine/shuttle/engine/plasma
	thrust = 15
	fuel_use = 0
	bluespace_capable = FALSE
	cooldown = 45
	var/usage_rate = 15
	var/obj/machinery/power/thruster_capacitor_bank/capacitor_bank

/obj/machinery/shuttle/engine/ion/consume_fuel(amount)
	if(!capacitor_bank)
		return
	capacitor_bank.stored_power = max(capacitor_bank.stored_power - usage_rate, 0)

/obj/machinery/shuttle/engine/ion/update_engine()
	if(panel_open)
		set_active(FALSE)
		icon_state = icon_state_open
		return
	if(!needs_heater)
		icon_state = icon_state_closed
		set_active(TRUE)
		return
	if(capacitor_bank?.stored_power)
		icon_state = icon_state_closed
		set_active(TRUE)
	else
		set_active(FALSE)
		icon_state = icon_state_off

/obj/machinery/shuttle/engine/ion/check_setup()
	var/heater_turf
	switch(dir)
		if(NORTH)
			heater_turf = get_offset_target_turf(src, 0, 1)
		if(SOUTH)
			heater_turf = get_offset_target_turf(src, 0, -1)
		if(EAST)
			heater_turf = get_offset_target_turf(src, 1, 0)
		if(WEST)
			heater_turf = get_offset_target_turf(src, -1, 0)
	if(!heater_turf)
		capacitor_bank = null
		update_engine()
		return
	register_capacitor_bank(null)
	var/obj/machinery/power/thruster_capacitor_bank/as_heater = locate() in heater_turf
	if(!as_heater)
		return
	if(as_heater.dir != dir)
		return
	if(as_heater.panel_open)
		return
	if(!as_heater.anchored)
		return
	register_capacitor_bank(as_heater)
	. = ..()

/obj/machinery/shuttle/engine/ion/proc/register_capacitor_bank(new_bank)
	if(capacitor_bank)
		UnregisterSignal(capacitor_bank, COMSIG_PARENT_QDELETING)
	capacitor_bank = new_bank
	if(capacitor_bank)
		RegisterSignal(capacitor_bank, COMSIG_PARENT_QDELETING, .proc/on_capacitor_deleted)
	update_engine()

/obj/machinery/shuttle/engine/ion/proc/on_capacitor_deleted(datum/source, force)
	register_capacitor_bank(null)

//=============================
// Capacitor Bank
//=============================

/obj/machinery/power/thruster_capacitor_bank
	name = "thruster capacitor bank"
	desc = "A capacitor bank that stores power for high-energy ion thrusters."
	icon_state = "heater_pipe"
	icon = 'icons/turf/shuttle.dmi'
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/shuttle/capacitor_bank
	var/icon_state_closed = "heater_pipe"
	var/icon_state_open = "heater_pipe_open"
	var/icon_state_off = "heater_pipe"
	var/stored_power = 0
	var/charge_rate = 50
	var/maximum_stored_power = 500

/obj/machinery/power/thruster_capacitor_bank/Initialize(mapload)
	. = ..()
	GLOB.custom_shuttle_machines += src
	update_adjacent_engines()

/obj/machinery/power/thruster_capacitor_bank/Destroy()
	GLOB.custom_shuttle_machines -= src
	. = ..()
	update_adjacent_engines()

/obj/machinery/power/thruster_capacitor_bank/RefreshParts()
	maximum_stored_power = 0
	charge_rate = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		maximum_stored_power += C.rating * 200
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		charge_rate += L.rating * 50
	stored_power = min(stored_power, maximum_stored_power)

/obj/machinery/power/thruster_capacitor_bank/examine(mob/user)
	. = ..()
	. += "The capacitor bank reads [stored_power]W of power stored.<br>"

/obj/machinery/power/thruster_capacitor_bank/process(delta_time)
	take_power()

/obj/machinery/power/thruster_capacitor_bank/proc/take_power()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(!C)
		return
	var/datum/powernet/powernet = C.powernet
	if(!powernet)
		return
	//Consume power
	var/surplus = max(powernet.avail - powernet.load, 0)
	var/available_power = min(charge_rate, surplus, maximum_stored_power - stored_power)
	if(available_power)
		powernet.load += available_power
		stored_power += available_power

//Annoying copy and paste because atmos machines aren't a component so engine heaters
//can't share from the same supertype
/obj/machinery/power/thruster_capacitor_bank/proc/update_adjacent_engines()
	var/engine_turf
	switch(dir)
		if(NORTH)
			engine_turf = get_offset_target_turf(src, 0, -1)
		if(SOUTH)
			engine_turf = get_offset_target_turf(src, 0, 1)
		if(EAST)
			engine_turf = get_offset_target_turf(src, -1, 0)
		if(WEST)
			engine_turf = get_offset_target_turf(src, 1, 0)
	if(!engine_turf)
		return
	for(var/obj/machinery/shuttle/engine/E in engine_turf)
		E.check_setup()

/obj/machinery/power/thruster_capacitor_bank/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		update_adjacent_engines()
		return
	if(default_pry_open(I))
		update_adjacent_engines()
		return
	if(panel_open)
		if(default_change_direction_wrench(user, I))
			update_adjacent_engines()
			return
	if(default_deconstruction_crowbar(I))
		update_adjacent_engines()
		return
	update_adjacent_engines()
	return ..()

//=============================
// Burst Thruster (For shuttles)
//=============================

/obj/machinery/shuttle/engine/ion/burst
	name = "burst ion thruster"
	desc = "A varient of the ion thruster that uses significantly more power for a burst of thrust."

	circuit = /obj/item/circuitboard/machine/shuttle/engine/plasma
	//Must faster
	thrust = 75
	//Uses more than it can be charged with a basic capacitor, so cannot sustain long periods of flight
	usage_rate = 70
