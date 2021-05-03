/obj/docking_port/mobile/mining/register()
	. = ..()
	//Register as a custom shuttle.
	var/datum/ship_datum/mining/mining_shuttle = new
	SSbluespace_exploration.register_new_ship("mining", "Mining Shuttle", mining_shuttle)

/datum/ship_datum/mining
	health_percentage = 0.8
	generation_mode = BLUESPACE_DRIVE_MININGLEVEL

/obj/effect/abstract/mining_landmark
	name = ""

/obj/machinery/computer/system_map/mining
	name = "mining shuttle console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/circuitboard/computer/mining_shuttle
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_ORANGE
	shuttle_id = "mining"
	standard_port_locations = list("mining_home", "mining_public")
	var/list/dumb_rev_heads = list()

/obj/machinery/computer/system_map/mining/attack_hand(mob/user)
	if(is_station_level(user.z) && user.mind && is_head_revolutionary(user) && !(user.mind in dumb_rev_heads))
		to_chat(user, "<span class='warning'>You get a feeling that leaving the station might be a REALLY dumb idea...</span>")
		dumb_rev_heads += user.mind
		return
	. = ..()
