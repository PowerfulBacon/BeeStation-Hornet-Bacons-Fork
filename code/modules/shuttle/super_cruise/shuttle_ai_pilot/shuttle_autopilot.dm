/datum/shuttle_ai_pilot/autopilot
	var/activated = FALSE
	/// Target orbital body of the autopilot.
	var/datum/orbital_object/shuttleTarget
	/// The target dock of the autopilot. If set to null, the shuttle will not automatically enter a port.
	var/targetPortId

/datum/shuttle_ai_pilot/autopilot/New(datum/orbital_object/_shuttleTarget, _targetPortId)
	. = ..()
	shuttleTarget = _shuttleTarget
	targetPortId = _targetPortId

///Called every shuttle tick, handles the action of the shuttle
/datum/shuttle_ai_pilot/autopilot/handle_ai_flight_action(datum/orbital_object/shuttle/shuttle)
	if(!activated)
		return
	//Delete if our target goes out of range
	if (shuttleTarget.position.DistanceTo(shuttle.position) > max(shuttle_data.detection_range, shuttleTarget.signal_range))
		SEND_SIGNAL(shuttle, COMSIG_ORBITAL_BODY_MESSAGE, "Autopilot disabled, target has left detection range.")
		shuttleTarget = null
		qdel(src)
		return
	//Drive to the target location
	if(!shuttle.shuttleTargetPos)
		shuttle.shuttleTargetPos = new(shuttleTarget.position.GetX(), shuttleTarget.position.GetY())
	else
		shuttle.shuttleTargetPos.Set(shuttleTarget.position.GetX(), shuttleTarget.position.GetY())
	//Enter the target port
	if(shuttle.docking_target == shuttleTarget)
		//Dock if we can
		var/obj/docking_port/stationary/target_port = SSshuttle.getDock(targetPortId)
		if(target_port && shuttle.docking_target.z_in_contents(target_port.z))
			shuttle.goto_port(targetPortId)
		else if(target_port)
			//Otherwise undock and relocate target port ID
			shuttle.undock()
			//Locate new target
			if(targetPortId)
				shuttleTarget = locate_target_object_from_port(targetPortId)
		return
	//Dock with the target location
	if(shuttle.can_dock_with == shuttleTarget)
		shuttle.commence_docking(shuttleTarget, TRUE)

/datum/shuttle_ai_pilot/autopilot/proc/locate_target_object_from_port(port_id)
	var/obj/docking_port/stationary/target_port = SSshuttle.getDock(port_id)
	if(!target_port)
		return
	var/datum/space_level/space_level = SSmapping.get_level(target_port.z)
	if(!space_level)
		return
	return space_level.orbital_body

/datum/shuttle_ai_pilot/autopilot/proc/target_deleted(datum/source, force)
	shuttleTarget = null
	qdel(src)

/datum/shuttle_ai_pilot/autopilot/get_target_name()
	return shuttleTarget.name

/datum/shuttle_ai_pilot/autopilot/try_toggle()
	activated = !activated
	return TRUE

/datum/shuttle_ai_pilot/autopilot/is_active()
	return activated

/datum/shuttle_ai_pilot/autopilot/request
	activated = TRUE

/datum/shuttle_ai_pilot/autopilot/request/try_toggle()
	return FALSE
