/datum/orbital_object/z_linked/lavaland
	name = "Lavaland"
	mass = 10000
	radius = 200
	forced_docking = TRUE
	static_object = TRUE
	random_docking = TRUE
	render_mode = RENDER_MODE_PLANET
	priority = 90
	signal_range = 10000
	//If you manage to go fast enough, you can crash
	min_collision_velocity = 100

/datum/orbital_object/z_linked/lavaland/New()
	. = ..()
	var/datum/orbital_map/linked_map = SSorbits.orbital_maps[orbital_map_index]
	linked_map.center = src
