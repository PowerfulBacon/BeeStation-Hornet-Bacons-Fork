/// ====================
/// Exploration subsystem, manages all things related
/// to exploration that need processing.
/// Manages progression of exploration related content.
/// Current Functionality:
/// - Objective Processing
/// - Material Sample Progression
///
/// @PowerfulBacon#3338
/// ====================

SUBSYSTEM_DEF(exploration)
	name = "Exploration Progression"
	flags = NONE
	init_order = INIT_ORDER_DEFAULT
	priority = FIRE_PRIORITY_EXPLORATION
	wait = 10 SECONDS

	// Artifact Material Progression
	// Artifacts become more difficult to research over time
	// as more materials get introduced into the game.
	var/list/datum/material_sample/current_samples = list()
	var/sample_difficulty = 0
	var/next_sample_introduction = 0

	// Objectives
	var/list/datum/orbital_objective/possible_objectives = list()
	var/datum/orbital_objective/current_objective
	var/next_objective_time = 0

/datum/controller/subsystem/exploration/Initialize(start_timeofday)
	. = ..()
	//Initialize at least 1 possible sample
	check_sample_progression()

/// Called in the event that the subsystem fails and needs to be
/// recreated.
/datum/controller/subsystem/exploration/Recover()
	possible_objectives |= SSexploration.possible_objectives
	current_objective = SSexploration.current_objective
	next_objective_time = SSexploration.next_objective_time

/// Called automatically every 10 seconds
/datum/controller/subsystem/exploration/fire(resumed)
	//Check sample progression
	check_sample_progression()
	//Check creating objectives / missions.
	if(next_objective_time < world.time && length(possible_objectives) < 6)
		create_objective()
		next_objective_time = world.time + rand(5 SECONDS, 30 SECONDS) * length(possible_objectives)
	//Check objective
	if(current_objective)
		if(current_objective.check_failed())
			priority_announce("Central Command priority objective failed.", "Central Command Report", SSstation.announcer.get_rand_report_sound())
			QDEL_NULL(current_objective)

/datum/controller/subsystem/exploration/proc/check_sample_progression()
	if(world.time < next_sample_introduction)
		return
	//Increase sample difficulty
	sample_difficulty ++
	//Create a new possible sample
	current_samples += new /datum/material_sample
	//Wait for some time before introducting a new sample
	next_sample_introduction = 90 SECONDS * sample_difficulty

/// Creates a new objective from a list of weighted objectives.
/// Updates all objective consoles on the map
/datum/controller/subsystem/exploration/proc/create_objective()
	var/static/list/valid_objectives = list(
		/datum/orbital_objective/recover_blackbox = 3,
		/datum/orbital_objective/nuclear_bomb = 1,
		/datum/orbital_objective/assassination = 1,
		/datum/orbital_objective/artifact = 2,
		/datum/orbital_objective/vip_recovery = 1
	)
	if(!length(possible_objectives))
		priority_announce("Priority station objective recieved - Details transmitted to all available objective consoles. \
			[GLOB.station_name] will have funds distributed upon objective completion.", "Central Command Report", SSstation.announcer.get_rand_report_sound())
	var/chosen = pickweight(valid_objectives)
	if(!chosen)
		return
	var/datum/orbital_objective/objective = new chosen()
	objective.generate_payout()
	possible_objectives += objective
	update_objective_computers()

/datum/controller/subsystem/exploration/proc/assign_objective(objective_computer, datum/orbital_objective/objective)
	if(!possible_objectives.Find(objective))
		return "Selected objective is no longer available or has been claimed already."
	if(current_objective)
		return "An objective has already been selected and must be completed first."
	objective.on_assign(objective_computer)
	objective.generate_attached_beacon()
	objective.announce()
	current_objective = objective
	possible_objectives.Remove(objective)
	update_objective_computers()
	return "Objective selected, good luck."

/datum/controller/subsystem/exploration/proc/update_objective_computers()
	for(var/obj/machinery/computer/objective/computer as() in GLOB.objective_computers)
		for(var/M in computer.viewing_mobs)
			computer.update_static_data(M)

