/datum/objective/open/explosion
	name = "detonate explosive"
	explanation_text = "Obtain and detonate an explosive device within %DEPARTMENT%."
	var/selected_area
	var/list/valid_areas = list(
		"medical" = list(/area/medical),
		"engineering" = list(/area/engineering, /area/engine),
		"security" = list(/area/security),
		"the cargo bay" = list(/area/quartermaster, /area/cargo),
		"the bridge" = list(/area/bridge),
		"the communications relay" = list(/area/comms, /area/server),
		"the science lab" = list(/area/science),
		"the research division server room" = list(/area/science/server),
	)
	var/success = FALSE
	var/devistation = 0
	var/heavy = 0
	var/light = 0

/datum/objective/open/explosion/New(text)
	. = ..()
	//Pick an area to target
	selected_area = pick(valid_areas)
	//Register for the signals
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, .proc/on_explosion)
	//Update the explanation text
	update_explanation_text()

/datum/objective/open/explosion/Destroy(force, ...)
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)
	. = ..()

/datum/objective/open/explosion/proc/on_explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	if(!light_impact_range && !heavy_impact_range && !devastation_range)
		return
	var/area/A = get_area(epicenter)
	var/list/target_area_types = valid_areas[selected_area]
	for(var/target_type in target_area_types)
		if(istype(A, target_type))
			success = TRUE
			devistation = max(devistation, devastation_range)
			heavy = max(heavy, light_impact_range)
			light = max(light, light_impact_range)
			return

/datum/objective/open/explosion/update_explanation_text()
	var/objective_text = pick(\
		"Obtain and detonate an explosive device within %DEPARTMENT%.",\
		"Get your hands on any form of explosive device and detonate it inside of %DEPARTMENT%.",\
		"Deploy and activate an explosive inside of %DEPARTMENT%.",\
		"Cause fear and panic by detonating an explosive within %DEPARTMENT%.",\
		"Destroy a part of %DEPARTMENT% with an explosive device.%")
	explanation_text = replacetext(objective_text, "%DEPARTMENT%", selected_area)

/datum/objective/open/explosion/check_completion()
	return success || ..()

/datum/objective/open/explosion/get_completion_message()
	if(!success)
		return "[explanation_text] <span class='redtext'>Fail!</span>"
	return "[explanation_text] <span class='infotext'>Largest Bomb: ([devistation], [heavy], [light])</span>"
