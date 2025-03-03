GLOBAL_VAR_INIT(shuttle_docking_jammed, FALSE)

/obj/machinery/computer/shuttle_flight
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list()
	use_power = NO_POWER_USE
	var/shuttleId

	//For recall consoles
	//If not set to an empty string, will display only the option to call the shuttle to that dock.
	//Once pressed the shuttle will engage autopilot and return to the dock.
	// TODO: REPLACE THIS WITH ITS OWN THING
	var/recall_docking_port_id = ""

	var/request_shuttle_message = "Request Shuttle"

	//Admin controlled shuttles
	var/admin_controlled = FALSE

	//Used for mapping mainly
	var/possible_destinations = ""
	var/list/valid_docks = list("")

	//The current orbital map we are observing
	var/orbital_map_index = PRIMARY_ORBITAL_MAP

	//Our orbital body.
	var/datum/orbital_object/shuttle/shuttleObject

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/computer/shuttle_flight)

/obj/machinery/computer/shuttle_flight/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	valid_docks = params2list(possible_destinations)
	if(shuttleId)
		shuttlePortId = "[shuttleId]_custom"
	else
		var/static/i = 0
		shuttlePortId = "unlinked_shuttle_console_[i++]"

/obj/machinery/computer/shuttle_flight/Destroy()
	. = ..()
	SSorbits.open_orbital_maps -= SStgui.get_all_open_uis(src)
	shuttleObject = null
	//De-link the port
	if(my_port)
		my_port.delete_after = TRUE
		my_port.id = null
		my_port.name = "Old [my_port.name]"
		my_port = null

/obj/machinery/computer/shuttle_flight/examine(mob/user)
	. = ..()
	var/obj/item/circuitboard/computer/shuttle/circuit_board = circuit
	if(istype(circuit_board))
		if(circuit_board.hacked)
			. += "It's access requirements have been disabled."
		else
			. += "It's access requirements could be disabled by disassembling the computer and using a multitool on the circuitboard."

/obj/machinery/computer/shuttle_flight/process()
	. = ..()
	//Check to see if the shuttleObject was launched by another console.
	if(QDELETED(shuttleObject) && SSorbits.assoc_shuttles.Find(shuttleId))
		shuttleObject = SSorbits.assoc_shuttles[shuttleId]

/obj/machinery/computer/shuttle_flight/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/shuttle_flight/ui_interact(mob/user, datum/tgui/ui)
	//Ash walkers cannot use the console because they are unga bungas
	if(user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, span_warning("This computer has been designed to keep the natives like you from meddling with it, you have no hope of using it."))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrbitalMap")
		ui.open()
	SSorbits.open_orbital_maps |= ui
	ui.set_autoupdate(FALSE)

/obj/machinery/computer/shuttle_flight/ui_close(mob/user, datum/tgui/tgui)
	SSorbits.open_orbital_maps -= tgui

/obj/machinery/computer/shuttle_flight/ui_static_data(mob/user)
	var/list/data = list()
	//The docks we can dock with never really changes
	//This is used for the forced autopilot mode where it goes to a set port.
	data["destination_docks"] = list()
	for(var/dock in valid_docks)
		data["valid_dock"] += list(list(
			"id" = dock,
		))
	//If we are a recall console.
	data["recall_docking_port_id"] = recall_docking_port_id
	data["request_shuttle_message"] = request_shuttle_message
	return data

