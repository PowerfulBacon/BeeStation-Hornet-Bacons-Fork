/// Flux harvester
/// Connects directly to the power grid and takes time to extract flux
/// The more flux you extract at once, the more power it requires which
/// means higher tier canisters require an upgraded power grid.
/obj/machinery/power/flux_harvester
	name = "flux harvester"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"

	processing_flags = START_PROCESSING_MANUALLY
	density = TRUE

	/// Are we currently harvesting
	var/harvesting = FALSE
	/// The amount we are currently harvesting
	var/harvest_amount
	/// The world time that the harvester will finish harvesting
	var/completion_time

/obj/machinery/power/flux_harvester/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FluxHarvester") //width, height
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/power/flux_harvester/process(delta_time)
	if (!harvesting)
		end_processing()
		return
	if (world.time > completion_time)
		complete_harvest()
		return
	var/obj/item/flux_container/container = locate() in contents
	if (!container)
		emergency_shutdown()
		return
	var/load_required = 50 * harvest_amount * delta_time
	if (surplus() < load_required)
		emergency_shutdown()
		return
	add_load(load_required)

/obj/machinery/power/flux_harvester/ui_data(mob/user)
	var/list/data = list()
	data["status"] = get_status()
	data["harvest_amount"] = harvest_amount
	data["is_processing"] = harvesting
	data["ticks_left"] = completion_time - world.time
	return data

/obj/machinery/power/flux_harvester/ui_act(action, params)
	if (!..())
		return

	switch (action)
		if ("set_harvest_amount")
			if (harvesting)
				return
			var/safe_num = sanitize_integer(text2num(params["amount"]), 1, INFINITY, 0)
			if (!safe_num)
				return
			harvest_amount = safe_num
		if ("begin_harvest")
			try_start_processing()
		if ("emergency_stop")
			emergency_shutdown()
		if ("eject_canister")
			eject_canister()
	return TRUE

/// Implement canister inserting behaviour
/obj/machinery/power/flux_harvester/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/flux_container))
		var/obj/item/flux_container/container = locate() in contents
		if (container)
			balloon_alert(user, "There is already a flux canister stored in there!")
			return
		// Make sure we can actually drop the item
		if (user.temporarilyRemoveItemFromInventory(W))
			W.forceMove(src)
		return
	. = ..()

/obj/machinery/power/flux_harvester/proc/eject_canister()
	if (harvesting)
		return
	// Make sure we have a canister inserted
	var/obj/item/flux_container/container = locate() in contents
	if (!container)
		return
	container.forceMove(get_turf(src))

/obj/machinery/power/flux_harvester/proc/try_start_processing()
	if (harvesting)
		return
	// Make sure we have a canister inserted
	var/obj/item/flux_container/container = locate() in contents
	if (!container || container.energy_stored)
		return

/obj/machinery/power/flux_harvester/proc/complete_harvest()
	var/obj/item/flux_container/container = locate() in contents
	if (!container || container.energy_stored)
		return
	// Lower the harvested flux amount
	var/turf/T = get_turf(src)
	SSanomaly_science.set_flux_level(T.z, SSanomaly_science.get_flux_level(T.z) - harvest_amount)
	container.energy_stored = harvest_amount

/obj/machinery/power/flux_harvester/proc/emergency_shutdown()
	if (!harvesting)
		return
	// Stop processing
	end_processing()
	// Do some weird effect

/// Return the status message which indicates to the user why the machine might not be working
/obj/machinery/power/flux_harvester/proc/get_status()
	if (harvesting)
		return "Harvesting flux"
	var/obj/item/flux_container/container = locate() in contents
	if (!container)
		return "No container inserted"
	if (container.energy_stored)
		// Energised is the correct spelling according to the oxford dictionary
		return "Installed container is already energised"
	var/load_required = 50 * harvest_amount
	if (surplus() < load_required)
		return "Insufficient power on grid, [display_power(load_required)] required"
	return "Ready to process"
