/datum/weapon_system
	//Instanced
	var/weapon_id		//The ID of the weapon system
	var/ammo = 0		//Ammo remaining
	var/next_shot = 0
	//Datum Values
	var/weapon_name		//Name of the weapon system
	var/weapon_enabled = TRUE	//Is the weapon system enabled?
	var/energy_ammunition	//Does the weapon system use energy based ammo? Recharge > Reload
	var/max_ammo		//Maximum ammo of the weapon system
	var/cooldown = 5 SECONDS
	var/shots = 5
	var/shot_cooldown = 4
	//Inaccuracy in degress
	var/innacuracy = 1
	//Projectile type
	var/projectile_typepath = null	//Typepath of the projectile

/datum/weapon_system/New()
	. = ..()
	var/static/weapons_created = 0
	weapon_id = "w[weapons_created++]"

/datum/weapon_system/proc/toggle()
	return

/datum/weapon_system/proc/can_fire()
	if(world.time < next_shot)
		return FALSE
	return ammo

/datum/weapon_system/proc/fire(datum/orbital_object/source, target_x, target_y)
	//If we can fire again, fire again
	INVOKE_ASYNC(src, .proc/_fire, source, target_x, target_y)

/datum/weapon_system/proc/_fire(datum/orbital_object/source, target_x, target_y)
	next_shot = world.time + cooldown + shot_cooldown * shots
	for(var/i in 1 to shots)
		if(!projectile_typepath)
			CRASH("Weapon system fired with no projectile typepath")
		//Calculate delta values.
		var/delta_x = target_x - source.position.x
		var/delta_y = target_y - source.position.y
		//Cast the typepath to a path to be used with initial()
		var/datum/orbital_object/projectile/projectile_path = projectile_typepath
		//Calculate the velocity
		var/datum/orbital_vector/velocity = new(delta_x, delta_y)
		velocity.NormalizeSelf()
		velocity.RotateSelf(rand(-10000, 10000) * innacuracy * 0.0001)
		velocity.ScaleSelf(initial(projectile_path.projectile_speed))
		//Create the projectile
		new projectile_typepath(
			new /datum/orbital_vector(source.position.x, source.position.y),
			velocity,
			source.orbital_map_index
			)
		//Reduce ammo.
		ammo --
		//Sleep until the shot cooldown is finished
		sleep(shot_cooldown)
