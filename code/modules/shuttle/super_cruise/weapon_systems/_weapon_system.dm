/datum/weapon_system
	//Instanced
	var/weapon_id		//The ID of the weapon system
	var/ammo = 0		//Ammo remaining
	//Datum Values
	var/weapon_name		//Name of the weapon system
	var/weapon_enabled = TRUE	//Is the weapon system enabled?
	var/energy_ammunition	//Does the weapon system use energy based ammo? Recharge > Reload
	var/max_ammo		//Maximum ammo of the weapon system
	//Projectile type
	var/projectile_typepath = null	//Typepath of the projectile

/datum/weapon_system/New()
	. = ..()
	var/static/weapons_created = 0
	weapon_id = "w[weapons_created++]"

/datum/weapon_system/proc/toggle()
	return

/datum/weapon_system/proc/can_fire()
	return ammo

/datum/weapon_system/proc/fire(datum/orbital_object/source, target_x, target_y)
	if(!projectile_typepath)
		CRASH("Weapon system fired with no projectile typepath")
	//Calculate delta values.
	var/delta_x = target_x - source.position.x
	var/delta_y = target_y - source.position.y
	//Cast the typepath to a path to be used with initial()
	var/datum/orbital_object/projectile/projectile_path = projectile_typepath
	//Calculate the velocity
	var/datum/orbital_vector/velocity = new(delta_x, delta_y)
	velocity.Normalize()
	velocity.Scale(initial(projectile_path.projectile_speed))
	//Create the projectile
	new projectile_typepath(
		new /datum/orbital_vector(source.position.x, source.position.y),
		velocity,
		source.orbital_map_index
		)
	//Reduce ammo.
	ammo --
