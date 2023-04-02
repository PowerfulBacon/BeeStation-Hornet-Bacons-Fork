/datum/orbital_object/z_linked/base
	name = "Unknown Base"
	mass = 0
	radius = 60
	priority = 400
	//The station maintains its orbit around lavaland by adjustment thrusters.
	maintain_orbit = TRUE
	//Sure, why not?
	can_dock_anywhere = TRUE
	signal_range = 4000
	var/allowed_faction_type = null

#ifdef LOWMEMORYMODE
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src
#endif

/datum/orbital_object/z_linked/base/post_map_setup()
	//Orbit around the system center
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	set_orbitting_around_body(linked_map.center, rand(4000, 10000))

/datum/orbital_object/z_linked/base/can_dock_here(datum/orbital_object/shuttle/shuttle)
	if (SSround_manager.base_docking_allowed)
		return TRUE
	if (istype(shuttle.shuttle_data.faction, allowed_faction_type))
		return TRUE
	return FALSE

/datum/orbital_object/z_linked/base/syndicate
	name = "Syndicate Hideout"
	allowed_faction_type = /datum/faction/syndicate

/datum/orbital_object/z_linked/base/nanotrasen
	name = "Nanotrasen Forward Operating Base"
	allowed_faction_type = /datum/faction/nanotrasen
