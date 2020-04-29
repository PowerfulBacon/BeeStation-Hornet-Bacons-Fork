//Todo: Config setup
#define MODIFIERS_MINIMUM 1
#define MODIFIERS_MAXIMUM 3

GLOBAL_LIST_EMPTY(current_modifiers)

/datum/modifiers_controller
	var/allowed_modifiers = null
	var/points_left = 2
	var/picks_left = 3
	var/total_weight = 0

/datum/modifiers_controller/proc/setup()
	generate_station_modifiers()
	for(var/datum/round_modifier/modifier in GLOB.current_modifiers)
		modifier.pre_setup()

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
		allowed_modifiers += instantiated_modifier
		total_weight += instantiated_modifier.weight

/datum/modifiers_controller/process()
	for(var/datum/round_modifier/modifier in GLOB.current_modifiers)
		modifier.process()

/datum/modifiers_controller/proc/post_setup()
	for(var/datum/round_modifier/modifier in GLOB.current_modifiers)
		modifier.post_setup()

#undef MODIFIERS_MINIMUM
#undef MODIFIERS_MAXIMUM
