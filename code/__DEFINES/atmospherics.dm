// ===========================
// Atmos Flow Flags
// ===========================

/// Atmos will be allowed to pass if no other flags are set
#define ATMOS_PASS 0
/// Atmos will be blocked by this atom.
/// By default, when we allow atoms to pass through us, we will create an atmos bridge
/// which will equalise the pressures between areas
#define ATMOS_DENSE (1 << 0)
/// If set, atmos will not flow through this atom ever, and bridges
/// will not be created when we are not dense
#define ATMOS_ALWAYS_DENSE ((1 << 0) | (1 << 1))
#define ATMOS_ALWAYS_DENSE_FLAG (1 << 1)
/// If set, while dense, atmos will only be blocked in the direction of the object
#define ATMOS_DENSE_DIRECTIONAL ((1 << 0) | (1 << 2))
#define ATMOS_DENSE_DIRECTIONAL_FLAG (1 << 2)

// ===========================
// Atmos Flow Updaters
// ===========================

#define UPDATE_TURF_ATMOS_FLOW(turf) SSair.set_atmos_flow_directions(turf.x, turf.y, turf.z, \
	(turf.atmos_flow_directions = (ALL \
	/* Disable all flags if there are fully dense objects here */ \
	& (turf.atmos_dense_objects ? NONE : ALL) \
	/* Disable directional flags based on directionally blocking objects */ \
	& (turf.atmos_dense_north_objects ? (~NORTH) : ALL) \
	& (turf.atmos_dense_east_objects ? (~EAST) : ALL) \
	& (turf.atmos_dense_south_objects ? (~SOUTH) : ALL) \
	& (turf.atmos_dense_west_objects ? (~WEST) : ALL) \
	/* Update for our own blocking status (turfs cannot directionally block atmos) */ \
	& ((turf.atmos_density && (turf.density || turf.atmos_density & ATMOS_ALWAYS_DENSE_FLAG)) ? NONE : ALL) \
	)))

// ===========================
//ATMOS
// ===========================

//stuff you should probably leave well alone!
/// kPa*L/(K*mol)
#define R_IDEAL_GAS_EQUATION 8.31
/// kPa
#define ONE_ATMOSPHERE 101.325
/// -270.3degC
#define TCMB 2.7
/// -48.15degC
#define TCRYO 225
/// 0degC
#define T0C 273.15
/// 20degC
#define T20C 293.15
/// -14C - Temperature used for kitchen cold room, medical freezer, etc.
#define COLD_ROOM_TEMP 259.15

///moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC (103 or so)
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))
///compared against for superconductivity
#define M_CELL_WITH_RATIO (MOLES_CELLSTANDARD * 0.005)
/// percentage of oxygen in a normal mixture of air
#define O2STANDARD 0.21
/// same but for nitrogen
#define N2STANDARD 0.79
/// O2 standard value (21%)
#define MOLES_O2STANDARD (MOLES_CELLSTANDARD*O2STANDARD)
/// N2 standard value (79%)
#define MOLES_N2STANDARD (MOLES_CELLSTANDARD*N2STANDARD)
/// liters in a cell
#define CELL_VOLUME 2500

#define BREATH_VOLUME			0.5		//! liters in a normal breath
#define BREATH_PERCENTAGE		(BREATH_VOLUME/CELL_VOLUME)					//! Amount of air to take a from a tile

//EXCITED GROUPS
#define EXCITED_GROUP_BREAKDOWN_CYCLES				3		//! number of FULL air controller ticks before an excited group breaks down (averages gas contents across turfs)
#define EXCITED_GROUP_DISMANTLE_CYCLES				15		//! number of FULL air controller ticks before an excited group dismantles and removes its turfs from active
#define MINIMUM_AIR_RATIO_TO_SUSPEND				0.1		//! Ratio of air that must move to/from a tile to reset group processing
#define MINIMUM_AIR_RATIO_TO_MOVE					0.05	//! Minimum ratio of air that must move to/from a tile
#define MINIMUM_AIR_TO_SUSPEND						(MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND)	//! Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_MOLES_DELTA_TO_MOVE					(MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_MOVE) //! Either this must be active or MINIMUM_TEMPERATURE_TO_MOVE
#define MINIMUM_TEMPERATURE_TO_MOVE					(T20C+100)			//! Either this must be active or MINIMUM_MOLES_DELTA_TO_MOVE
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND		4		//! Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER		1		//! Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		(T20C+10)
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	(T20C+200)

