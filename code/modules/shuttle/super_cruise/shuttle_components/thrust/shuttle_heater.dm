//-----------------------------------------------
//--------------Engine Heaters-------------------
//This uses atmospherics, much like a thermomachine,
//but instead of changing temp, it stores plasma and uses
//it for the engine.
//-----------------------------------------------
/obj/machinery/atmospherics/components/unary/shuttle
	name = "shuttle atmospherics device"
	desc = "This does something to do with shuttle atmospherics"
	icon_state = "heater"
	icon = 'icons/obj/shuttle.dmi'

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster. Whilst the engine can be overclocked by being flooded with tritium, this will void the warrenty."
	icon_state = "heater_pipe"
	var/icon_state_closed = "heater_pipe"
	var/icon_state_open = "heater_pipe_open"
	var/icon_state_off = "heater_pipe"
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/shuttle/heater

	density = TRUE
	obj_flags = CAN_BE_HIT | BLOCK_Z_IN_DOWN | BLOCK_Z_IN_UP
	max_integrity = 400
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 100, ACID = 30, STAMINA = 0)
	layer = OBJ_LAYER
	showpipe = TRUE

	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	var/efficiency_multiplier = 1
	var/gas_capacity = 0
	var/fuel_state = FALSE

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/New()
	. = ..()
	GLOB.custom_shuttle_machines += src
	SetInitDirections()
	update_adjacent_engines()
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/Destroy()
	GLOB.custom_shuttle_machines -= src
	. = ..()
	update_adjacent_engines()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/process(delta_time)
	if(hasFuel(1))
		if(!fuel_state)
			fuel_state = TRUE
			update_adjacent_engines()
	else if(fuel_state)
		fuel_state = FALSE
		update_adjacent_engines()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/on_construction()
	..(dir, dir)
	SetInitDirections()
	update_adjacent_engines()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		node.disconnect(src)
		nodes[1] = null
	if(!parents[1])
		return
	nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	build_network()
	return TRUE

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/RefreshParts()
	var/cap = 0
	var/eff = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		cap += M.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		eff += L.rating
	gas_capacity = 5000 * ((cap - 1) ** 2) + 1000
	efficiency_multiplier = round(((eff / 2) / 2.8) ** 2, 0.1) * initial(efficiency_multiplier)
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/examine(mob/user)
	. = ..()
	. += "The engine heater's gas dial reads [getFuelAmount()] moles of gas.<br>"

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/updateGasStats()
	var/datum/gas_mixture/air_contents = airs[1]
	if(!air_contents)
		return
	air_contents.set_volume(gas_capacity)
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/hasFuel(var/required)
	return getFuelAmount() >= required

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/consumeFuel(var/amount)
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.remove(amount / efficiency_multiplier)

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/getFuelAmount()
	var/datum/gas_mixture/air_contents = airs[1]
	var/moles = air_contents.get_moles(GAS_PLASMA) + air_contents.get_moles(GAS_TRITIUM)
	return moles

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/get_gas_multiplier()
	//Check the gas ratio
	var/datum/gas_mixture/air_contents = airs[1]
	var/total_moles = air_contents.total_moles()
	if(!total_moles)
		return 0
	var/moles_plasma = air_contents.get_moles(GAS_PLASMA)
	var/moles_tritium = air_contents.get_moles(GAS_TRITIUM)
	return (moles_plasma / total_moles) + (3 * moles_tritium / total_moles)

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/attackby(obj/item/I, mob/living/user, params)
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

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/proc/update_adjacent_engines()
	var/engine_turf
	switch(dir)
		if(NORTH)
			engine_turf = get_offset_target_turf(src, 0, 1)
		if(SOUTH)
			engine_turf = get_offset_target_turf(src, 0, -1)
		if(EAST)
			engine_turf = get_offset_target_turf(src, 1, 0)
		if(WEST)
			engine_turf = get_offset_target_turf(src, -1, 0)
	if(!engine_turf)
		return
	for(var/obj/machinery/shuttle/engine/E in engine_turf)
		E.check_setup()

//=========================
// Ghetto Heater
//=========================

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/ghetto
	name = "ghetto fuel injector"
	desc = "A fuel injector made out of components that you could find in a scrapyard. It requires manual pumping in order to inject the plasma into the engine."
	icon_state = "DIY_heater_pipe"
	icon_state_closed = "DIY_heater_pipe"
	icon_state_open = "DIY_heater_pipe_open"
	icon_state_off = "DIY_heater_pipe"
	idle_power_usage = 50
	efficiency_multiplier = 0.8
	/// How much fuel has been pumped into the engine
	var/injected_fuel = 0
	var/injected_high_fuel = 0
	/// How much fuel gets injected with each pump
	var/injection_amount = 40
	/// How much fuel can we hold in storage maximum
	var/fuel_storage_amount = 400
	/// Are we being pumped?
	var/being_pumped = FALSE

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/ghetto/hasFuel(required)
	return (injected_fuel + injected_high_fuel) >= required

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/ghetto/consumeFuel(amount)
	var/amount_left = amount
	var/injection_amount = min(injected_high_fuel, amount_left)
	injected_high_fuel -= injection_amount
	amount_left -= injection_amount
	if (amount_left > 0)
		injection_amount = min(injected_fuel, amount_left)
		injected_fuel -= injection_amount

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/ghetto/getFuelAmount()
	return injected_fuel + injected_high_fuel

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/ghetto/get_gas_multiplier()
	if (injected_high_fuel > 0)
		return 3
	return 1

/// Injects fuel into the engine.
/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/ghetto/proc/inject_fuel()
	var/datum/gas_mixture/air_contents = airs[1]
	// Oxygen and plasma results in an explosion
	var/oxygen_amount = air_contents.get_moles(GAS_O2)
	var/plasma_amount = air_contents.get_moles(GAS_PLASMA)
	var/tritium_amount = air_contents.get_moles(GAS_TRITIUM)
	if (oxygen_amount > 50)
		var/burned_amount = min(oxygen_amount, max(plasma_amount, tritium_amount))
		explosion(loc, 0, 0, sqrt(burned_amount / 10), sqrt(burned_amount / 5))
		air_contents.adjust_moles(GAS_O2, -burned_amount)
		if (plasma_amount > tritium_amount)
			air_contents.adjust_moles(GAS_PLASMA, -burned_amount)
		else
			air_contents.adjust_moles(GAS_TRITIUM, -burned_amount)
		return
	if (tritium_amount > 5)
		var/injected_amt = min(min(tritium_amount, injection_amount), fuel_storage_amount - injected_fuel - injected_high_fuel)
		injected_high_fuel += injected_amt
		air_contents.adjust_moles(GAS_TRITIUM, -injected_amt)
		return
	var/injected_amt = min(min(plasma_amount, injection_amount), fuel_storage_amount - injected_fuel - injected_high_fuel)
	injected_fuel += injected_amt
	air_contents.adjust_moles(GAS_PLASMA, -injected_amt)

/obj/machinery/atmospherics/components/unary/shuttle/engine_heater/ghetto/attack_hand(mob/living/user)
	if (..())
		return TRUE
	if (!being_pumped)
		return
	playsound(src, 'sound/effects/manual_pump.ogg', 80, FALSE)
	being_pumped = TRUE
	if (!do_after(user, 1 SECONDS, src))
		being_pumped = FALSE
		return
	being_pumped = FALSE
	inject_fuel()
	return TRUE
