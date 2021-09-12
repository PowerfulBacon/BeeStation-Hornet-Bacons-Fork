/datum/orbital_object
	var/name = "undefined"
	//Unique ID of the orbital object
	var/unique_id = ""
	//The tick of SSorbits when this was created
	var/created_at = 0
	//Mass of the object in solar masses
	var/mass = 0
	//Radius of the object in ~~parsecs~~ arbitary space units
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
	//Does the object actively thrust to maintain a stable orbit?
	var/maintain_orbit = FALSE
	//The object in which we are trying to maintain a stable orbit around.
	var/datum/orbital_object/target_orbital_body
	//Are we invisible on the map?
	var/stealth = FALSE
	//Multiplier for velocity
	var/velocity_multiplier = 1
	//Do we ignore gravity?
	var/ignore_gravity = FALSE

	//Delta time updates
	//Ship translations are smooth so must use a delta time
	//Dont get confused with subsystem delta_time as this accounts for time dilation
	var/last_update_tick = 0

	//CALCULATED IN INIT
	//Once objects are outside of this range, we will not apply gravity to them.
	var/relevant_gravity_range
	//Are we force-orbitting something?
	var/orbitting = FALSE
	//The relative velocity required for a stable orbit
	var/relative_velocity_required
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

	//Single instanced?
	//If things are singally instanced, they are only transmitted via ui_data with destroy and creation events.
	//Their position will never be updated.
	//This will cause huge inaccuracy if something has its velocity changed, so gravity must be ignored.
	//Even with no velocity changes it could be inaccurate anyway.
	//Used for non significant stuff like projectiles
	var/single_instanced = FALSE

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
	//Created at time
	created_at = SSorbits.times_fired
	//Calculate relevant grav range
	relevant_gravity_range = sqrt((mass * GRAVITATIONAL_CONSTANT) / MINIMUM_EFFECTIVE_GRAVITATIONAL_ACCEELRATION)
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
	LAZYREMOVE(target_orbital_body?.orbitting_bodies, src)
	if(length(orbitting_bodies))
		for(var/datum/orbital_object/orbitting_bodies in orbitting_bodies)
			orbitting_bodies.target_orbital_body = null
		orbitting_bodies.Cut()
	. = ..()

/datum/orbital_object/proc/explode()
	return

