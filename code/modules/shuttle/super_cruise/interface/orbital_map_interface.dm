/datum/orbital_map_tgui
	var/list/assoc_data = list()
	var/default_orbital_map = PRIMARY_ORBITAL_MAP

/datum/orbital_map_tgui/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbital_map_tgui/Destroy(force, ...)
	. = ..()
	SSorbits.open_orbital_maps -= SStgui.get_all_open_uis(src)

/datum/orbital_map_tgui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		//Store user specific data.
		assoc_data["[REF(user)]"] = list(
			"open_map" = default_orbital_map,
			"active_single_instances" = list(),
		)
		ui = new(user, src, "OrbitalMap")
		ui.open()
	//Do not auto update, handled by orbits subsystem.
	SSorbits.open_orbital_maps |= ui
	ui.set_autoupdate(FALSE)

/datum/orbital_map_tgui/ui_close(mob/user, datum/tgui/tgui)
	SSorbits.open_orbital_maps -= tgui
	//Clear the data from the user, we don't need it anymore.
	assoc_data -= "[REF(user)]"

/datum/orbital_map_tgui/ui_data(mob/user)
	var/list/data = list()
	data["update_index"] = SSorbits.times_fired
	data["map_objects"] = list()
	data["created_objects"] = list()
	data["destroyed_objects"] = list()
	//Fetch the user data
	var/open_orbital_map = default_orbital_map
	var/user_ref = "[REF(user)]"
	if(assoc_data[user_ref])
		open_orbital_map = assoc_data[user_ref]["open_map"]
	else
		log_runtime("Orbital map updated UI without reference to [user] in the assoc data list.")
		assoc_data[user_ref] = list(
			"open_map" = default_orbital_map,
			"active_single_instances" = list(),
		)
	//Fetch the active single instances
	var/list/active_single_instances = assoc_data[user_ref]["active_single_instances"]
	var/list/alive_single_instances = list()
	//Show the correct map to the user
	var/datum/orbital_map/showing_map = SSorbits.orbital_maps[open_orbital_map]
	for(var/zone in showing_map.collision_zone_bodies)
		for(var/datum/orbital_object/object as() in showing_map.collision_zone_bodies[zone])
			//Only transmit when necessary
			if(object.single_instanced)
				//If the instance wasn't active before, activate it
				if(!active_single_instances[object.unique_id])
					data["created_objects"] += list(list(
						"id" = object.unique_id,
						"name" = object.name,
						"position_x" = object.position.x,
						"position_y" = object.position.y,
						"velocity_x" = object.velocity.x,
						"velocity_y" = object.velocity.y,
						"radius" = object.radius,
						"created_at" = object.created_at,
						"render_mode" = object.render_mode,
					))
					//Set the instance to be active in the user data list
					active_single_instances[object.unique_id] = TRUE
				//The instance is alive
				alive_single_instances[object.unique_id] = TRUE
				continue
			//Transmit map data about non single-instanced objects.
			data["map_objects"] += list(list(
				"id" = object.unique_id,
				"name" = object.name,
				"position_x" = object.position.x,
				"position_y" = object.position.y,
				"velocity_x" = object.velocity.x,
				"velocity_y" = object.velocity.y,
				"radius" = object.radius,
				"render_mode" = object.render_mode,
			))
	//Calculate destroyed single instances
	for(var/unique_id in active_single_instances)
		//If the instance is still alive, continue
		if(alive_single_instances[unique_id])
			continue
		//Destroy instances that are active but not alive.
		data["destroyed_objects"] += unique_id
		//Deactivate the instance in the tracking list.
		active_single_instances -= unique_id
	//Save data about single instances.
	assoc_data[user_ref]["active_single_instances"] = active_single_instances
	return data