//HEAT TRANSFER COEFFICIENTS
//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Should not exceed 0.4 else strange heat flow occur
#define WALL_HEAT_TRANSFER_COEFFICIENT		0.0
#define OPEN_HEAT_TRANSFER_COEFFICIENT		0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT	0.1		//a hack for now
#define HEAT_CAPACITY_VACUUM				7000	//a hack to help make vacuums "cold", sacrificing realism for gameplay

//FIRE
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	(150+T0C)
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	(100+T0C)
#define FIRE_SPREAD_RADIOSITY_SCALE			0.85
#define FIRE_GROWTH_RATE					40000	//For small fires
#define PLASMA_MINIMUM_BURN_TEMPERATURE		(100+T0C)
#define PLASMA_UPPER_TEMPERATURE			(1370+T0C)
#define PLASMA_OXYGEN_FULLBURN				10

//GASES
#define MIN_TOXIC_GAS_DAMAGE				1
#define MAX_TOXIC_GAS_DAMAGE				10
#define MOLES_GAS_VISIBLE					0.25 //! Moles in a standard cell after which gases are visible

#define FACTOR_GAS_VISIBLE_MAX				20 //! moles_visible * FACTOR_GAS_VISIBLE_MAX = Moles after which gas is at maximum visibility
#define MOLES_GAS_VISIBLE_STEP				0.25 //! Mole step for alpha updates. This means alpha can update at 0.25, 0.5, 0.75 and so on

//REACTIONS
//return values for reactions (bitflags)
#define NO_REACTION		0
#define REACTING		1
#define STOP_REACTIONS 	2

// Pressure limits.
/// This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define HAZARD_HIGH_PRESSURE 550
/// This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_HIGH_PRESSURE 325
/// This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define WARNING_LOW_PRESSURE 50
/// This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)
#define HAZARD_LOW_PRESSURE 20

/// This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define TEMPERATURE_DAMAGE_COEFFICIENT 1.5

/// The natural temperature for a body
#define BODYTEMP_NORMAL 310.15
/// This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_DIVISOR 14
/// Minimum amount of kelvin moved toward 310K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_AUTORECOVERY_MINIMUM 6
///Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_COLD_DIVISOR 15
/// Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR 15
/// The maximum number of degrees that your body can cool in 1 tick, due to the environment, when in a cold area.
#define BODYTEMP_COOLING_MAX -30
/// The maximum number of degrees that your body can heat up in 1 tick, due to the environment, when in a hot area.
#define BODYTEMP_HEATING_MAX 30

/// The body temperature limit the human body can take before it starts taking damage from heat.
/// This also affects how fast the body normalises it's temperature when hot.
/// 340k is about 66c, and rather high for a human.
#define BODYTEMP_HEAT_DAMAGE_LIMIT (BODYTEMP_NORMAL + 30)
/// The body temperature limit the human body can take before it starts taking damage from cold.
/// This also affects how fast the body normalises it's temperature when cold.
/// 270k is about -3c, that is below freezing and would hurt over time.
#define BODYTEMP_COLD_DAMAGE_LIMIT (BODYTEMP_NORMAL - 40)
/// The body temperature limit the human body can take before it will take wound damage.
#define BODYTEMP_HEAT_WOUND_LIMIT (BODYTEMP_NORMAL + 90) // 400.5 k

