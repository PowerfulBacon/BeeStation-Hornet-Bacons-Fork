/datum/round_modifier/charged_interference
	name = "Charged Interference"
	desc = "The station is currently encountering some mild electrical interference \
		likely originating from lavaland. Overcharging of devices is expected as well \
		as possible interference to our artificial intelligence systems. Stay safe out there."
	points = -2
	weight = 10

/datum/round_modifier/charged_interference/post_setup()
	for(var/datum/round_event_control/ion_storm/event in SSevents.control)
		event.weight = round(event.weight * 1.5)
	for(var/datum/round_event_control/electrical_storm/event in SSevents.control)
		event.weight = round(event.weight * 1.8)
	for(var/datum/round_event_control/processor_overload/event in SSevents.control)
		event.weight = round(event.weight * 1.5)