/obj/machinery/computer/shuttle_flight/ui_data(mob/user)
	//Fetch data
	var/user_ref = "[REF(user)]"

	//Get the base map data
	var/list/data = SSorbits.get_orbital_map_base_data(
		SSorbits.orbital_maps[orbital_map_index],
		user_ref,
		FALSE,
		shuttleObject
	)

	//Send shuttle data
	if(!SSshuttle.getShuttle(shuttleId))
		data["linkedToShuttle"] = FALSE
		return data
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttleId)
	var/area/shuttle/first_area = mobile_port.shuttle_areas[1]
	data["canLaunch"] = TRUE
	data["powered"] = first_area.powered()
	if(QDELETED(shuttleObject))
		data["linkedToShuttle"] = FALSE
		return data
	data["autopilot"] = shuttleObject.autopilot
	data["linkedToShuttle"] = TRUE
	data["shuttleTarget"] = shuttleObject.shuttleTarget?.name
	data["shuttleName"] = shuttleObject.name
	data["shuttleAngle"] = shuttleObject.angle
	data["shuttleThrust"] = shuttleObject.thrust
	data["autopilot_enabled"] = shuttleObject.autopilot
	if(shuttleObject?.shuttleTarget)
		data["shuttleVelX"] = shuttleObject.velocity.x - shuttleObject.shuttleTarget.velocity.x
		data["shuttleVelY"] = shuttleObject.velocity.y - shuttleObject.shuttleTarget.velocity.y
	else
		data["shuttleVelX"] = shuttleObject.velocity.x
		data["shuttleVelY"] = shuttleObject.velocity.y
	data["pitch"] = shuttleObject.pitch
	//Docking data
	data["canDock"] = shuttleObject.ils_docking_target != null
	data["isInOrbit"] = shuttleObject.is_in_orbit
	data["landingGear"] = shuttleObject.gear_down
	data["shuttleTargetX"] = shuttleObject.shuttleTargetPos?.x
	data["shuttleTargetY"] = shuttleObject.shuttleTargetPos?.y
	data["validDockingPorts"] = list()
	data["orbitState"] = shuttleObject.is_in_orbit
	// Station docking
	if (shuttleObject.is_in_orbit == ORBITAL_STATUS_ORBIT)
		//Stealth shuttles bypass shuttle jamming.
		if(!GLOB.shuttle_docking_jammed || shuttleObject.stealth)
			data["validDockingPorts"] += list(list(
				"name" = "Custom Location",
				"id" = "custom_location"
			))
		for(var/obj/docking_port/stationary/stationary_port as() in SSshuttle.stationary)
			var/datum/space_level/level = SSmapping.get_level(stationary_port.z)
			if (!level.traits[ZTRAIT_ORBIT])
				continue
			if(stationary_port.id in valid_docks)
				data["validDockingPorts"] += list(list(
					"name" = stationary_port.name,
					"id" = stationary_port.id,
				))
	return data