// Body temperature warning icons
/// The temperature the red icon is displayed.
#define BODYTEMP_HEAT_WARNING_3 (BODYTEMP_HEAT_DAMAGE_LIMIT + 360) //+700k
/// The temperature the orange icon is displayed.
#define BODYTEMP_HEAT_WARNING_2 (BODYTEMP_HEAT_DAMAGE_LIMIT + 120) //460K
/// The temperature the yellow icon is displayed.
#define BODYTEMP_HEAT_WARNING_1 (BODYTEMP_HEAT_DAMAGE_LIMIT) //340K
/// The temperature the light green icon is displayed.
#define BODYTEMP_COLD_WARNING_1 (BODYTEMP_COLD_DAMAGE_LIMIT) //270k
/// The temperature the cyan icon is displayed.
#define BODYTEMP_COLD_WARNING_2 (BODYTEMP_COLD_DAMAGE_LIMIT - 70) //200k
/// The temperature the blue icon is displayed.
#define BODYTEMP_COLD_WARNING_3 (BODYTEMP_COLD_DAMAGE_LIMIT - 150) //120k

/// what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_HELM_MIN_TEMP_PROTECT 2.0
/// Thermal insulation works both ways /Malkevin
#define SPACE_HELM_MAX_TEMP_PROTECT 1500
/// what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MIN_TEMP_PROTECT 2.0
/// The min cold protection of a space suit without the heater active
#define SPACE_SUIT_MIN_TEMP_PROTECT_OFF 72
#define SPACE_SUIT_MAX_TEMP_PROTECT 1500

#define FIRE_SUIT_MIN_TEMP_PROTECT			60		//! Cold protection for firesuits
#define FIRE_SUIT_MAX_TEMP_PROTECT			30000	//! what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_HELM_MIN_TEMP_PROTECT			60		//! Cold protection for fire helmets
#define FIRE_HELM_MAX_TEMP_PROTECT			30000	//! for fire helmet quality items (red and white hardhats)

#define FIRE_IMMUNITY_MAX_TEMP_PROTECT	35000		//! what max_heat_protection_temperature is set to for firesuit quality suits and helmets. MUST NOT BE 0.

//Emergency skinsuits
#define EMERGENCY_HELM_MIN_TEMP_PROTECT		2.0		//The helmet is pressurized with air from the oxygen tank. If they don't take damage from that they won't take damage here
#define EMERGENCY_SUIT_MIN_TEMP_PROTECT		237		//This is the approximate average temperature of Mt. Everest in the winter

#define HELMET_MIN_TEMP_PROTECT				160		//For normal helmets
#define HELMET_MAX_TEMP_PROTECT				600		//For normal helmets
#define ARMOR_MIN_TEMP_PROTECT				160		//For armor
#define ARMOR_MAX_TEMP_PROTECT				600		//For armor

#define GLOVES_MIN_TEMP_PROTECT				2.0		//For some gloves (black and)
#define GLOVES_MAX_TEMP_PROTECT				1500	//For some gloves
#define SHOES_MIN_TEMP_PROTECT				2.0		//For gloves
#define SHOES_MAX_TEMP_PROTECT				1500	//For gloves

#define PRESSURE_DAMAGE_COEFFICIENT			4		//! The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE			4
#define LOW_PRESSURE_DAMAGE					4		//! The amount of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define COLD_SLOWDOWN_FACTOR				20		//! Humans are slowed by the difference between bodytemp and BODYTEMP_COLD_DAMAGE_LIMIT divided by this

//PIPES
//Atmos pipe limits
/// (kPa) What pressure pumps and powered equipment max out at.
#define MAX_OUTPUT_PRESSURE					4500
/// (L/s) Maximum speed powered equipment can work at.
#define MAX_TRANSFER_RATE 200
/// How many percent of the contents that an overclocked volume pumps leak into the air
#define VOLUME_PUMP_LEAK_AMOUNT 0.1

//used for device_type vars
#define UNARY		1
#define BINARY 		2
#define TRINARY		3
#define QUATERNARY	4

