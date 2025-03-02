/datum/orbital_object/ils_beacon
	name = "ILS Beacon"
	radius = 30
	static_object = TRUE
	var/obj/docking_port/stationary/port

/datum/orbital_object/ils_beacon/New(obj/docking_port/stationary/port)
	if (!port)
		CRASH("ILS Beacon created without a port")
	src.name = "ILS Beacon ([port.name])"
	src.port = port
	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]
	radius = (max(port.width, port.height) / world.maxx) * parent_map.map_size
	return ..(new /datum/orbital_vector(0, 0, 0), new /datum/orbital_vector(0, 0, 0), PRIMARY_ORBITAL_MAP)

/datum/orbital_object/ils_beacon/post_map_setup()
	set_position(port.x, port.y)
