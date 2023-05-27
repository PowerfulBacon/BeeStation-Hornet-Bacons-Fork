/**
 * Test to ensure that objects with a velocity correctly update their position
 * in their processing loop.
 */

/datum/unit_test/basic_object_movement/Run()
	// Reset the orbital map for testing
	SSorbits.orbital_maps[PRIMARY_ORBITAL_MAP] = new /datum/orbital_map()
	var/datum/orbital_object/moving_object = new(
		new /datum/orbital_vector(-500, 0),
		new /datum/orbital_vector(1000, 0),
		PRIMARY_ORBITAL_MAP
	)
	// Run the simulation for 1 second
	moving_object.process(1 SECONDS)
	// Assert the position of the object is correct
	if (moving_object.position.x != 500 || moving_object.position.y != 0)
		Fail("Failed basic movement test for orbital objects. An object spawned at (-500, 0) moving at (1000, 0)/s was not in the expected position. Expected: (500, 0), Actual: ([moving_object.position.x], [moving_object.position.y])")

/**
 * Secondary test to ensure that objects are in the correct grids after movement
 * occurs.
 */

/datum/unit_test/supercruise_map_zoning/Run()
	// Reset the orbital map for testing
	var/datum/orbital_map/map = new /datum/orbital_map()
	SSorbits.orbital_maps[PRIMARY_ORBITAL_MAP] = map
	var/datum/orbital_object/moving_object = new(
		new /datum/orbital_vector(-ORBITAL_MAP_ZONE_SIZE * 2, 0),
		new /datum/orbital_vector(ORBITAL_MAP_ZONE_SIZE * 3, ORBITAL_MAP_ZONE_SIZE * 2),
		PRIMARY_ORBITAL_MAP
	)
	// Assert that the object is in the correct map position
	var/expected_x = round(position.GetX() / ORBITAL_MAP_ZONE_SIZE)
	var/expected_y = round(position.GetY() / ORBITAL_MAP_ZONE_SIZE)
	var/position_key = "[expected_x],[expected_y]"
	if (!(moving_object in collision_zone_bodies[position_key]))
		Fail("Failed supercruise map zoning test. The object was not in the expected grid cell of [expected_x],[expected_y]. Are base orbital objects being moved directly instead of by using the wrapper define?")
	// Run the simulation for 1 second
	moving_object.process(1 SECONDS)
	// Assert that the object is in the correct map position
	expected_x = round(position.GetX() / ORBITAL_MAP_ZONE_SIZE)
	expected_y = round(position.GetY() / ORBITAL_MAP_ZONE_SIZE)
	position_key = "[expected_x],[expected_y]"
	if (!(moving_object in collision_zone_bodies[position_key]))
		Fail("Failed supercruise map zoning test. The object was not in the expected grid cell of [expected_x],[expected_y]. Are base orbital objects being moved directly instead of by using the wrapper define?")