//TANKS
#define TANK_MELT_TEMPERATURE				1000000	//! temperature in kelvins at which a tank will start to melt
#define TANK_LEAK_PRESSURE					(30.*ONE_ATMOSPHERE)	//! temperature in kelvins at which a tank starts leaking
#define TANK_RUPTURE_PRESSURE				(35.*ONE_ATMOSPHERE)	//! temperature in kelvins at which a tank spills all contents into atmosphere
#define TANK_FRAGMENT_PRESSURE				(40.*ONE_ATMOSPHERE)	//! temperature in kelvins at which a tank creates a boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    			(6.*ONE_ATMOSPHERE)		//! +1 for each SCALE kPa aboe threshold
#define TANK_MAX_RELEASE_PRESSURE 			(ONE_ATMOSPHERE*3)
#define TANK_MIN_RELEASE_PRESSURE 			0
#define TANK_DEFAULT_RELEASE_PRESSURE 		17

// Atmos can pass when:
// - Always can pass if the 2 tiles are not atmos dense
// - Can never pass if either tile is always dense and if the direction flag is set, the direction matches
// - Can always pass if both tiles have density of 0
// - Can not pass if 1 of the tiles has density and if the direction flag is set, the direction matches
// - Can pass otherwise
#define CANATMOSPASS(source, target) ( \
	/* Check atmos density in the correct flow directions */ \
	(!ISATMOSDENSE(source, get_dir(source, target)) && !ISATMOSDENSE(target, get_dir(target, source))) \
	)
/// Check if a turf is atmos dense
#define ISATMOSDENSE(turf, check_direction) ( \
	/* Turf self-check */ \
	(\
		/* Turf must have atmos density set to something */ \
		turf.atmos_density \
		/* Turf needs to be either dense or always dense */ \
		&& (turf.density || (turf.atmos_density & ATMOS_ALWAYS_DENSE_FLAG)) \
	)\
	/* Check valid flow directions from contents */ \
	|| !(check_direction & turf.atmos_flow_directions) \
	)
// Temp
#define CANVERTICALATMOSPASS(A, O) ( FALSE )

#define SET_TURF_ATMOS_DENSE atmos_flow_directions = NONE;\
	atmos_density = ATMOS_ALWAYS_DENSE;

// ============================
// Default Atmos Mixes
// ============================

