/datum/orbital_object/ils_beacon
	name = "ILS Beacon"
	radius = 30
	static_object = TRUE
	var/obj/docking_port/stationary/port

/datum/orbital_object/ils_beacon/New(obj/docking_port/stationary/port)
	. = ..()
	src.name = "ILS Beacon ([port.name])"
	src.port = port
	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]
	radius = (max(port.width, port.height) / world.maxx) * parent_map.map_size

/datum/orbital_object/ils_beacon/post_map_setup()
	set_position(port.x, port.y)
