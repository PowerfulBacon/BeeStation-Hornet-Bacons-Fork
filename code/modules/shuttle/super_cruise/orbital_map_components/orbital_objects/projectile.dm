/datum/orbital_object/projectile
	name = "Projectile"
	collision_type = COLLISION_PROJECTILE
	collision_flags = COLLISION_SHUTTLES | COLLISION_Z_LINKED
	ignore_gravity = TRUE
	//Projectiles are a signle instance to stop spamming UIs.
	single_instanced = TRUE
	//The speed of the projectile in arbitary space units per second.
	var/projectile_speed = 400
