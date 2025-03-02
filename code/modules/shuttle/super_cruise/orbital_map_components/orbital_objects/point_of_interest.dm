/datum/orbital_object/point_of_interest
	name = "Beacon"
	radius = 30
	static_object = TRUE
	var/init_x
	var/init_y

/datum/orbital_object/point_of_interest/New(name, x, y, tile_size = 5)
	. = ..(new /datum/orbital_vector(0, 0), new /datum/orbital_vector(0, 0), PRIMARY_ORBITAL_MAP)
	src.name = name
	init_x = x
	init_y = y
	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]
	radius = (tile_size / world.maxx) * parent_map.map_size

/datum/orbital_object/point_of_interest/post_map_setup()
	set_position(init_x, init_y)
