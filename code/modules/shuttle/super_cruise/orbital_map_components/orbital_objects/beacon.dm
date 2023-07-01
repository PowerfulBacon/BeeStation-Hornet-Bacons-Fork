/datum/orbital_object/z_linked/beacon
	name = "Unidentified Signal"
	mass = 0
	radius = 60
	can_dock_anywhere = TRUE
	render_mode = RENDER_MODE_BEACON
	signal_range = 2000
	orbit_distance = 9000
	orbit_distance_variation = 5000
	//The attached event
	var/datum/ruin_event/ruin_event

/datum/orbital_object/z_linked/beacon/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	ruin_event = SSorbits.get_event()
	if(ruin_event?.warning_message)
		name = "[initial(name)] #[rand(1, 9)][linked_map.object_count][rand(1, 9)] ([ruin_event.warning_message])"
	else
		name = "[initial(name)] #[rand(1, 9)][linked_map.object_count][rand(1, 9)]"
	//Link the ruin event to ourselves
	ruin_event?.linked_z = src

/datum/orbital_object/z_linked/beacon/weak
	name = "Weak Signal"
	signal_range = 700

/datum/orbital_object/z_linked/beacon/proc/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src

//====================
// Asteroids
//====================

/datum/orbital_object/z_linked/beacon/asteroid
	name = "Asteroid"
	render_mode = RENDER_MODE_DEFAULT
	signal_range = 0
	orbit_distance = 3000
	orbit_distance_variation = 500

/datum/orbital_object/z_linked/beacon/asteroid/New()
	. = ..()
	radius = rand(40, 160)

/datum/orbital_object/z_linked/beacon/asteroid/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	generate_asteroids(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, quick_generation ? 40 : 70, rand(-0.5, 0), rand(40, 70))

/datum/orbital_object/z_linked/beacon/asteroid/deep_space
	orbit_distance = 10000
	orbit_distance_variation = 5000

//====================
// Regular Ruin Z-levels
//====================

/datum/orbital_object/z_linked/beacon/spaceruin
	name = "Unknown Signal"

/datum/orbital_object/z_linked/beacon/spaceruin/New()
	. = ..()
	SSorbits.ruin_levels ++

/datum/orbital_object/z_linked/beacon/spaceruin/Destroy(force, ...)
	. = ..()
	SSorbits.ruin_levels --

/datum/orbital_object/z_linked/beacon/spaceruin/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	seedRuins(list(assigned_space_level.z_value), CONFIG_GET(number/space_budget), /area/space, SSmapping.space_ruins_templates)

//====================
// Random-Ruin z-levels
//====================
/datum/orbital_object/z_linked/beacon/ruin
	//The linked objective to the ruin, for generating extra stuff if required.
	var/datum/orbital_objective/linked_objective

/datum/orbital_object/z_linked/beacon/ruin/Destroy()
	//Remove linked objective.
	if(linked_objective)
		linked_objective.linked_beacon = null
		linked_objective = null
	. = ..()

/datum/orbital_object/z_linked/beacon/ruin/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	generate_space_ruin(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, quick_generation ? 30 : 50, quick_generation ? 30 : 50, linked_objective, null, ruin_event)

//====================
//Stranded shuttles
//====================

/datum/orbital_object/z_linked/beacon/stranded_shuttle
	name = "Distress Beacon"
	static_object = TRUE
	signal_range = 0

/datum/orbital_object/z_linked/beacon/stranded_shuttle/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src
	generate_asteroids(world.maxx / 2, world.maxy / 2, assigned_space_level.z_value, quick_generation ? 40 : 120, -0.2, 40)

/datum/orbital_object/z_linked/beacon/stranded_shuttle/post_map_setup()
	return

//====================
//Interdiction
//====================

/datum/orbital_object/z_linked/beacon/interdiction
	name = "Distress Beacon"
	static_object = TRUE
	signal_range = 0

/datum/orbital_object/z_linked/beacon/interdiction/assign_z_level(quick_generation = FALSE)
	var/datum/space_level/assigned_space_level = SSzclear.get_free_z_level()
	linked_z_level = list(assigned_space_level)
	SSorbits.assoc_z_levels["[assigned_space_level.z_value]"] = src

/datum/orbital_object/z_linked/beacon/interdiction/post_map_setup()
	return
