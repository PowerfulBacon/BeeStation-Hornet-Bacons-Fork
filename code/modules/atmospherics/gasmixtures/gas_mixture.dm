#define CHECK_IMMUTABILITY if (immutable) { return; }

/datum/gas_mixture
	// Gas contents by moles
	var/list/gas_contents = new(GAS_MAX) // moles
	var/temperature = 0 // kelvin
	var/total_moles = 0 // moles
	var/initial_volume = CELL_VOLUME // liters
	var/list/reaction_results
	var/list/analyzer_results //used for analyzer feedback - not initialized until its used
	VAR_PRIVATE/immutable = FALSE

/datum/gas_mixture/New(volume)
	if (!isnull(volume))
		initial_volume = volume
	reaction_results = new

/datum/gas_mixture/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_PARSE_GASSTRING, "Parse Gas String")
	VV_DROPDOWN_OPTION(VV_HK_EMPTY, "Empty")
	VV_DROPDOWN_OPTION(VV_HK_SET_MOLES, "Set Moles")
	VV_DROPDOWN_OPTION(VV_HK_SET_TEMPERATURE, "Set Temperature")
	VV_DROPDOWN_OPTION(VV_HK_SET_VOLUME, "Set Volume")

/datum/gas_mixture/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return
	if(href_list[VV_HK_PARSE_GASSTRING])
		var/gasstring = input(usr, "Input Gas String (WARNING: Advanced. Don't use this unless you know how these work.", "Gas String Parse") as text|null
		if(!istext(gasstring))
			return
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Set to gas string [gasstring].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Set to gas string [gasstring].")
		populate_from_gas_string(gasstring)
	if(href_list[VV_HK_EMPTY])
		log_admin("[key_name(usr)] emptied gas mixture [REF(src)].")
		message_admins("[key_name(usr)] emptied gas mixture [REF(src)].")
		clear()
	if(href_list[VV_HK_SET_MOLES])
		var/gasid = input(usr, "What kind of gas?", "Set Gas") as null|anything in GLOB.gas_data.ids
		if(!gasid)
			return
		var/amount = input(usr, "Input amount", "Set Gas", gas_contents[gasid] || 0) as num|null
		if(!isnum(amount))
			return
		amount = max(0, amount)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Set gas [gasid] to [amount] moles.")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Set gas [gasid] to [amount] moles.")
		set_moles(gasid, amount)
	if(href_list[VV_HK_SET_TEMPERATURE])
		var/temp = input(usr, "Set the temperature of this mixture to?", "Set Temperature", return_temperature()) as num|null
		if(!isnum(temp))
			return
		temp = max(2.7, temp)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Changed temperature to [temp].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Changed temperature to [temp].")
		set_temperature(temp)
	if(href_list[VV_HK_SET_VOLUME])
		var/volume = input(usr, "Set the volume of this mixture to?", "Set Volume", return_volume()) as num|null
		if(!isnum(volume))
			return
		volume = max(0, volume)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Changed volume to [volume].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Changed volume to [volume].")
		set_volume(volume)

/datum/gas_mixture/proc/heat_capacity() //joules per kelvin
	. = 0
	for (var/i in 1 to GAS_MAX)
		. += GLOB.gas_data.specific_heats[i] * gas_contents[i]

/datum/gas_mixture/proc/partial_heat_capacity(gas_type)
	return GLOB.gas_data.specific_heats[gas_type] * gas_contents[gas_type] * temperature

/datum/gas_mixture/proc/total_moles()
	return total_moles

/datum/gas_mixture/proc/return_pressure() //kilopascals
	return (total_moles * R_IDEAL_GAS_EQUATION * temperature) / initial_volume

/datum/gas_mixture/proc/return_temperature() //kelvins
	return temperature

/datum/gas_mixture/proc/set_temperature(new_temp)
	CHECK_IMMUTABILITY
	temperature = new_temp

/datum/gas_mixture/proc/set_volume(new_volume)
	CHECK_IMMUTABILITY
	initial_volume = new_volume

/datum/gas_mixture/proc/get_moles(gas_type)
	return gas_contents[gas_type]

/datum/gas_mixture/proc/set_moles(gas_type, moles)
	CHECK_IMMUTABILITY
	total_moles -= gas_contents[gas_type]
	gas_contents[gas_type] = moles
	total_moles += moles
	gas_content_change()

/datum/gas_mixture/proc/scrub_into(datum/gas_mixture/target, ratio, list/gases)
	for (var/i in gases)
		var/delta = gas_contents[i] * ratio
		target.set_moles(i, target.gas_contents[i] + delta)
		set_moles(i, gas_contents[i] - delta)

/datum/gas_mixture/proc/mark_immutable()
	immutable = TRUE