/// the default air mix that open turfs spawn
#define APPLY_OPENTURF_DEFAULT_ATMOS(target) ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial) {\
	var/final_thermal_energy = target_mixture.thermal_energy()\
		+ GLOB.gas_data.specific_heats[GAS_O2] * MOLES_O2STANDARD * T20C\
		+ GLOB.gas_data.specific_heats[GAS_N2] * MOLES_N2STANDARD * T20C;\
	target_mixture.gas_contents[GAS_O2] += MOLES_O2STANDARD;\
	target_mixture.gas_contents[GAS_N2] += MOLES_N2STANDARD;\
	target_mixture.total_moles += MOLES_O2STANDARD + MOLES_N2STANDARD;\
	target_mixture.temperature = 0;\
	target_mixture.adjust_thermal_energy(final_thermal_energy);\
	if (!initial) {\
		target_mixture.gas_content_change();\
	}\
}
// Lower pressure default mix
#define APPLY_OPENTURF_LOW_PRESSURE(target) ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial) {\
	var/final_thermal_energy = target_mixture.thermal_energy()\
		+ GLOB.gas_data.specific_heats[GAS_O2] * 0.14 * MOLES_CELLSTANDARD * T20C\
		+ GLOB.gas_data.specific_heats[GAS_N2] * 0.3 * MOLES_CELLSTANDARD * T20C;\
	target_mixture.gas_contents[GAS_O2] += 0.14 * MOLES_CELLSTANDARD;\
	target_mixture.gas_contents[GAS_N2] += 0.3 * MOLES_CELLSTANDARD;\
	target_mixture.total_moles += 0.14 * MOLES_CELLSTANDARD + 0.3 * MOLES_CELLSTANDARD;\
	target_mixture.temperature = 0;\
	target_mixture.adjust_thermal_energy(final_thermal_energy);\
	if (!initial) {\
		target_mixture.gas_content_change();\
	}\
} ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial)
// Telecommunications atmos mix
#define APPLY_TCOMMS_ATMOS(target) ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial) {\
	var/final_thermal_energy = target_mixture.thermal_energy()\
		+ GLOB.gas_data.specific_heats[GAS_N2] * MOLES_CELLSTANDARD * 80;\
	target_mixture.gas_contents[GAS_N2] += MOLES_CELLSTANDARD;\
	target_mixture.total_moles += 0 + MOLES_CELLSTANDARD;\
	target_mixture.temperature = 0;\
	target_mixture.adjust_thermal_energy(final_thermal_energy);\
	if (!initial) {\
		target_mixture.gas_content_change();\
	}\
} ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial)
// Space mix
#define APPLY_AIRLESS_ATMOS(target) ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial) {\
	target_mixture.temperature = max(2.7, target_mixture.temperature);\
	if (!initial) {\
		target_mixture.gas_content_change();\
	}\
}
// Frozen atmos
#define APPLY_FROZEN_ATMOS(target) ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial) {\
	var/final_thermal_energy = target_mixture.thermal_energy()\
		+ GLOB.gas_data.specific_heats[GAS_O2] * MOLES_O2STANDARD * 180\
		+ GLOB.gas_data.specific_heats[GAS_N2] * MOLES_N2STANDARD * 180;\
	target_mixture.gas_contents[GAS_O2] += MOLES_O2STANDARD;\
	target_mixture.gas_contents[GAS_N2] += MOLES_N2STANDARD;\
	target_mixture.total_moles += MOLES_O2STANDARD + MOLES_N2STANDARD;\
	target_mixture.temperature = 0;\
	target_mixture.adjust_thermal_energy(final_thermal_energy);\
	if (!initial) {\
		target_mixture.gas_content_change();\
	}\
}
// -14°C kitchen coldroom, just might lose your tail; higher amount of mol to reach about 101.3 kpA
#define APPLY_KITCHEN_COLDROOM_ATMOS(target) ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial) {\
	var/final_thermal_energy = target_mixture.thermal_energy()\
		+ GLOB.gas_data.specific_heats[GAS_O2] * 0.26 * MOLES_CELLSTANDARD * COLD_ROOM_TEMP\
		+ GLOB.gas_data.specific_heats[GAS_N2] * 0.97 * MOLES_CELLSTANDARD * COLD_ROOM_TEMP;\
	target_mixture.gas_contents[GAS_O2] += 0.26 * MOLES_CELLSTANDARD;\
	target_mixture.gas_contents[GAS_N2] += 0.97 * MOLES_CELLSTANDARD;\
	target_mixture.total_moles += 0.26 * MOLES_CELLSTANDARD + 0.97 * MOLES_CELLSTANDARD;\
	target_mixture.temperature = 0;\
	target_mixture.adjust_thermal_energy(final_thermal_energy);\
	if (!initial) {\
		target_mixture.gas_content_change();\
	}\
}
// used in the holodeck burn test program
#define APPLY_BURNMIX_ATMOS(target) ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial) {\
	var/final_thermal_energy = target_mixture.thermal_energy()\
		+ GLOB.gas_data.specific_heats[GAS_O2] * 1 * MOLES_CELLSTANDARD * 370\
		+ GLOB.gas_data.specific_heats[GAS_PLASMA] * 2 * MOLES_CELLSTANDARD * 370;\
	target_mixture.gas_contents[GAS_O2] += 1 * MOLES_CELLSTANDARD;\
	target_mixture.gas_contents[GAS_PLASMA] += 2 * MOLES_CELLSTANDARD;\
	target_mixture.total_moles += 3 * MOLES_CELLSTANDARD;\
	target_mixture.temperature = 0;\
	target_mixture.adjust_thermal_energy(final_thermal_energy);\
	if (!initial) {\
		target_mixture.gas_content_change();\
	}\
}

