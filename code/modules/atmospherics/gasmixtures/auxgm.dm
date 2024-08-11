GLOBAL_LIST_INIT(nonreactive_gases, typecacheof(list(GAS_O2, GAS_N2, GAS_CO2, GAS_PLUOXIUM, GAS_STIMULUM, GAS_NITRYL))) //unable to react amongst themselves

// Auxgm
// It's a send-up of XGM, like what baystation got.
// It's got the same architecture as XGM, but it's structured
// differently to make it more convenient for auxmos.

// Most important compared to TG is that it does away with hardcoded typepaths,
// which lead to problems on the auxmos end anyway. We cache the string value
// references on the Rust end, so no performance is lost here.

// Also allows you to add new gases at runtime

/datum/auxgm
	var/list/datums = new(GAS_MAX)
	var/list/specific_heats = new(GAS_MAX)
	var/list/names = new(GAS_MAX)
	var/list/visibility = new(GAS_MAX)
	var/list/overlays = new(GAS_MAX)
	var/list/flags = new(GAS_MAX)
	var/list/ids = new(GAS_MAX)
	var/list/typepaths = new(GAS_MAX)
	var/list/fusion_powers = new(GAS_MAX)
	var/list/breathing_classes = new(GAS_MAX)
	var/list/breath_results = new(GAS_MAX)
	var/list/breath_reagents = new(GAS_MAX)
	var/list/breath_reagents_dangerous = new(GAS_MAX)
	var/list/breath_alert_info = new(GAS_MAX)
	var/list/oxidation_temperatures = new(GAS_MAX)
	var/list/oxidation_rates = new(GAS_MAX)
	var/list/fire_temperatures = new(GAS_MAX)
	var/list/enthalpies = new(GAS_MAX)
	var/list/fire_products = new(GAS_MAX)
	var/list/fire_burn_rates = new(GAS_MAX)


/datum/gas
	var/id = ""
	var/specific_heat = 0 // joules per moles per kelvin
	var/name = ""
	var/gas_overlay = "" //icon_state in icons/effects/atmospherics.dmi
	var/moles_visible = null
	var/flags = NONE //currently used by canisters
	var/fusion_power = 0 // How much the gas destabilizes a fusion reaction
	var/breath_results = GAS_CO2 // what breathing this breathes out
	var/breath_reagent = null // what breathing this adds to your reagents
	var/breath_reagent_dangerous = null // what breathing this adds to your reagents IF it's above a danger threshold
	var/list/breath_alert_info = null // list for alerts that pop up when you have too much/not enough of something
	var/oxidation_temperature = null // temperature above which this gas is an oxidizer; null for none
	var/oxidation_rate = 1 // how many moles of this can oxidize how many moles of material
	var/fire_temperature = null // temperature above which gas may catch fire; null for none
	var/list/fire_products = null // what results when this gas is burned (oxidizer or fuel); null for none
	var/enthalpy = 0 // how much energy is released per mole of fuel burned
	var/fire_burn_rate = 1 // how many moles are burned per product released

/datum/gas/proc/breath(partial_pressure, light_threshold, heavy_threshold, moles, mob/living/carbon/C, obj/item/organ/lungs/lungs)
	// This is only called on gases with the GAS_FLAG_BREATH_PROC flag. When possible, do NOT use this--
	// greatly prefer just adding a reagent. This is mostly around for legacy reasons.
	return null

/datum/auxgm/proc/add_gas(datum/gas/gas)
	var/g = gas.id
	if(g)
		datums[g] = gas
		specific_heats[g] = gas.specific_heat
		names[g] = gas.name
		if(gas.moles_visible)
			visibility[g] = gas.moles_visible
			overlays[g] = gas.gas_overlay
		else
			visibility[g] = 0
			overlays[g] = null
		flags[g] = gas.flags
		ids[g] = g
		typepaths[g] = gas.type
		fusion_powers[g] = gas.fusion_power

		if(gas.breath_alert_info)
			breath_alert_info[g] = gas.breath_alert_info
		breath_results[g] = gas.breath_results
		if(gas.breath_reagent)
			breath_reagents[g] = gas.breath_reagent
		if(gas.breath_reagent_dangerous)
			breath_reagents_dangerous[g] = gas.breath_reagent_dangerous

		if(gas.oxidation_temperature)
			oxidation_temperatures[g] = gas.oxidation_temperature
			oxidation_rates[g] = gas.oxidation_rate
			if(gas.fire_products)
				fire_products[g] = gas.fire_products
			enthalpies[g] = gas.enthalpy
		else if(gas.fire_temperature)
			fire_temperatures[g] = gas.fire_temperature
			fire_burn_rates[g] = gas.fire_burn_rate
			if(gas.fire_products)
				fire_products[g] = gas.fire_products
			enthalpies[g] = gas.enthalpy

/proc/finalize_gas_refs()

/datum/auxgm/New()
	for(var/gas_path in subtypesof(/datum/gas))
		var/datum/gas/gas = new gas_path
		add_gas(gas)
	for(var/breathing_class_path in subtypesof(/datum/breathing_class))
		var/datum/breathing_class/class = new breathing_class_path
		breathing_classes[breathing_class_path] = class
	finalize_gas_refs()

GLOBAL_DATUM_INIT(gas_data, /datum/auxgm, new)

/obj/effect/overlay/gas
	icon = 'icons/effects/atmospherics.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	appearance_flags = TILE_BOUND
	vis_flags = NONE

/obj/effect/overlay/gas/New(state)
	. = ..()
	icon_state = state