/datum/gas_mixture/proc/multiply(factor)
	CHECK_IMMUTABILITY
	for (var/i in 1 to GAS_MAX)
		gas_contents[i] *= factor
	total_moles *= factor
	gas_content_change()

/datum/gas_mixture/proc/divide(factor)
	CHECK_IMMUTABILITY
	for (var/i in 1 to GAS_MAX)
		gas_contents[i] /= factor
	total_moles /= factor
	gas_content_change()

/datum/gas_mixture/proc/clear()
	CHECK_IMMUTABILITY
	for (var/i in 1 to GAS_MAX)
		gas_contents[i] = 0
	total_moles = 0
	gas_content_change()

/datum/gas_mixture/proc/adjust_moles(gas_type, amt = 0)
	set_moles(gas_type, clamp(get_moles(gas_type) + amt,0,INFINITY))

/datum/gas_mixture/proc/return_volume() //liters
	return initial_volume

/datum/gas_mixture/proc/thermal_energy() //joules
	. = 0
	for (var/i in 1 to GAS_MAX)
		. += GLOB.gas_data.specific_heats[i] * gas_contents[i] * temperature

//Merges all air from giver into self. Does NOT delete the giver.
//Returns: 1 if we are mutable, 0 otherwise
/datum/gas_mixture/proc/merge(datum/gas_mixture/giver)
	CHECK_IMMUTABILITY
	for (var/i in 1 to GAS_MAX)
		var/transfer_amount = giver.gas_contents[i]
		gas_contents[i] += transfer_amount
		total_moles += transfer_amount
	adjust_thermal_energy(giver.thermal_energy())
	gas_content_change()
	giver.clear()
	return TRUE

//Proportionally removes amount of gas from the gas_mixture
//Returns: gas_mixture with the gases removed
/datum/gas_mixture/proc/remove(amount)
	CHECK_IMMUTABILITY
	var/datum/gas_mixture/removed = new(initial_volume)
	transfer_to(removed, amount)
	return removed

/datum/gas_mixture/proc/transfer_to(datum/gas_mixture/target, amount)
	CHECK_IMMUTABILITY
	var/ratio = CLAMP01(amount / total_moles)
	for (var/i in 1 to GAS_MAX)
		var/delta = gas_contents[i] * ratio
		target.set_moles(i, target.gas_contents[i] + delta)
		set_moles(i, gas_contents[i] - delta)

/// Transfers ratio of gas to target. Equivalent to target.merge(remove_ratio(amount)) but faster.
/datum/gas_mixture/proc/transfer_ratio_to(datum/gas_mixture/target, ratio)
	CHECK_IMMUTABILITY
	for (var/i in 1 to GAS_MAX)
		var/delta = gas_contents[i] * ratio
		target.set_moles(i, target.gas_contents[i] + delta)
		set_moles(i, gas_contents[i] - delta)

//Proportionally removes amount of gas from the gas_mixture
//Returns: gas_mixture with the gases removed
/datum/gas_mixture/proc/remove_ratio(ratio)
	CHECK_IMMUTABILITY
	var/datum/gas_mixture/removed = new(initial_volume)
	transfer_ratio_to(removed, ratio)
	return removed

/// Creates new, identical gas mixture
/// Returns: duplicate gas mixture
/datum/gas_mixture/proc/copy()
	var/datum/gas_mixture/clone = new()
	clone.copy_from(src)
	return clone

/// Copies variables from sample
/datum/gas_mixture/proc/copy_from(datum/gas_mixture/sample)
	CHECK_IMMUTABILITY
	temperature = sample.temperature
	total_moles = sample.total_moles
	initial_volume = sample.initial_volume
	for (var/i in 1 to GAS_MAX)
		gas_contents[i] = sample.gas_contents[i]
	gas_content_change()
	return TRUE

//Copies all gas info from the turf into the gas list along with temperature
//Returns: 1 if we are mutable, 0 otherwise
/datum/gas_mixture/proc/copy_from_turf(turf/model)
	CHECK_IMMUTABILITY

//Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length
//Returns: amount of gas exchanged (+ if sharer received)
/datum/gas_mixture/proc/share(datum/gas_mixture/sharer)
	CHECK_IMMUTABILITY

/// Performs temperature sharing calculations (via conduction) between two gas_mixtures assuming only 1 boundary length
/datum/gas_mixture/proc/temperature_share(datum/gas_mixture/sharer, conduction_coefficient)
	CHECK_IMMUTABILITY
	var/delta = (sharer.temperature - temperature) * conduction_coefficient
	sharer.set_temperature(sharer.temperature - delta)
	set_temperature(temperature + delta)

//Performs various reactions such as combustion or fusion (LOL)
//Returns: 1 if any reaction took place; 0 otherwise
/datum/gas_mixture/proc/react(turf/open/dump_location)
	CHECK_IMMUTABILITY