//Process orbital objects, calculate gravity
/datum/orbital_object/process()
	//Dont process updates for static objects.
	if(static_object)
		return PROCESS_KILL

	//NOTE TO SELF: This does nothing because world.time is in ticks not realtime.
	var/delta_time = 0
	if(last_update_tick)
		//Don't go too crazy.
		delta_time = CLAMP(world.time - last_update_tick, 10, 50) * 0.1
	else
		delta_time = 1
	last_update_tick = world.time

	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]

	//===================================
	// GRAVITATIONAL ATTRACTION
	//===================================
	//Gravity is not considered while we have just undocked and are at the center of a massive body.
	if(!collision_ignored && !ignore_gravity)
		//Find relevant gravitational bodies.
		var/list/gravitational_bodies =parent_map.get_relevnant_bodies(src)
		//Calculate acceleration vector
		var/datum/orbital_vector/acceleration_per_second = new()
		//Calculate gravity
		for(var/datum/orbital_object/gravitational_body as() in gravitational_bodies)
			//https://en.wikipedia.org/wiki/Gravitational_acceleration
			var/distance = position.DistanceTo(gravitational_body.position)
			if(!distance)
				continue
			var/acceleration_amount = (GRAVITATIONAL_CONSTANT * gravitational_body.mass) / (distance * distance)
			//Calculate acceleration direction
			var/datum/orbital_vector/direction = new (gravitational_body.position.x - position.x, gravitational_body.position.y - position.y)
			direction.NormalizeSelf()
			direction.ScaleSelf(acceleration_amount)
			//Add on the gravitational acceleration
			acceleration_per_second.AddSelf(direction)
		//Divide acceleration per second by the tick rate
		accelerate_towards(acceleration_per_second, delta_time)

	//===================================
	// ORBIT CORRECTION
	//===================================
	//Some objects may automatically thrust to maintain a stable orbit
	if(maintain_orbit && target_orbital_body)
		//Velocity should always be perpendicular to the planet
		var/datum/orbital_vector/perpendicular_vector = new(position.y - target_orbital_body.position.y, target_orbital_body.position.x - position.x)
		//Calculate the relative velocity we should have
		perpendicular_vector.NormalizeSelf()
		perpendicular_vector.ScaleSelf(relative_velocity_required)
		//Set it because we are a lazy shit
		velocity = perpendicular_vector.AddSelf(target_orbital_body.velocity)

	//===================================
	// MOVEMENT
	//===================================
	//Remember this
	var/prev_x = position.x
	var/prev_y = position.y

	//Move the gravitational body.
	var/datum/orbital_vector/vel_new = new(velocity.x * delta_time * velocity_multiplier, velocity.y * delta_time * velocity_multiplier)
	position.AddSelf(vel_new)

	//Oh we moved btw
	parent_map.on_body_move(src, prev_x, prev_y)

	//===================================
	// COLLISION CHECKING
	//===================================
	var/colliding = FALSE
	LAZYCLEARLIST(colliding_with)

	//Calculate our current position
	var/position_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE)],[round(position.y / ORBITAL_MAP_ZONE_SIZE)]"
	var/valid_side_key = "none"
	var/valid_front_key = "none"
	var/valid_corner_key = "none"

	var/dir_flags = NONE

	var/segment_x = position.x % ORBITAL_MAP_ZONE_SIZE
	var/segment_y = position.y % ORBITAL_MAP_ZONE_SIZE

	if(segment_x < ORBITAL_MAP_ZONE_SIZE / 3)
		valid_side_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE) - 1],[round(position.y / ORBITAL_MAP_ZONE_SIZE)]"
		dir_flags |= EAST
	else if(segment_x > 2 * (ORBITAL_MAP_ZONE_SIZE / 3))
		valid_side_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE) + 1],[round(position.y / ORBITAL_MAP_ZONE_SIZE)]"
		dir_flags |= WEST

	if(segment_y < ORBITAL_MAP_ZONE_SIZE / 3)
		valid_front_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE)],[round(position.y / ORBITAL_MAP_ZONE_SIZE) - 1]"
		dir_flags |= SOUTH
	else if(segment_y > 2 * (ORBITAL_MAP_ZONE_SIZE / 3))
		valid_front_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE)],[round(position.y / ORBITAL_MAP_ZONE_SIZE) + 1]"
		dir_flags |= NORTH

	//Check multiple zones
	if(dir_flags & EAST)
		if(dir_flags & NORTH)
			valid_corner_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE) + 1],[round(position.y / ORBITAL_MAP_ZONE_SIZE) + 1]"
		else if(dir_flags & SOUTH)
			valid_corner_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE) + 1],[round(position.y / ORBITAL_MAP_ZONE_SIZE) - 1]"
	else if(dir_flags & WEST)
		if(dir_flags & NORTH)
			valid_corner_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE) - 1],[round(position.y / ORBITAL_MAP_ZONE_SIZE) + 1]"
		else if(dir_flags & SOUTH)
			valid_corner_key = "[round(position.x / ORBITAL_MAP_ZONE_SIZE) - 1],[round(position.y / ORBITAL_MAP_ZONE_SIZE) - 1]"

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
		if(!(object.collision_type & collision_flags))
			continue
		//Vector collision.
		//Note: We detect collisions that occursed in the current move rather than in the next.
		//Position - Velocity -> Position
		//Detects collisions for when 2 objects pass each other.
		//Get the intersection point
		//Must be between 0 and 1
		var/other_x
		var/other_y
		var/other_delta_x = object.velocity.x * object.velocity_multiplier
		var/other_delta_y = object.velocity.y * object.velocity_multiplier
		if(object.last_update_tick == last_update_tick)
			//They are on the same tick as us
			other_x = object.position.x - other_delta_x
			other_y = object.position.y - other_delta_y
		else
			//They are still on the previous tick
			other_x = object.position.x
			other_y = object.position.y
		//Reassign variables for ease of read.
		var/px = prev_x
		var/py = prev_y
		var/vx = delta_x
		var/vy = delta_y
		var/px2 = other_x
		var/py2 = other_y
		var/vx2 = other_delta_x
		var/vy2 = other_delta_y
		if(!vx || !vx2 || vy * vx2 - vx * vy2 == 0 || py * vy2 - vx * vy2 == 0)
			//TODO Closest distance between a point and a vector
			var/distance = object.position.DistanceTo(position)
			if(distance < radius + object.radius)
				//Collision
				LAZYADD(colliding_with, object)
				collision(object)
				//Static objects dont check collisions, so call their collision proc for them.
				if(object.static_object)
					object.collision(src)
				colliding = TRUE
		else
			//Calculate mu and lambda independantly
			var/mu = (vx * py2 + vy * px - py * vx - vy * px2) / (vy * vx2 - vx * vy2)
			var/lambda = (py2 * vx2 + vy2 * px - px2 * vy2 - py * vx2) / (py * vy2 - vx * vy2)
			//Calculate lambda respecting clamped mu and mu respecting clamped lambda
			//Alright so now we have 2 scenarios
			//One of these values when plugged into the other should return a value between 0 and 1
			//Whatever one does that is correct. The other is wrong.
			var/restricted_mu = CLAMP01(mu)
			var/restricted_lambda = CLAMP01(lambda)
			var/lambda_2 = (px2 + vx2 * mu - px) / vx
			var/mu_2 = (px + vx * lambda - px2) / vx2
			var/correct_lambda
			var/correct_mu
			//Calculate the correct lambda and mu values
			if((restricted_mu == 1 || restricted_mu == 0) && (restricted_lambda == 1 || restricted_lambda == 0))
				correct_lambda = restricted_lambda
				correct_mu = restricted_mu
			else if(lambda_2 >= 0 && lambda_2 <= 1)
				correct_lambda = lambda_2
				correct_mu = restricted_mu
			else if(mu_2 >= 0 && mu_2 <= 1)
				correct_lambda = restricted_lambda
				correct_mu = mu_2
			else
				message_admins("Failed to calculate")
			//Calculate the closest distance
			var/ax = px + vx * correct_lambda
			var/ay = py + vy * correct_lambda
			var/bx = px2 + vx2 * correct_mu
			var/by = py2 + vy2 * correct_mu
			var/dx = bx - ax
			var/dy = by - ay
			if(sqrt(dx * dx + dy * dy) <= radius + object.radius)
				message_admins("[name] colided with [object.name]")
				//Collision
				LAZYADD(colliding_with, object)
				collision(object)
				//Static objects dont check collisions, so call their collision proc for them.
				if(object.static_object)
					object.collision(src)
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

