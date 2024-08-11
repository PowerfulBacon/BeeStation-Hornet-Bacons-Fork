/datum/mixture_populator
	var/datum/gas_mixture/parent
	var/total_capacity = 0

/datum/mixture_populator/New(datum/gas_mixture/parent)
	. = ..()
	src.parent = parent

/datum/mixture_populator/proc/with_gas(gas_id, moles)
	RETURN_TYPE(/datum/mixture_populator)
	parent.set_moles(gas_id, parent.gas_contents[gas_id] + moles)
	total_capacity += GLOB.gas_data.specific_heats[gas_id] * moles
	return src

/// Indicate that the populated gas is at the provided temperature
/// Otherwise, it will be the same temperature that the source gas mixture
/// was at.
/datum/mixture_populator/proc/at_temperature(kelvin)
	RETURN_TYPE(/datum/mixture_populator)
	// How much energy was required to reach this temperature?
	// Make sure we remove the energy that we magically added by not accounting
	// for incoming temperature up to this point
	var/energy = total_capacity * (kelvin - parent.temperature)
	parent.adjust_thermal_energy(energy)
	return src

/datum/mixture_populator/proc/with_energy(energy)
	RETURN_TYPE(/datum/mixture_populator)
	parent.adjust_thermal_energy(energy)
	return src

/datum/mixture_populator/blank/with_gas(gas_id, moles)
	return src

/datum/mixture_populator/blank/at_temperature(kelvin)
	return src

/datum/mixture_populator/blank/with_energy(energy)
	return src
