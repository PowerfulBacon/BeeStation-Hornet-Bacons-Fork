//BACONTODO
//This could really use inheritance with a base map type
//If you are spamming the UI or something it doesn't accept data.

/obj/machinery/computer/weapons
	name = "weapons console"
	desc = "A high-tech computer console that interfaces with shuttle-based weapon systems."
	icon_screen = "shuttle"
	icon_keyboard = "security_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list()
	//Port ID of the shuttle
	var/shuttleId
	//Alternatively the orbital object attached to
	var/datum/orbital_object/attached_orbital_object
	//Current orbital map that's being observed
	var/orbital_map_index = PRIMARY_ORBITAL_MAP
	//Attached weapon systems
	var/list/attached_weapon_systems = list()
	//Selected weapon
	var/selected_weapon_id = ""
	//Assoc data
	var/list/assoc_data = list()

/obj/machinery/computer/weapons/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	//Get the station
	//TODO DEBUG:
	attached_orbital_object = SSorbits.station_instance
	var/datum/weapon_system/WS = new /datum/weapon_system/debug
	//TODO ENDDEBUG
	attached_weapon_systems[WS.weapon_id] = WS
	//Unlike the attached object when its destroyed.
	if(attached_orbital_object)
		RegisterSignal(attached_orbital_object, COMSIG_PARENT_QDELETING, .proc/unlink)

//Remove the UIs from the SSorbit TGUI update list.
/obj/machinery/computer/weapons/Destroy()
	if(attached_orbital_object)
		UnregisterSignal(attached_orbital_object, COMSIG_PARENT_QDELETING)
	SSorbits.open_orbital_maps -= SStgui.get_all_open_uis(src)
	. = ..()

/obj/machinery/computer/weapons/proc/link_to_body(datum/orbital_object/body)
	if(attached_orbital_object)
		unlink(attached_orbital_object)
	RegisterSignal(body, COMSIG_PARENT_QDELETING)
	attached_orbital_object = body

/obj/machinery/computer/weapons/proc/unlink(datum/source)
	SIGNAL_HANDLER
	attached_orbital_object = null
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

//UI stuff

/obj/machinery/computer/weapons/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/weapons/ui_interact(mob/user, datum/tgui/ui)
	if(!allowed(user) && !isobserver(user))
		say("Insufficient access rights.")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		//Store user specific data.
		assoc_data["[REF(user)]"] = list(
			"active_single_instances" = list(),
		)
		ui = new(user, src, "OrbitalWeaponMap")
		ui.open()
	SSorbits.open_orbital_maps |= ui
	ui.set_autoupdate(FALSE)

/obj/machinery/computer/weapons/ui_close(mob/user, datum/tgui/tgui)
	SSorbits.open_orbital_maps -= tgui
	//Clear the data from the user, we don't need it anymore.
	assoc_data -= "[REF(user)]"

/obj/machinery/computer/weapons/ui_static_data(mob/user)
	var/list/data = list()
	data["interdiction_range"] = 0
	//Add the weapon systems
	data["weapon_systems"] = list()
	for(var/weapon_id in attached_weapon_systems)
		var/datum/weapon_system/weapon = attached_weapon_systems[weapon_id]
		data["weapon_systems"] += list(list(
			"weaponId" = weapon.weapon_id,
			"weaponName" = weapon.weapon_name,
			"ammo" = weapon.ammo,
			"maxAmmo" = weapon.max_ammo,
			"weaponEnabled" = weapon.weapon_enabled,
			"energyAmmunition" = weapon.energy_ammunition,
			"weaponSelected" = selected_weapon_id == weapon.weapon_id,
		))
	return data

/obj/machinery/computer/weapons/ui_data(mob/user)
	//Fetch data
	var/user_ref = "[REF(user)]"
	if(!assoc_data[user_ref])
		log_runtime("Orbital map updated UI without reference to [user] in the assoc data list.")
		assoc_data[user_ref] = list(
			"active_single_instances" = list(),
		)

	//Get the base map data
	var/list/data = SSorbits.get_orbital_map_base_data(
		SSorbits.orbital_maps[orbital_map_index],
		assoc_data,
		user_ref,
		FALSE,
		attached_orbital_object
	)

	//Send data about the weapons
	if(!SSshuttle.getShuttle(shuttleId))
		data["linkedToShuttle"] = FALSE
		return data
	//Interdicted shuttles
	data["interdictedShuttles"] = list()
	if(SSorbits.interdicted_shuttles[shuttleId] > world.time)
		var/obj/docking_port/our_port = SSshuttle.getShuttle(shuttleId)
		data["interdictionTime"] = SSorbits.interdicted_shuttles[shuttleId] - world.time
		for(var/interdicted_id in SSorbits.interdicted_shuttles)
			var/timer = SSorbits.interdicted_shuttles[interdicted_id]
			if(timer < world.time)
				continue
			var/obj/docking_port/port = SSshuttle.getShuttle(interdicted_id)
			if(port && port.get_virtual_z_level() == our_port.get_virtual_z_level())
				data["interdictedShuttles"] += list(list(
					"shuttleName" = port.name,
					"x" = port.x - our_port.x,
					"y" = port.y - our_port.y,
				))
	else
		data["interdictionTime"] = 0
	if(QDELETED(attached_orbital_object))
		data["linkedToShuttle"] = FALSE
		return data
	data["linkedToShuttle"] = TRUE
	data["shuttleName"] = attached_orbital_object.name
	return data

/obj/machinery/computer/weapons/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!allowed(usr))
		say("Insufficient access rights.")
		return

	switch(action)
		if("toggle_weapon")
			var/weapon_id = params["weapon_id"]
			if(attached_weapon_systems[weapon_id])
				var/datum/weapon_system/weapon = attached_weapon_systems[weapon_id]
				weapon.toggle()
			else
				say("Invalid weapon system toggled.")
		if("selectWeapon")
			var/weapon_id = params["weapon_id"]
			if(attached_weapon_systems[weapon_id])
				selected_weapon_id = weapon_id
			else
				say("Invalid weapon system selected.")
		if("fireAtCoordinates")
			var/target_x = params["x"]
			var/target_y = params["y"]
			if(!attached_orbital_object)
				say("Console not linked to any orbital object.")
				return
			if(attached_weapon_systems[selected_weapon_id])
				var/datum/weapon_system/weapon = attached_weapon_systems[selected_weapon_id]
				weapon.fire(attached_orbital_object, target_x, target_y)
			//TODO Update to display the new projectile
			//Reminder that this needs to account for elapsed time.
			//. = TRUE
