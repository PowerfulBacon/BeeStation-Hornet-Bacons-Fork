/obj/docking_port/mobile/proc/enter_supercruise()
	//Must be idle to supercruise.
	if(mode != SHUTTLE_IDLE)
		return
	//Inherit orbital velocity of the place we are leaving
	var/datum/orbital_map/map = SSorbits.orbital_maps[PRIMARY_ORBITAL_MAP]
	//Start moving
	destination = null
	mode = SHUTTLE_IGNITING
	setTimer(ignitionTime)
	//Enter the orbital system
	var/datum/orbital_object/shuttle/our_orbital_body = new shuttle_object_type(
		new /datum/orbital_vector(rand(-map.map_size * 0.5, map.map_size * 0.5), rand(-map.map_size * 0.5, map.map_size * 0.5), ORBIT_HEIGHT + 20000),
		new /datum/orbital_vector(0, 0, 0)
	)
	//Linkup
	our_orbital_body.link_shuttle(src)
	return our_orbital_body
