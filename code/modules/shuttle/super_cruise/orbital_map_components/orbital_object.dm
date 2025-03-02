/datum/orbital_object
	var/name = "undefined"
	//Unique ID of the orbital object
	var/unique_id = ""
	//Radius of the object in arbitary space units
	var/radius = 1
	//What render mode to use
	var/render_mode = RENDER_MODE_DEFAULT
	//Position of the object (0,0) is the center of the map.
	//Position is in kilometers
	//If this is modified, on_body_move() MUST be called. (Really this should be a helper proc)
	var/datum/orbital_vector/position = new()
	//Velocity of the object
	//KILOMETERS PER SECOND
	var/datum/orbital_vector/velocity = new()
	//Static objects don't get moved.
	var/static_object = FALSE
	//Are we invisible on the map?
	var/stealth = FALSE
	//Multiplier for velocity
	var/velocity_multiplier = 1
	//Priority in the sorted list
	var/priority = 0

	//Delta time updates
	//Ship translations are smooth so must use a delta time
	//Dont get confused with subsystem delta_time as this accounts for time dilation
	var/last_update_tick = 0

	//CALCULATED IN INIT
	//Are we force-orbitting something?
	var/orbitting = FALSE
	//Bodies that are orbitting us.
	var/list/orbitting_bodies = list()
	//Are we currently immune to collisions
	var/collision_ignored = TRUE
	//What are we colliding with
	var/list/datum/orbital_object/colliding_with

	//The index or the orbital map we exist in
	var/orbital_map_index = PRIMARY_ORBITAL_MAP

	//Our collision type
	var/collision_type = COLLISION_UNDEFINED
	//The collision flags we register with
	//Add to this when you want THIS objects collision proc to be called.
	var/collision_flags = NONE
	/// Are we considered to be in orbit?
	/// Once we enter orbit, we no longer exist on the map and have a countdown
	/// before we enter the station.
	var/is_in_orbit = ORBITAL_STATUS_NONE

/datum/orbital_object/New(datum/orbital_vector/position, datum/orbital_vector/velocity, orbital_map_index)
	if(orbital_map_index)
		src.orbital_map_index = orbital_map_index
	if(position)
		src.position = position
	if(velocity)
		src.velocity = velocity
	var/static/created_amount = 0
	unique_id = "ObjID[++created_amount]"
	. = ..()
	//Process this
	if(!static_object)
		START_PROCESSING(SSorbits, src)
	//Add to orbital map
	var/datum/orbital_map/map = SSorbits.orbital_maps[src.orbital_map_index]
	map.add_body(src)
	//If orbits has already setup, then post map setup
	if(SSorbits.orbits_setup)
		post_map_setup()

/datum/orbital_object/Destroy()
	STOP_PROCESSING(SSorbits, src)
	var/datum/orbital_map/map = SSorbits.orbital_maps[orbital_map_index]
	map.remove_body(src)
	. = ..()

/datum/orbital_object/proc/explode()
	return

