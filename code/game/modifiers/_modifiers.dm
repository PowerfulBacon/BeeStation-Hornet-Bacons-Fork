//Todo: Config setup
#define MODIFIERS_MINIMUM 1
#define MODIFIERS_MAXIMUM 3
#define SECTOR_REPORT_MIN 30 SECONDS
#define SECTOR_REPORT_MAX 5 MINUTES

GLOBAL_LIST_EMPTY(current_modifiers)

/datum/modifiers_controller
	var/allowed_modifiers = null
	var/points_left = 2	//Not implemented yet, don't push without this being done
	var/picks_left = 3
	var/total_weight = 0

/datum/modifiers_controller/proc/setup()
	generate_station_modifiers()
	for(var/datum/round_modifier/modifier in GLOB.current_modifiers)
		modifier.pre_setup()
	addtimer(CALLBACK(src, .proc/send_sector_report, 0), rand(SECTOR_REPORT_MIN, SECTOR_REPORT_MAX))

/datum/modifiers_controller/proc/generate_station_modifiers()
	if(!allowed_modifiers)
		generate_allowed_modifiers()
	while(picks_left > 0)
		picks_left --
		//Choose one :)
		var/weight_left = total_weight
		for(var/datum/round_modifier/M in allowed_modifiers)
			if(prob(weight_left?(M.weight / weight_left) * 100:0))
				log_game("[M.name] was chosen as the round modifier, with a [weight_left?(M.weight / weight_left) * 100:0]% chance of spawning")
				GLOB.current_modifiers += M
				total_weight -= M.weight
				allowed_modifiers -= M
				//Don't spawn these modifiers either
				for(var/datum/round_modifier/mod_to_remove in allowed_modifiers)
					if(!(mod_to_remove in M.incompatible_modifiers))
						continue
					total_weight -= mod_to_remove.weight
					allowed_modifiers -= mod_to_remove
				break
			weight_left -= M.weight

/datum/modifiers_controller/proc/generate_allowed_modifiers()
	allowed_modifiers = list()
	var/pop_count = GLOB.player_list.len
	for(var/M in subtypesof(/datum/round_modifier))
		var/datum/round_modifier/instantiated_modifier = new M()
		if(pop_count < instantiated_modifier.minimum_pop)
			continue
		if(pop_count > instantiated_modifier.maximum_pop)
			continue
		if(SSticker.mode in instantiated_modifier.blacklisted_gamemodes)
		allowed_modifiers += instantiated_modifier
		total_weight += instantiated_modifier.weight

/datum/modifiers_controller/process()
	for(var/datum/round_modifier/modifier in GLOB.current_modifiers)
		modifier.process()

/datum/modifiers_controller/proc/post_setup()
	for(var/datum/round_modifier/modifier in GLOB.current_modifiers)
		modifier.post_setup()

/datum/modifiers_controller/proc/send_sector_report()
	var/text = "<b><i>Central Command Status Summary</i></b><hr>"
	text += "<b>Sensor data has been recorded and interpreted for the shift, data for the\
	sector has been provided below.</b><hr>"
	var/extra_data = ""
	for(var/datum/round_modifier/modifier in GLOB.current_modifiers)
		extra_data += "[modifier.desc]<br>"
	text += extra_data ? extra_data : "No anomalous data has been reported. Have a secure shift. <br>"
	text += "Thank you for your attention. Glory to nanotrasen."
	print_command_report(text, "Central Command Status Summary", announce=FALSE)
	priority_announce("A secure sector report has been downloaded to all communication consoles.", "Sector summary report downloaded.", 'sound/ai/commandreport.ogg')

#undef MODIFIERS_MINIMUM
#undef MODIFIERS_MAXIMUM
#undef SECTOR_REPORT_MIN
#undef SECTOR_REPORT_MAX
