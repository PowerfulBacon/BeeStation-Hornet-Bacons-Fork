/// How often the sensor data updates.
#define SENSORS_UPDATE_PERIOD 1 MINUTES
/// How many missed pings until a mob is declared as missing
#define SENSORS_MISSING_PINGS 5

SUBSYSTEM_DEF(suit_sensors)
	name = "Suit sensor network"
	flags = SS_NO_INIT
	wait = SENSORS_UPDATE_PERIOD

	/// Mobs that we are currently processing, in cases of tick overrun
	var/list/current_run = list()

/datum/controller/subsystem/suit_sensors/fire(resumed)
	if (!resumed)
		current_run = GLOB.carbon_list.Copy()
	while (current_run.len)
		// Pull the top element
		var/mob/living/carbon/top_carbon = current_run[current_run.len]
		current_run.len --
		// Subsystem Overruns
		if (MC_TICK_CHECK)
			return

/datum/suit_sensor_data
	/// How should this mob show pu on the sensors?
	var/name
	/// The mob that we are currently attached to.
	var/mob/tracking_mob
	/// Do we actually care who this is?
	/// If true, then we will track when they go missing and display that. If not,
	/// we will just scrub them from the sensor network.
	var/important = FALSE
	/// How many times have we missed pings?
	var/missed_pings
	/// The last few positions of the player, so that we can display inaccurate
	/// last known position data if they have sensors off or go missing. This is
	/// purposely inaccurate and slow to update.
	/// Null if the data is not marked as important
	var/list/last_positions
	/// Their job assignment
	var/assignment
	/// Their job icon
	var/job_icon
	/// Total oxygen damage
	var/oxygen_damage
	/// Total toxin damage
	var/toxin_damage
	/// Total brute damage
	var/brute_damage
	/// Total burn damage
	var/burn_damage
	/// Current position
	var/current_location
	/// Can the AI track this entry?
	var/can_track
	/// What are the current sensor levels of the target?
	var/target_sensors

/// If the mob is fully deleted and they don't matter, then just delete the entry.
/datum/suit_sensor_data/proc/on_mob_deleted()
	SIGNAL_HANDLER
	tracking_mob = null
	if (!important)
		qdel(src)

/datum/suit_sensor_data/proc/update_entry()
	if (!tracking_mob)
		target_missing(source)
		return
	var/turf/position = get_turf(tracking_mob)
	if (!position)
		target_missing(source)
		return
	// Just skip for now
	if (!ishuman(tracking_mob))
		return
	// The system cannot tell the difference between jammed mobs
	// and missing mobs.
	if (tracking_mob.is_jammed(JAMMER_PROTECTION_SENSOR_NETWORK))
		target_missing(source)
		return
	// Determine the type of sensors
	var/nanite_sensors = HAS_TRAIT(tracking_mob, TRAIT_NANITE_SENSORS)
	var/obj/item/clothing/under/uniform = tracking_mob.w_uniform
	// Determine the currently known position
	var/camera_position = (nanite_sensors || (uniform?.has_sensor > NO_SENSORS && uniform.sensor_mode) || GLOB.cameranet.checkTurfVis(position)) ? get_area_name(tracking_mob, TRUE) : null
	// Update the last known position
	for (var/i in 1 to SENSORS_MISSING_PINGS - 1)
		last_positions[i] = last_positions[i + 1]
	// The last known position is what we will record instead
	last_positions[SENSORS_MISSING_PINGS] = camera_position || last_positions[SENSORS_MISSING_PINGS - 1]

/// For when a target is completely missing (Off-cameras or non existant)
/datum/suit_sensor_data/proc/target_missing(list/source)
	missed_pings ++
	// We don't care if they are missing
	if (!important)
		return
	// if they haven't missed a lot of pings, display their last record
	// Once they miss enough pings, then mark them as missing and display their
	// last seen appearance on camera a few ticks ago
	for (var/i in 1 to SENSORS_MISSING_PINGS - 1)
		last_positions[i] = last_positions[i + 1]
	// The last known position is what we will record instead
	last_positions[SENSORS_MISSING_PINGS] = last_positions[SENSORS_MISSING_PINGS - 1]
