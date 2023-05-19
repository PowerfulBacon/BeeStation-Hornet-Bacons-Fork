/datum/objective/open/damage_equipment
	name = "sabotage operations"
	explanation_text = "Sabotage equipment by damaging or disabling it within %DEPARTMENT%."
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
		// Anywhere monitored by the AI will do
		"the AI's facilities" = list(/area/aisat, /area/ai_monitored)
	)
	var/damaged_machines = 0

/datum/objective/open/damage_equipment/New(text)
	. = ..()
	// Select an area to target
	selected_area = pick(valid_areas)
	//Update the explanation text
	update_explanation_text()
	// All machines in the area at the time will count
	// Registered signals will be cleared automatically on destroy
	for (var/obj/machinery/machine in GLOB.machines)
		var/area/machine_area = get_area(machine)
		var/list/target_area_types = valid_areas[selected_area]
		for (var/target_zone in target_area_types)
			if (istype(machine_area, target_zone))
				RegisterSignal(machine, COMSIG_MACHINERY_BROKEN, PROC_REF(register_machine_damage))
				RegisterSignal(machine, COMSIG_PARENT_QDELETING, PROC_REF(register_machine_damage))
				break

/datum/objective/open/damage_equipment/proc/register_machine_damage(obj/machinery/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MACHINERY_BROKEN, COMSIG_PARENT_QDELETING))
	damaged_machines ++

/datum/objective/open/damage_equipment/update_explanation_text()
	var/objective_text = pick(\
		"Sabotage equipment by damaging or disabling it within %DEPARTMENT%.",\
		"Damage equipment inside of %DEPARTMENT% in order to disrupt station operations.")
	explanation_text = replacetext(objective_text, "%DEPARTMENT%", selected_area)

/datum/objective/open/damage_equipment/check_completion()
	return (damaged_machines > 0) || ..()

/datum/objective/open/damage_equipment/get_completion_message()
	if (!damaged_machines)
		return "[explanation_text] <span class='redtext'>No sabotaged machines (somehow)!</span>"
	return "[explanation_text] <span class='infotext'>[damaged_machines] sabotaged machines!</span>"
