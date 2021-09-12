/datum/orbital_object/projectile
	name = "Projectile"
	collision_type = COLLISION_PROJECTILE
	collision_flags = COLLISION_SHUTTLES | COLLISION_Z_LINKED | COLLISION_METEOR
	ignore_gravity = TRUE
	render_mode = RENDER_MODE_PROJECTILE
	//Projectiles are a signle instance to stop spamming UIs.
	single_instanced = TRUE
	//The speed of the projectile in arbitary space units per second.
	var/projectile_speed = 400
	//How long the projectile lasts for
	var/survival_time = 15 SECONDS
	//World time that the projectile will be deleted at
	var/kill_time

/datum/orbital_object/projectile/New(datum/orbital_vector/position, datum/orbital_vector/velocity, orbital_map_index)
	. = ..()
	//Calculate the world time we will be destroyed at
	kill_time = world.time + survival_time
	//Translate forward based on the time of our creation
	var/subticks = (world.time - SSorbits.last_fire) / ORBITAL_UPDATE_RATE
	var/datum/orbital_vector/scaled_velocity = velocity.Scale(subticks)
	MOVE_ORBITAL_BODY(src, position.x + scaled_velocity.x, position.y + scaled_velocity.y)

/datum/orbital_object/projectile/process()
	. = ..()
	//The time has come, delete the projectile.
	if(world.time > kill_time)
		qdel(src)

/datum/orbital_object/projectile/collision(datum/orbital_object/other)
	if(istype(other, /datum/orbital_object/meteor))
		qdel(other)
	qdel(src)
