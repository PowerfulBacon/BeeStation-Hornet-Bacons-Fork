/*
	The relay idles until it receives information. It then passes on that information
	depending on where it came from.

	The relay is needed in order to send information pass Z levels. It must be linked
	with a HUB, the only other machine that can send/receive pass Z levels.
*/

/obj/machinery/telecomms/relay
	name = "telecommunication relay"
	icon_state = "relay"
	desc = "A mighty piece of hardware used to send massive amounts of data far away."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	netspeed = 5
	long_range_link = 1
	circuit = /obj/item/circuitboard/machine/telecomms/relay
	var/broadcasting = 1
	var/receiving = 1

/obj/machinery/telecomms/relay/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	// Add our level and send it back
	var/turf/T = get_turf(src)
	if(can_send(signal) && T)
		signal.levels |= T.get_virtual_z_level()

// Checks to see if it can send/receive.

/obj/machinery/telecomms/relay/proc/can(datum/signal/signal)
	if(!on)
		return FALSE
	if(!is_freq_listening(signal))
		return FALSE
	return TRUE

/obj/machinery/telecomms/relay/proc/can_send(datum/signal/signal)
	if(!can(signal))
		return FALSE
	return broadcasting

/obj/machinery/telecomms/relay/proc/can_receive(datum/signal/signal)
	if(!can(signal))
		return FALSE
	return receiving

//Preset Relay

/obj/machinery/telecomms/relay/preset
	network = "tcommsat"

/obj/machinery/telecomms/relay/Initialize(mapload)
	. = ..()
	if(autolinkers.len) //We want lateloaded presets to autolink (lateloaded aways/ruins/shuttles)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/telecomms/relay/preset/station
	id = "Station Relay"
	autolinkers = list("s_relay")

/obj/machinery/telecomms/relay/preset/telecomms
	id = "Telecomms Relay"
	autolinkers = list("relay")

/obj/machinery/telecomms/relay/preset/mining
	id = "Mining Relay"
	autolinkers = list("m_relay")

/obj/machinery/telecomms/relay/preset/ruskie
	id = "Ruskie Relay"
	hide = 1
	toggled = FALSE
	autolinkers = list("r_relay")

/obj/machinery/telecomms/relay/preset/reebe
	id = "Hierophant Relay"
	hide = 1
	autolinkers = list("h_relay")
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "relay"
	broadcasting = FALSE	//It only receives

/obj/machinery/telecomms/relay/preset/reebe/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/encryptionkey) || P.tool_behaviour == TOOL_SCREWDRIVER)
		if(GLOB.clockcult_eminence)
			var/mob/living/simple_animal/eminence/eminence = GLOB.clockcult_eminence
			var/obj/item/encryptionkey/E
			for(var/i in E.channels)
				E.channels[i] = 1
			eminence.internal_radio.attackby(E, user, params)
	. = ..()

//Generic preset relay
/obj/machinery/telecomms/relay/preset/auto
	hide = TRUE
	autolinkers = list("autorelay")
