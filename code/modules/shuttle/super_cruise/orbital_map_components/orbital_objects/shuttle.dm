/datum/orbital_object/shuttle
	name = "Shuttle"
	collision_type = COLLISION_SHUTTLES
	//Collision is handled by z-linked.
	collision_flags = NONE
	render_mode = RENDER_MODE_SHUTTLE
	priority = 10
	var/shuttle_port_id
	//Shuttle data
	var/max_thrust = 2
	//Controls
	var/thrust = 0
	var/angle = 0
	//Valid docking locations
	var/list/valid_docks = list()

	var/desired_vel_x = 0
	var/desired_vel_y = 0

	//They go faster
	velocity_multiplier = 3

	//The computer controlling us.
	var/controlling_computer = null

	var/datum/orbital_object/ils_beacon/ils_docking_target

	var/obj/docking_port/mobile/port

	//Semi-Autopilot controls
	var/datum/orbital_vector/shuttleTargetPos

	//AUTOPILOT CONTROLS.
	//Is autopilot enabled.
	//Determines if the autopilot should fly to the
	var/autopilot = FALSE
	//The target, speeds are calulated relative to this.
	var/datum/orbital_object/shuttleTarget
	//Cheating autopilots never fail
	var/cheating_autopilot = FALSE

	/// If the landing gear down?
	var/gear_down = GEAR_STATUS_UP

/datum/orbital_object/shuttle/stealth/infiltrator
	max_thrust = 2.5

/datum/orbital_object/shuttle/stealth/steel_rain
	max_thrust = 0
	//We never miss our mark
	cheating_autopilot = TRUE

/datum/orbital_object/shuttle/stealth
	stealth = TRUE

/datum/orbital_object/shuttle/Destroy()
	var/z_level = port?.z
	port = null
	valid_docks = null
	shuttleTarget = null
	. = ..()
	SSorbits.assoc_shuttles.Remove(shuttle_port_id)
	if(z_level)
		SSorbits.assoc_z_levels.Remove("[z_level]")

//Dont fly into the sun idiot.
/datum/orbital_object/shuttle/explode()
	if(port)
		port.jumpToNullSpace()
	qdel(src)

/datum/orbital_object/shuttle/process(delta_time)
	if(check_stuck())
		return
	//AUTOPILOT
	handle_autopilot()
	//Do thrust
	var/thrust_amount = thrust * max_thrust / 100
	var/thrust_x = cos(angle) * thrust_amount
	var/thrust_y = sin(angle) * thrust_amount
	accelerate_towards(new /datum/orbital_vector(thrust_x, thrust_y), ORBITAL_UPDATE_RATE_SECONDS * delta_time)
	//Do gravity and movement
	. = ..()

/datum/orbital_object/shuttle/proc/check_stuck()
	if(!port)
		return FALSE
	if(!is_reserved_level(port.z) && port.mode == SHUTTLE_IDLE)
		message_admins("Shuttle [shuttle_port_id] is not on a reserved Z-Level but is somehow registered as in flight! Automatically fixing...")
		log_runtime("Shuttle [shuttle_port_id] is not on a reserved Z-Level but is somehow registered as in flight! Removing shuttle object.")
		qdel(src)
		return TRUE
	return FALSE