//LAVALAND
#define MAXIMUM_LAVALAND_EQUIPMENT_EFFECT_PRESSURE 90 //! what pressure you have to be under to increase the effect of equipment meant for lavaland
#define APPLY_LAVALAND_DEFAULT_ATMOS(target) ##target/populate_initial_gas(datum/gas_mixture/target_mixture, initial) {\
	var/final_thermal_energy = target_mixture.thermal_energy()\
		+ GLOB.gas_data.specific_heats[GAS_O2] * 0.14 * MOLES_CELLSTANDARD * 300\
		+ GLOB.gas_data.specific_heats[GAS_CO2] * 0.13 * MOLES_CELLSTANDARD * 300\
		+ GLOB.gas_data.specific_heats[GAS_N2] * 0.05 * MOLES_CELLSTANDARD * 300;\
	target_mixture.gas_contents[GAS_O2] += 0.14 * MOLES_CELLSTANDARD;\
	target_mixture.gas_contents[GAS_CO2] += 0.13 * MOLES_CELLSTANDARD;\
	target_mixture.gas_contents[GAS_N2] += 0.05 * MOLES_CELLSTANDARD;\
	target_mixture.total_moles += 0.32 * MOLES_CELLSTANDARD;\
	target_mixture.temperature = 0;\
	target_mixture.adjust_thermal_energy(final_thermal_energy);\
	if (!initial) {\
		target_mixture.gas_content_change();\
	}\
}

//ATMOS MIX IDS
//Lavaland used to live here. That was a mistake.

//ATMOSIA GAS MONITOR TAGS
#define ATMOS_GAS_MONITOR_INPUT_O2 "o2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_O2 "o2_out"
#define ATMOS_GAS_MONITOR_SENSOR_O2 "o2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_PLASMA "plasma_in"
#define ATMOS_GAS_MONITOR_OUTPUT_PLASMA "plasma_out"
#define ATMOS_GAS_MONITOR_SENSOR_PLASMA "plasma_sensor"

#define ATMOS_GAS_MONITOR_INPUT_AIR "air_in"
#define ATMOS_GAS_MONITOR_OUTPUT_AIR "air_out"
#define ATMOS_GAS_MONITOR_SENSOR_AIR "air_sensor"

#define ATMOS_GAS_MONITOR_INPUT_MIX "mix_in"
#define ATMOS_GAS_MONITOR_OUTPUT_MIX "mix_out"
#define ATMOS_GAS_MONITOR_SENSOR_MIX "mix_sensor"

#define ATMOS_GAS_MONITOR_INPUT_N2O "n2o_in"
#define ATMOS_GAS_MONITOR_OUTPUT_N2O "n2o_out"
#define ATMOS_GAS_MONITOR_SENSOR_N2O "n2o_sensor"

#define ATMOS_GAS_MONITOR_INPUT_N2 "n2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_N2 "n2_out"
#define ATMOS_GAS_MONITOR_SENSOR_N2 "n2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_CO2 "co2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_CO2 "co2_out"
#define ATMOS_GAS_MONITOR_SENSOR_CO2 "co2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_INCINERATOR "incinerator_in"
#define ATMOS_GAS_MONITOR_OUTPUT_INCINERATOR "incinerator_out"
#define ATMOS_GAS_MONITOR_SENSOR_INCINERATOR "incinerator_sensor"

#define ATMOS_GAS_MONITOR_INPUT_TOXINS_LAB "toxinslab_in"
#define ATMOS_GAS_MONITOR_OUTPUT_TOXINS_LAB "toxinslab_out"
#define ATMOS_GAS_MONITOR_SENSOR_TOXINS_LAB "toxinslab_sensor"

#define ATMOS_GAS_MONITOR_LOOP_DISTRIBUTION "distro-loop_meter"
#define ATMOS_GAS_MONITOR_LOOP_ATMOS_WASTE "atmos-waste_loop_meter"

#define ATMOS_GAS_MONITOR_WASTE_ENGINE "engine-waste_out"
#define ATMOS_GAS_MONITOR_WASTE_ATMOS "atmos-waste_out"