/obj/machinery/computer/shuttle_flight/ui_act(action, params)
	. = ..()

	if(.)
		return

	if(admin_controlled)
		say("This shuttle is restricted to authorised personnel only.")
		return
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttleId)
	var/area/shuttle/first_area = mobile_port.shuttle_areas[1]
	if (!first_area)
		return

	switch(action)
		if ("toggleAPU")
			// Can be used without power, turn the APU on or off
			if(!mobile_port || mobile_port.destination != null)
				return
			var/apu_on = !first_area.always_unpowered
			for (var/area/shuttle/shuttle_area in mobile_port.shuttle_areas)
				if (apu_on)
					shuttle_area.disable_apu()
				else
					shuttle_area.enable_apu()
		if ("setTarget")
			// If you have no power, you can't do this
			if (!first_area.powered())
				return
			if(QDELETED(shuttleObject))
				say("Shuttle not in flight.")
				return
			var/desiredTarget = params["target"]
			if(shuttleObject.name == desiredTarget)
				return
			var/datum/orbital_map/showing_map = SSorbits.orbital_maps[orbital_map_index]
			for(var/map_key in showing_map.collision_zone_bodies)
				for(var/datum/orbital_object/object as() in showing_map.collision_zone_bodies[map_key])
					if(object.name == desiredTarget)
						shuttleObject.shuttleTarget = object
						return
		if("setThrust")
			// If you have no power, you can't do this
			if (!first_area.powered())
				return
			if(QDELETED(shuttleObject))
				say("Shuttle not in flight.")
				return
			if(shuttleObject.autopilot)
				to_chat(usr, span_warning("Shuttle is controlled by autopilot."))
				return
			shuttleObject.thrust = clamp(params["thrust"], 0, 100)
		if("setAngle")
			// If you have no power, you can't do this
			if (!first_area.powered())
				return
			if(QDELETED(shuttleObject))
				say("Shuttle not in flight.")
				return
			if(shuttleObject.autopilot)
				to_chat(usr, span_warning("Shuttle is controlled by autopilot."))
				return
			shuttleObject.angle = params["angle"]
		if("nautopilot")
			// If you have no power, you can't do this
			if (!first_area.powered())
				return
			if(QDELETED(shuttleObject) || !shuttleObject.shuttleTarget)
				return
			shuttleObject.autopilot = !shuttleObject.autopilot
			shuttleObject.shuttleTargetPos = null
		//Launch the shuttle. Lets do this.
		if("launch")
			// If you have no power, you can't do this
			if (!first_area.powered())
				return
			launch_shuttle()
		if("setTargetCoords")
			// If you have no power, you can't do this
			if (!first_area.powered())
				return
			if(QDELETED(shuttleObject))
				return
			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			if(!shuttleObject.shuttleTargetPos)
				shuttleObject.shuttleTargetPos = new(x, y)
			else
				shuttleObject.shuttleTargetPos.x = x
				shuttleObject.shuttleTargetPos.y = y
			shuttleObject.autopilot = FALSE
			. = TRUE
		if ("toggleGear")
			// If you have no power, you can't do this
			if (!first_area.powered())
				return
			if(QDELETED(shuttleObject))
				return
			if (shuttleObject.gear_down == GEAR_STATUS_UP)
				shuttleObject.gear_down()
			else
				shuttleObject.gear_up()
			. = TRUE
		// Dock via ILS
		if ("dockILS")
			// If you have no power, you can't do this
			if (!first_area.powered())
				return
			if(QDELETED(shuttleObject))
				say("Shuttle has already landed, cannot dock at this time.")
				return
			if(QDELETED(shuttleObject.ils_docking_target))
				say("Docking target lost, please re-establish orbital trajectory.")
				return
			//Get our port
			if(!mobile_port || mobile_port.destination != null)
				return
			//Check ready
			if(mobile_port.mode == SHUTTLE_RECHARGING)
				say("Supercruise Warning: Shuttle engines not ready for use.")
				return
			if(mobile_port.mode != SHUTTLE_CALL || mobile_port.destination)
				say("Supercruise Warning: Already dethrottling shuttle.")
				return
			//Find the target port
			var/obj/docking_port/stationary/target_port = shuttleObject.ils_docking_target.port
			if(!target_port)
				return
			switch(SSshuttle.moveShuttle(shuttleId, target_port.id, 1))
				if(0)
					say("Initiating ILS approach...")
					if(current_user)
						remove_eye_control(current_user)
					QDEL_NULL(shuttleObject)
					mobile_port.setTimer(20)
				if(1)
					to_chat(usr, span_warning("Invalid shuttle requested."))
				else
					to_chat(usr, span_notice("Unable to comply."))

/obj/machinery/computer/shuttle_flight/proc/launch_shuttle()
	if(SSorbits.interdicted_shuttles.Find(shuttleId))
		if(world.time < SSorbits.interdicted_shuttles[shuttleId])
			var/time_left = (SSorbits.interdicted_shuttles[shuttleId] - world.time) * 0.1
			say("Supercruise Warning: Engines have been interdicted and will be recharged in [time_left] seconds.")
			return
	var/obj/docking_port/mobile/mobile_port = SSshuttle.getShuttle(shuttleId)
	if(!mobile_port)
		return
	if(!mobile_port.canMove())
		say("Supercruise Warning: The shuttle's movement is being inhibited.")
		return
	if(mobile_port.mode == SHUTTLE_RECHARGING)
		say("Supercruise Warning: Shuttle engines not ready for use.")
		return
	if(mobile_port.mode != SHUTTLE_IDLE)
		say("Supercruise Warning: Shuttle already in transit.")
		return
	if(SSorbits.assoc_shuttles.Find(shuttleId))
		say("Shuttle is controlled from another location, updating telemetry.")
		shuttleObject = SSorbits.assoc_shuttles[shuttleId]
		return shuttleObject
	shuttleObject = mobile_port.enter_supercruise()
	if(!shuttleObject)
		say("Failed to enter supercruise due to an unknown error.")
		return
	shuttleObject.valid_docks = valid_docks
	return shuttleObject

/obj/machinery/computer/shuttle_flight/on_emag(mob/user)
	..()
	req_access = list()
	to_chat(user, span_notice("You fried the consoles ID checking system."))

/obj/machinery/computer/shuttle_flight/allowed(mob/M)
	var/obj/item/circuitboard/computer/shuttle/circuit_board = circuit
	if(istype(circuit_board) && circuit_board.hacked)
		return TRUE
	return ..()
