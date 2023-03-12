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