//Adjusts the thermal energy of the gas mixture
/datum/gas_mixture/proc/adjust_thermal_energy(joules)
	CHECK_IMMUTABILITY
	// How much thermal energy do we have?
	var/joules_per_kelvin = 0
	for (var/i in 1 to GAS_MAX)
		joules_per_kelvin += GLOB.gas_data.specific_heats[i] * gas_contents[i]
	if (!joules_per_kelvin)
		return
	// Good enough for me
	temperature += joules / joules_per_kelvin

//Gets how much oxidation this gas can do, optionally at a given temperature.
/datum/gas_mixture/proc/get_oxidation_power(temp)

//Gets how much fuel for fires (not counting trit/plasma!) this gas has, optionally at a given temperature.
/datum/gas_mixture/proc/get_fuel_amount(temp)

/// Makes every gas mixture in the given list have the same pressure, temperature and gas proportions.
/proc/equalize_all_gases_in_list(list/L, visual_only = FALSE)
	if (!length(L))
		return
	var/datum/gas_mixture/master = L[1]
	var/total_thermal_energy = master.thermal_energy()
	var/total_volume = master.initial_volume
	// Place all gas into the master
	for (var/i in 2 to length(L))
		var/datum/gas_mixture/slave = L[i]
		for (var/j in 1 to GAS_MAX)
			master.gas_contents[j] += slave.gas_contents[j]
			master.total_moles += slave.total_moles
		total_thermal_energy += slave.thermal_energy()
		total_volume += slave.initial_volume
	if (!total_volume)
		CRASH("Attempting to equalise gas mixtures with no volume, this is a bug")
	// Distribute gasses
	for (var/i in 2 to length(L))
		var/datum/gas_mixture/slave = L[i]
		slave.temperature = 0
		slave.total_moles = 0
		var/proportion = slave.initial_volume / total_volume
		for (var/j in 1 to GAS_MAX)
			var/distributed_gas = master.gas_contents[j] * proportion
			slave.gas_contents[j] = distributed_gas
			slave.total_moles += distributed_gas
		slave.adjust_thermal_energy(total_thermal_energy * proportion)
		slave.gas_content_change(visual_only)
	var/final_proportion = master.initial_volume / total_volume
	master.temperature = 0
	master.total_moles = 0
	for (var/i in 1 to GAS_MAX)
		var/distributed_gas = master.gas_contents[i] * final_proportion
		master.gas_contents[i] = distributed_gas
		master.total_moles += distributed_gas
	master.adjust_thermal_energy(total_thermal_energy * final_proportion)
	master.gas_content_change(visual_only)

/datum/gas_mixture/remove(amount)
	CHECK_IMMUTABILITY
	var/ratio = CLAMP01(amount / total_moles)
	return remove_ratio(ratio)

/datum/gas_mixture/remove_ratio(ratio)
	CHECK_IMMUTABILITY
	var/datum/gas_mixture/removed = new type
	for (var/i in 1 to GAS_MAX)
		var/removed_amount = gas_contents[i] * ratio
		gas_contents[i] -= removed_amount
		total_moles -= removed_amount
		removed.gas_contents[i] += removed_amount
		removed.total_moles += removed_amount
	gas_content_change()
	return removed

/datum/gas_mixture/copy()
	var/datum/gas_mixture/copy = new type
	copy.copy_from(src)
	return copy

//Mathematical proofs:
/*
get_breath_partial_pressure(gas_pp) --> gas_pp/total_moles()*breath_pp = pp
get_true_breath_pressure(pp) --> gas_pp = pp/breath_pp*total_moles()

10/20*5 = 2.5
10 = 2.5/5*20
*/

/// Releases gas from src to output air. This means that it can not transfer air to gas mixture with higher pressure.
/datum/gas_mixture/proc/release_gas_to(datum/gas_mixture/output_air, target_pressure)
	var/output_starting_pressure = output_air.return_pressure()
	var/input_starting_pressure = return_pressure()

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 kPa difference to overcome friction in the mechanism
		return FALSE

	//Calculate necessary moles to transfer using PV = nRT
	if((total_moles() > 0) && (return_temperature()>0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = pressure_delta*output_air.return_volume()/(return_temperature() * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = remove(transfer_moles)
		output_air.merge(removed)
		return TRUE
	return FALSE

/datum/gas_mixture/proc/vv_react(datum/holder)
	return react(holder)

/datum/gas_mixture/proc/gas_content_change(visual_only = FALSE)
	return

// Instead of atmos_spawn_air, this can be used to populate a mixture
// from code
/datum/gas_mixture/proc/create_populator()
	RETURN_TYPE(/datum/mixture_populator)
	return new /datum/mixture_populator(src)
