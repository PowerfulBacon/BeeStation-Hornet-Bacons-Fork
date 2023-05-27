/**
 * The supression field generator which allows for the permanent
 * containment of anomalies. While in a supression field, anomalies
 * will never breach however they will produce significantly less
 * flux and cannot be experimented on.
 *
 * It is controlled by the containment chamber control computer and
 * actively consumes power while active.
 *
 * The supression field consumes more power depending on how strong of
 * an anomaly it is containing as well as how many anomalies. It has a
 * limit to its supression cababilities and anomalies will slowly destabilise
 * if they exceed the limit of the generator.
 *
 * The supression generator can be placed anywhere inside the room with the
 * anomaly.
 *
 * @PowerfulBacon#3338
 */
/obj/machinery/power/anomaly_supression_generator
	name = "flux supression field generator"
	desc = "A large pylon-like structure which stabilises flux-space decreasing the reactivity of nearby anomalies, making containment possible."
	obj_flags = CAN_BE_HIT
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"
	processing_flags = START_PROCESSING_MANUALLY
	var/activated = FALSE
	// Gain 1.2 supression rates per second (Total of 0.2 increase per second)
	var/supression_rate = 1.2

/obj/machinery/power/anomaly_supression_generator/proc/set_activate(state)
	if (activated == state)
		return
	activated = state
	if (activated)
		begin_processing()
	else
		end_processing()

/obj/machinery/power/anomaly_supression_generator/process(delta_time)
	// Supress nearby anomalies
	var/list/anomalies = list()
	for (var/atom/movable/target in view(4, src))
		var/datum/component/anomaly_base/anom = target.GetComponent(/datum/component/anomaly_base)
		if (!anom)
			continue
		anomalies += anom
		// For testing purposes
		new /obj/effect/temp_visual/explosion(target.loc)
	// Do the supression
	var/supression_ratio = supression_rate / length(anomalies)
	for (var/datum/component/anomaly_base/anom as() in anomalies)
		anom.stability_level = max(anom.stability_level + supression_ratio, 100)