//Process orbital objects
/datum/orbital_object/process(delta_time)
	//Dont process updates for static objects.
	if(static_object)
		return PROCESS_KILL
	if (is_in_orbit == ORBITAL_STATUS_ORBIT)
		return

	last_update_tick = world.time

	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]

	//===================================
	// GRAVITY
	//===================================

	//var/force = -gravity * delta_time * SHUTTLE_WEIGHT

	//===================================
	// LIFT
	//===================================



	//===================================
	// MOVEMENT
	//===================================
	//Remember this
	var/prev_x = position.x
	var/prev_y = position.y

	//Move the gravitational body.
	var/datum/orbital_vector/vel_new = new(velocity.x * delta_time * velocity_multiplier, velocity.y * delta_time * velocity_multiplier)
	position.AddSelf(vel_new)

	if (position.x > parent_map.map_size * 0.5)
		position.x -= parent_map.map_size + 10
	if (position.x < parent_map.map_size * -0.5)
		position.x += parent_map.map_size - 10
	if (position.y > parent_map.map_size * 0.5)
		position.y -= parent_map.map_size + 10
	if (position.y < parent_map.map_size * -0.5)
		position.y += parent_map.map_size - 10

	//Oh we moved btw
	parent_map.on_body_move(src, prev_x, prev_y)

	//===================================
	// Ground Impact
	//===================================

	if (position.z <= 0 && impact_ground())
		return

	//===================================
	// ORBITAL
	//===================================

	// Check if we have the height to enter orbit
	is_in_orbit = position.z > ORBIT_HEIGHT ? ORBITAL_STATUS_READY : ORBITAL_STATUS_NONE

	//===================================
	// COLLISION CHECKING
	//===================================
	var/colliding = FALSE
	LAZYCLEARLIST(colliding_with)

	//Calculate our current position
	var/section_x = round(position.x / ORBITAL_MAP_ZONE_SIZE)
	var/section_y = round(position.y / ORBITAL_MAP_ZONE_SIZE)

	var/position_key = "[section_x],[section_y]"
	var/valid_side_key = "none"
	var/valid_front_key = "none"
	var/valid_corner_key = "none"

	var/dir_flags = NONE

	var/segment_x = (position.x + abs(section_x) * ORBITAL_MAP_ZONE_SIZE) % ORBITAL_MAP_ZONE_SIZE
	var/segment_y = (position.y + abs(section_y) * ORBITAL_MAP_ZONE_SIZE) % ORBITAL_MAP_ZONE_SIZE

	if(segment_x < ORBITAL_MAP_ZONE_SIZE / 3)
		valid_side_key = "[section_x - 1],[section_y]"
		dir_flags |= WEST
	else if(segment_x > 2 * (ORBITAL_MAP_ZONE_SIZE / 3))
		valid_side_key = "[section_x + 1],[section_y]"
		dir_flags |= EAST

	if(segment_y < ORBITAL_MAP_ZONE_SIZE / 3)
		valid_front_key = "[section_x],[section_y - 1]"
		dir_flags |= SOUTH
	else if(segment_y > 2 * (ORBITAL_MAP_ZONE_SIZE / 3))
		valid_front_key = "[section_x],[section_y + 1]"
		dir_flags |= NORTH

	//Check multiple zones
	if(dir_flags & EAST)
		if(dir_flags & NORTH)
			valid_corner_key = "[section_x + 1],[section_y + 1]"
		else if(dir_flags & SOUTH)
			valid_corner_key = "[section_x + 1],[section_y - 1]"
	else if(dir_flags & WEST)
		if(dir_flags & NORTH)
			valid_corner_key = "[section_x - 1],[section_y + 1]"
		else if(dir_flags & SOUTH)
			valid_corner_key = "[section_x - 1],[section_y - 1]"

	var/list/valid_objects = list()

	//Only check nearby segments for collision objects
	if(parent_map.collision_zone_bodies[position_key])
		valid_objects += parent_map.collision_zone_bodies[position_key]
	if(parent_map.collision_zone_bodies[valid_side_key])
		valid_objects += parent_map.collision_zone_bodies[valid_side_key]
	if(parent_map.collision_zone_bodies[valid_front_key])
		valid_objects += parent_map.collision_zone_bodies[valid_front_key]
	if(parent_map.collision_zone_bodies[valid_corner_key])
		valid_objects += parent_map.collision_zone_bodies[valid_corner_key]

	//Track our delta positional values for collision detection purposes
	var/delta_x = position.x - prev_x
	var/delta_y = position.y - prev_y

	for(var/datum/orbital_object/object as() in valid_objects)
		if(object == src)
			continue
		if(!(object.collision_type & collision_flags) && !(object.static_object && (collision_type & object.collision_flags)))
			continue
		var/distance = object.position.DistanceTo(position)
		if(distance < radius + object.radius)
			//Collision
			LAZYADD(colliding_with, object)
			collision(object)
			//Static objects dont check collisions, so call their collision proc for them.
			if(object.static_object)
				object.collision(src)
			colliding = TRUE
		else if(!object.static_object)
			//Vector collision.
			//Note: We detect collisions that occursed in the current move rather than in the next.
			//Position - Velocity -> Position
			//Detects collisions for when 2 objects pass each other.
			//Get the intersection point
			//Must be between 0 and 1
			var/other_x
			var/other_y
			var/other_delta_x = object.velocity.x
			var/other_delta_y = object.velocity.y
			if(object.last_update_tick == last_update_tick)
				//They are on the same tick as us
				other_x = object.position.x - other_delta_x
				other_y = object.position.y - other_delta_y
			else
				//They are still on the previous tick
				other_x = object.position.x
				other_y = object.position.y
			//ALRIGHT LETS DO THE CHECK
			//Reassign variables for ease of read.
			var/px = prev_x
			var/py = prev_y
			var/vx = delta_x
			var/vy = delta_y
			var/px2 = other_x
			var/py2 = other_y
			var/vx2 = other_delta_x
			var/vy2 = other_delta_y
			//Both must be moving
			if((vx || vy) && (vx2 || vy2))
				//Collision between 2 vectors using simultaneous equations.
				var/mu = (vx * py2 + vy * px - py * vx - vy * px2) / (vy * vx2 - vx * vy2)
				var/lambda = (px2 + vx2 * mu - px) / vx
				if(lambda >= 0 && lambda <= 1 && mu >= 0 && mu <= 1)
					//Collision
					LAZYADD(colliding_with, object)
					collision(object)
					colliding = TRUE
	if(!colliding)
		collision_ignored = FALSE

//We do a little suvatting
/datum/orbital_object/proc/accelerate_towards(datum/orbital_vector/acceleration_vector, time)
	velocity.AddSelf(acceleration_vector.ScaleSelf(time))

//Called when we collide with another orbital object.
//Make sure to check if(other.collision_ignored || collision_ignored)
/datum/orbital_object/proc/collision(datum/orbital_object/other)
	return

/// Set the position of the orbital object relative to the world position
/datum/orbital_object/proc/set_position(world_x, world_y)
	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]
	var/prev_x = position.x
	var/prev_y = position.y
	position.x = (world_x / world.maxx) * parent_map.map_size - (parent_map.map_size * 0.5)
	position.y = (world_y / world.maxy) * parent_map.map_size - (parent_map.map_size * 0.5)
	parent_map.on_body_move(src, prev_x, prev_y)

/datum/orbital_object/proc/post_map_setup()
	return

/datum/orbital_object/proc/get_map_turf()
	RETURN_TYPE(/turf)

/// Return true to cancel the rest of the movement
/datum/orbital_object/proc/impact_ground()
	return FALSE