#define ATMOS_GAS_MONITOR_INPUT_SM "sm_in"
#define ATMOS_GAS_MONITOR_OUTPUT_SM "sm_out"
#define ATMOS_GAS_MONITOR_SENSOR_SM "sm_sense"

#define ATMOS_GAS_MONITOR_INPUT_SM_WASTE "sm_waste_in"
#define ATMOS_GAS_MONITOR_OUTPUT_SM_WASTE "sm_waste_out"
#define ATMOS_GAS_MONITOR_SENSOR_SM_WASTE "sm_waste_sense"

#define ATMOS_GAS_MONITOR_INPUT_TOXINS_WASTE "toxins_waste_in"
#define ATMOS_GAS_MONITOR_OUTPUT_TOXINS_WASTE "toxins_waste_out"
#define ATMOS_GAS_MONITOR_SENSOR_TOXINS_WASTE "toxins_waste_sense"

//AIRLOCK CONTROLLER TAGS

//RnD toxins burn chamber
#define INCINERATOR_TOXMIX_IGNITER 				"toxmix_igniter"
#define INCINERATOR_TOXMIX_VENT 				"toxmix_vent"
#define INCINERATOR_TOXMIX_DP_VENTPUMP			"toxmix_airlock_pump"
#define INCINERATOR_TOXMIX_AIRLOCK_SENSOR 		"toxmix_airlock_sensor"
#define INCINERATOR_TOXMIX_AIRLOCK_CONTROLLER 	"toxmix_airlock_controller"
#define INCINERATOR_TOXMIX_AIRLOCK_INTERIOR 	"toxmix_airlock_interior"
#define INCINERATOR_TOXMIX_AIRLOCK_EXTERIOR 	"toxmix_airlock_exterior"

//Atmospherics/maintenance incinerator
#define INCINERATOR_ATMOS_IGNITER 				"atmos_incinerator_igniter"
#define INCINERATOR_ATMOS_MAINVENT 				"atmos_incinerator_mainvent"
#define INCINERATOR_ATMOS_AUXVENT 				"atmos_incinerator_auxvent"
#define INCINERATOR_ATMOS_DP_VENTPUMP			"atmos_incinerator_airlock_pump"
#define INCINERATOR_ATMOS_AIRLOCK_SENSOR 		"atmos_incinerator_airlock_sensor"
#define INCINERATOR_ATMOS_AIRLOCK_CONTROLLER	"atmos_incinerator_airlock_controller"
#define INCINERATOR_ATMOS_AIRLOCK_INTERIOR 		"atmos_incinerator_airlock_interior"
#define INCINERATOR_ATMOS_AIRLOCK_EXTERIOR 		"atmos_incinerator_airlock_exterior"

//Syndicate lavaland base incinerator (lavaland_surface_syndicate_base1.dmm)
#define INCINERATOR_SYNDICATELAVA_IGNITER 				"syndicatelava_igniter"
#define INCINERATOR_SYNDICATELAVA_MAINVENT 				"syndicatelava_mainvent"
#define INCINERATOR_SYNDICATELAVA_AUXVENT 				"syndicatelava_auxvent"
#define INCINERATOR_SYNDICATELAVA_DP_VENTPUMP			"syndicatelava_airlock_pump"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_SENSOR 		"syndicatelava_airlock_sensor"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_CONTROLLER 	"syndicatelava_airlock_controller"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_INTERIOR 		"syndicatelava_airlock_interior"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_EXTERIOR	 	"syndicatelava_airlock_exterior"

//MULTIPIPES
//IF YOU EVER CHANGE THESE CHANGE SPRITES TO MATCH.
#define PIPING_LAYER_MIN 1
#define PIPING_LAYER_MAX 5
#define PIPING_LAYER_DEFAULT 3
#define PIPING_LAYER_P_X 5
#define PIPING_LAYER_P_Y 5
#define PIPING_LAYER_LCHANGE 0.05