/datum/orbital_object/proc/set_orbitting_around_body(datum/orbital_object/target_body, orbit_radius = 10, force = FALSE)
	if(orbitting && !force)
		return
	var/prev_x = position.x
	var/prev_y = position.y
	orbitting = TRUE
	//Calculates the required velocity for the object to orbit around the target body.
	//Hopefully the planets gravity doesn't fuck with each other too hard.
	//Set position
	var/delta_x = -position.x
	var/delta_y = -position.y
	position.x = target_body.position.x + orbit_radius
	position.y = target_body.position.y
	delta_x += position.x
	delta_y += position.y
	//Move all orbitting b()odies too.
	if(orbitting_bodies)
		for(var/datum/orbital_object/object in orbitting_bodies)
			object.position.AddSelf(new /datum/orbital_vector(delta_x, delta_y))
	//Set velocity
	var/relative_velocity = sqrt((GRAVITATIONAL_CONSTANT * (target_body.mass + mass)) / orbit_radius)
	velocity.x = target_body.velocity.x
	velocity.y = target_body.velocity.y + relative_velocity
	//Set random angle
	var/random_angle = rand(0, 360)	//Is cos and sin in radians?
	position.RotateSelf(random_angle)
	velocity.RotateSelf(random_angle)
	//Update target
	target_orbital_body = target_body
	LAZYADD(target_body.orbitting_bodies, src)
	relative_velocity_required = relative_velocity
	//We moved, make sure to update the map.
	var/datum/orbital_map/parent_map = SSorbits.orbital_maps[orbital_map_index]
	parent_map.on_body_move(src, prev_x, prev_y)

/datum/orbital_object/proc/post_map_setup()
	return

//Registers that something references this object, prevents potential hard dels
//Simple system, variable name must be constant
//This is super weird but helps prevent hard dels in an easier way that doesn't require
//repeating register signal code.
/datum/orbital_object/proc/RegisterReference(datum/source_object)
	source_object.RegisterSignal(src, COMSIG_PARENT_QDELETING, /datum/orbital_object.proc/UnregisterReference)
	source_object.vars[source_object["referencedOrbitalObjectVarName"]] = src

/datum/orbital_object/proc/UnregisterReference(datum/source_object)
	source_object.UnregisterSignal(src, COMSIG_PARENT_QDELETING)
	source_object.vars[source_object["referencedOrbitalObjectVarName"]] = null
