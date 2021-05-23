/datum/orbital_object
	var/name = "undefined"
	//Mass of the object in solar masses
	var/mass = 0
	//Radius of the object in parsecs
	var/radius = 1
	//Position of the object (0,0) is the center of the map.
	//Position is in kilometers
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

/datum/orbital_object/New()
	. = ..()
	//Calculate relevant grav range
	relevant_gravity_range = sqrt((mass * GRAVITATIONAL_CONSTANT) / MINIMUM_EFFECTIVE_GRAVITATIONAL_ACCEELRATION)
	//Process this
	if(!static_object)
		START_PROCESSING(SSorbits, src)
	//Add to orbital map
	SSorbits.orbital_map?.bodies += src

/datum/orbital_object/Destroy()
	STOP_PROCESSING(SSorbits, src)
	SSorbits.orbital_map.bodies -= src
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

	//===================================
	// GRAVITATIONAL ATTRACTION
	//===================================
	//Find relevant gravitational bodies.
	var/list/gravitational_bodies = SSorbits.orbital_map.get_relevnant_bodies(src)
	//Calculate acceleration vector
	var/datum/orbital_vector/acceleration_per_second = new()
	//Calculate gravity
	for(var/datum/orbital_object/gravitational_body as() in gravitational_bodies)
		//https://en.wikipedia.org/wiki/Gravitational_acceleration
		var/distance = position.Distance(gravitational_body.position)
		if(!distance)
			continue
		var/acceleration_amount = (GRAVITATIONAL_CONSTANT * gravitational_body.mass) / (distance * distance)
		//Calculate acceleration direction
		var/datum/orbital_vector/direction = new (gravitational_body.position.x - position.x, gravitational_body.position.y - position.y)
		direction.Normalize()
		direction.Scale(acceleration_amount)
		//Add on the gravitational acceleration
		acceleration_per_second.Add(direction)
	//Divide acceleration per second by the tick rate
	accelerate_towards(acceleration_per_second, ORBITAL_UPDATE_RATE_SECONDS)

	//===================================
	// ORBIT CORRECTION
	//===================================
	//Some objects may automatically thrust to maintain a stable orbit
	if(maintain_orbit)
		//Velocity should always be perpendicular to the planet
		var/datum/orbital_vector/perpendicular_vector = new(position.y - target_orbital_body.position.y, target_orbital_body.position.x - position.x)
		//Calculate the relative velocity we should have
		perpendicular_vector.Normalize()
		perpendicular_vector.Scale(relative_velocity_required)
		//Set it because we are a lazy shit
		velocity = perpendicular_vector.Add(target_orbital_body.velocity)

	//===================================
	// MOVEMENT
	//===================================
	//Move the gravitational body.
	position.Add(velocity.Scale(ORBITAL_UPDATE_RATE_SECONDS))

	//===================================
	// COLLISION CHECKING
	//===================================
	var/colliding = FALSE
	LAZYCLEARLIST(colliding_with)
	for(var/datum/orbital_object/object in SSorbits.orbital_map.bodies)
		var/distance = object.position.Distance(position)
		if(distance < radius + object.radius)
			//Collision
			LAZYADD(colliding_with, object)
			collision(object)
			colliding = TRUE
	if(!colliding)
		collision_ignored = FALSE

//We do a little suvatting
/datum/orbital_object/proc/accelerate_towards(datum/orbital_vector/acceleration_vector, time)
	velocity.Add(acceleration_vector.Scale(time))

//Called when we collide with another orbital object.
//Make sure to check if(other.collision_ignored || collision_ignored)
/datum/orbital_object/proc/collision(datum/orbital_object/other)
	return

/datum/orbital_object/proc/set_orbitting_around_body(datum/orbital_object/target_body, orbit_radius = 10, force = FALSE)
	if(orbitting && !force)
		return
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
	//Move all orbitting bodies too.
	if(orbitting_bodies)
		for(var/datum/orbital_object/object in orbitting_bodies)
			object.position.Add(new /datum/orbital_vector(delta_x, delta_y))
	//Set velocity
	var/relative_velocity = sqrt((GRAVITATIONAL_CONSTANT * (target_body.mass + mass)) / orbit_radius)
	velocity.x = target_body.velocity.x
	velocity.y = target_body.velocity.y + relative_velocity
	//Set random angle
	/*var/random_angle = rand(0, 360)	//Is cos and sin in radians?
	position.Rotate(random_angle)
	velocity.Rotate(random_angle)*/
	//Update target
	target_orbital_body = target_body
	LAZYADD(target_body.orbitting_bodies, src)
	relative_velocity_required = relative_velocity

/datum/orbital_object/proc/post_map_setup()
	return