/datum/orbital_object/shuttle/proc/handle_autopilot()
	var/datum/orbital_vector/target_pos = shuttleTargetPos

	if(autopilot)
		target_pos = shuttleTarget.position

	if(!target_pos)
		return

	//Relative velocity to target needs to point towards target.
	var/distance_to_target = position.DistanceTo(target_pos)

	//Cheat and slow down.
	//Remove this if you make better autopilot logic ever.
	if(distance_to_target < 100 && velocity.Length() > 25)
		velocity.NormalizeSelf()
		velocity.ScaleSelf(20)

	//If there is an object in the way, we need to fly around it.
	var/datum/orbital_vector/next_position = target_pos

	//Adjust our speed to target to point towards it.
	var/datum/orbital_vector/desired_velocity = new(next_position.x - position.x, next_position.y - position.y)
	var/desired_speed = distance_to_target * 0.02 + 10
	desired_velocity.NormalizeSelf()
	desired_velocity.ScaleSelf(desired_speed)

	//Adjust thrust to make our velocity = desired_velocity
	var/thrust_dir_x = desired_velocity.x - velocity.x
	var/thrust_dir_y = desired_velocity.y - velocity.y

	desired_vel_x = desired_velocity.x
	desired_vel_y = desired_velocity.y

	//message_admins("Thrusting in dir: [thrust_dir_y], [thrust_dir_x]")
	//message_admins("Next pos: [next_position.x], [next_position.y]")

	if(!thrust_dir_x)
		if(!thrust_dir_y)
			thrust = 0
			return
		angle = thrust_dir_y > 0 ? 90 : -90
	else
		angle = arctan(thrust_dir_y / thrust_dir_x)
		//Account for ambiguous cases
		if(thrust_dir_x < 0)
			if(thrust_dir_y > 0)
				angle = -180 + angle
			else
				angle = 180 + angle

	//message_admins("Angle: [angle]")

	//FULL SPEED
	thrust = 100
	//Auto dock
	if(shuttleTarget && ils_docking_target == shuttleTarget)
		commence_docking(ils_docking_target)

	//Fuck all that, we cheat anyway
	if(cheating_autopilot)
		velocity.x = desired_vel_x
		velocity.y = desired_vel_y

/datum/orbital_object/shuttle/proc/link_shuttle(obj/docking_port/mobile/dock)
	name = dock.name
	shuttle_port_id = dock.id
	port = dock
	stealth = dock.hidden
	SSorbits.assoc_shuttles[shuttle_port_id] = src
	SSorbits.assoc_z_levels["[dock.virtual_z]"] = src

/datum/orbital_object/shuttle/proc/gear_down()
	if (gear_down != GEAR_STATUS_UP)
		return FALSE
	gear_down = GEAR_STATUS_MOVING
	addtimer(VARSET_CALLBACK(src, gear_down, GEAR_STATUS_DEPLOYED), GEAR_DEPLOY_SPEED)
	play_sound('sound/machines/landing_gear.ogg', 'sound/machines/landing_gear_external.ogg')
	return TRUE

/datum/orbital_object/shuttle/proc/gear_up()
	if (gear_down != GEAR_STATUS_DEPLOYED)
		return FALSE
	gear_down = GEAR_STATUS_MOVING
	addtimer(VARSET_CALLBACK(src, gear_down, GEAR_STATUS_UP), GEAR_DEPLOY_SPEED)
	play_sound('sound/machines/landing_gear.ogg', 'sound/machines/landing_gear_external.ogg')

/datum/orbital_object/shuttle/proc/play_sound(sound_internal, sound_external)
	port.play_shuttle_sound(sound_internal, sound_external)

/// Returns either null or an error message
/datum/orbital_object/shuttle/proc/commence_docking(datum/orbital_object/ils_beacon/beacon)
	if(QDELETED(beacon))
		return "Docking target lost, please re-establish orbital trajectory."
	//Get our port
	if(!port || port.destination != null)
		return "Could not locate shuttle."
	//Check ready
	if(port.mode == SHUTTLE_RECHARGING)
		return "Supercruise Warning: Shuttle engines not ready for use."
	if(port.mode != SHUTTLE_CALL || port.destination)
		return "Supercruise Warning: Already dethrottling shuttle."
	//Find the target port
	var/obj/docking_port/stationary/target_port = beacon.port
	if(!target_port)
		return "Could not locate docking zone on the ILS beacon."
	switch(SSshuttle.moveShuttle(port.id, target_port.id, 1))
		if(0)
			QDEL_NULL(src)
			port.setTimer(20)
		if(1)
			return "Invalid shuttle requested."
		else
			return "Unable to comply."
