// Works like a networking device using NTnet:
// Suit sensors send a request to connect to the network
// The suit sensor network then sends constant pings to the suit sensor to request status
// If suit sensors time out then they are removed from the suit sensor network
//
// BPM will be recorded frequently and used to determine if someone is unconcious (low BPM), alive (Average BPM), taking damage (High BPM) or dead (No BPM)
// Suit sensors will also monitor environmental alerts and indicate situations:
// - Blunt force warning
// - Low pressure warning
// - High pressure warning
// - Temperatures warnings
//
// Brute damage and burn damage attacks will have warnings, however oxygen and toxin based damages will not
// show signs of injury except from monitoring BPM.
//
// If visible to a camera, the camera network will record the last known position of someone if their
// suit sensors are set to tracking.
// The disadvantage to this method is that it is slow, infrequently updating every 30 seconds but it gives
// paramedics and detectives an area where they can start investigation into accidents that occur on the station.
//
// Having full health scanning inside of a small suit sensors would consume far too much power, and GPS devices would
// require a decent chunk of power, so instead the tracking is offloaded to the station's camera network, where power is not
// a concern and the suit sensors record data using very basic, primitive but efficient sensors.
//
// If a suit sensor goes offline, it will remain in the network for some time showing (DISCONNECTED) before disappearing.
//
// If the comms network goes down, then the suit sensor network unit box (this machine) will not be able to receive the network
// querys and all suit sensor monitoring devices will be disabled.
/obj/machinery/suit_sensor_network
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	name = "suit sensor network"
	density = TRUE
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70, "stamina" = 0)
	network_id = __NETWORK_SENSORS
	/// Associative list of datapoints by name
	var/list/datapoints_by_name = list()
	///Timeout time, after this time a node will be removed from the network
	var/timeout_time = 30 SECONDS
	///Update time
	var/update_rate = 15 SECONDS
	///Time of last update
	var/last_update

/obj/machinery/suit_sensor_network/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, .proc/handle_ntnet_signal)

/obj/machinery/suit_sensor_network/proc/handle_ntnet_signal(datum/source, datum/netdata/data)
	//Machine isn't operational, don't respond
	if (!is_operational())
		return
	var/request = data.data["request"]
	switch (request)
		if ("connect")
			//New suit sensor registering on the network
			var/sensor_id = data.data["id"]
			var/datum/sensor_datapoint/new_point = new /datum/sensor_datapoint()
			//Set some initial data
			new_point.id = sensor_id
			new_point.name = "Unknown"
			new_point.hardware_id = data.sender_id
			new_point.last_updated_time = world.time
			new_point.recorded_bpm = 0
			new_point.last_known_location = "Unknown"
			new_point.sensor_alerts = list()
			//Add the datapoint to the network
			datapoints_by_name[sensor_id] = new_point
		if ("disconnect")
			//A sensor requested to be deleted from the network
			//Surely this wasn't a faked packet :oblivious:
			var/sensor_id = data.data["id"]
			datapoints_by_name -= sensor_id
		if ("query")
			//Something is attempting to query the network, build the response and send it back
		if ("response")
			//Get the top level data
			var/sensor_id = data.data["id"]
			var/sensor_name = data.data["name"]
			var/sensor_bpm = data.data["bpm"]
			var/sensor_location = data.data["location"]
			//Update the datapoint
			var/datum/sensor_datapoint/located_point = datapoints_by_name[sensor_id]
			//Cannot respond to something that isn't registered
			if (!located_point)
				return
			located_point.name = sensor_name || located_point.name
			located_point.recorded_bpm = sensor_bpm
			located_point.last_known_location = sensor_location || located_point.last_known_location
			located_point.last_updated_time = world.time
			located_point.sensor_alerts = list()

/obj/machinery/suit_sensor_network/process(delta_time)
	if (world.time < last_update + update_rate)
		return
	last_update = world.time
	//Send out ping requests to everyone connected to the network
	//Remove timed out nodes
	for (var/datapoint_name in datapoints_by_name)
		//Get the datapoint we want to update
		var/datum/sensor_datapoint/datapoint = datapoints_by_name[datapoint_name]
		//Create a data packet and send it
		var/datum/netdata/ping_request = new(list("request" = "query"))
		ntnet_send(data, datapoint.hardware_id)

/datum/sensor_datapoint
	/// Identifier for this sensor
	var/id
	/// The name of the person on the network
	var/name
	/// The network ID of this datapoint
	var/hardware_id
	/// The BPM recorded by the sensor
	var/recorded_bpm
	/// The last known location of the person
	var/last_known_location
	/// A list of all active sensor alerts
	var/list/sensor_alerts
	/// Last updated time
	var/last_updated_time

/datum/sensor_alert
	/// ID of the alert
	var/sensor_id
	/// The name of the alert
	var/sensor_text