#define PIPING_ALL_LAYER				(1<<0)	//! intended to connect with all layers, check for all instead of just one.
#define PIPING_ONE_PER_TURF				(1<<1) 	//! can only be built if nothing else with this flag is on the tile already.
#define PIPING_DEFAULT_LAYER_ONLY		(1<<2)	//! can only exist at PIPING_LAYER_DEFAULT
#define PIPING_CARDINAL_AUTONORMALIZE	(1<<3)	//! north/south east/west doesn't matter, auto normalize on build.

// Gas defines
// Start at 1 and increment by 1 each time
#define GAS_O2 1
#define GAS_N2 2
#define GAS_CO2	3
#define GAS_PLASMA 4
#define GAS_H2O 5
#define GAS_HYPERNOB 6
#define GAS_NITROUS 7
#define GAS_NITRYL 8
#define GAS_TRITIUM 9
#define GAS_BZ 10
#define GAS_STIMULUM 11
#define GAS_PLUOXIUM 12

// Maximum gas ID
#define GAS_MAX 12

#define GAS_FLAG_DANGEROUS		(1<<0)
#define GAS_FLAG_BREATH_PROC	(1<<1)

//HELPERS
#define PIPING_LAYER_SHIFT(T, PipingLayer) \
	if(T.dir & (NORTH|SOUTH)) {									\
		T.pixel_x = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X;\
	}																		\
	if(T.dir & (EAST|WEST)) {										\
		T.pixel_y = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y;\
	}

#define PIPING_FORWARD_SHIFT(T, PipingLayer, more_shift) \
	if(T.dir & (NORTH|SOUTH)) {									\
		T.pixel_y += more_shift * (PipingLayer - PIPING_LAYER_DEFAULT);\
	}																		\
	if(T.dir & (EAST|WEST)) {										\
		T.pixel_x += more_shift * (PipingLayer - PIPING_LAYER_DEFAULT);\
	}

#define PIPING_LAYER_DOUBLE_SHIFT(T, PipingLayer) \
	T.pixel_x = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X;\
	T.pixel_y = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y;

#ifdef TESTING
GLOBAL_LIST_INIT(atmos_adjacent_savings, list(0,0))
#define CALCULATE_ADJACENT_TURFS(T) if (SSadjacent_air.queue[T]) { GLOB.atmos_adjacent_savings[1] += 1 } else { GLOB.atmos_adjacent_savings[2] += 1; SSadjacent_air.queue[T] = 1 }
#else
#define CALCULATE_ADJACENT_TURFS(T) SSadjacent_air.queue[T] = 1
#endif

GLOBAL_LIST_INIT(pipe_paint_colors, sort_list(list(
		"amethyst" = rgb(130,43,255),
		"blue" = rgb(0,0,255),
		"brown" = rgb(178,100,56),
		"cyan" = rgb(0,255,249),
		"dark" = rgb(69,69,69),
		"green" = rgb(30,255,0),
		"grey" = rgb(255,255,255),
		"orange" = rgb(255,129,25),
		"purple" = rgb(128,0,182),
		"red" = rgb(255,0,0),
		"violet" = rgb(64,0,128),
		"yellow" = rgb(255,198,0)
)))

//PIPENET UPDATE STATUS
#define PIPENET_UPDATE_STATUS_DORMANT 0
#define PIPENET_UPDATE_STATUS_REACT_NEEDED 1
#define PIPENET_UPDATE_STATUS_RECONCILE_NEEDED 2

// GAS MIXTURE STUFF (used to be in code/modules/atmospherics/gasmixtures/gas_mixture.dm)
#define MINIMUM_HEAT_CAPACITY	0.0003
#define MINIMUM_MOLE_COUNT		0.01
/*I feel the need to document what happens here. Basically this is used to catch most rounding errors, however it's previous value made it so that
once gases got hot enough, most procedures wouldnt occur due to the fact that the mole counts would get rounded away. Thus, we lowered it a few orders of magnititude */
#define QUANTIZE(variable)		(round(variable,0.0000001))
