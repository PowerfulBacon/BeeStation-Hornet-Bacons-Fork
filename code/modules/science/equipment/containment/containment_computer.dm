/obj/machinery/computer/containment
	name = "anomaly containment management computer"
	desc = "A computer which monitors and manages the containment of anomalies."
	var/obj/machinery/power/anomaly_supression_generator/linked_stabiliser

/obj/machinery/computer/containment/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	link_nearest_field()

/obj/machinery/computer/containment/proc/link_nearest_field(max_range = 5)
	for (var/obj/machinery/power/anomaly_supression_generator/stabiliser in circlerange(src, max_range))
		if (linked_stabiliser)
			UnregisterSignal(linked_stabiliser, COMSIG_PARENT_QDELETING)
		linked_stabiliser = stabiliser
		RegisterSignal(linked_stabiliser, COMSIG_PARENT_QDELETING, PROC_REF(clear_reference))
		return

/obj/machinery/computer/containment/proc/clear_reference()
	linked_stabiliser = null

/obj/machinery/computer/containment/ui_data(mob/user)
	var/list/data = list()
	data["linked"] = !!linked_stabiliser
	data["activated"] = linked_stabiliser?.activated
	return data

/obj/machinery/computer/containment/ui_act(action, params)
	if (..())
		return
	switch (action)
		// Relink
		if ("relink")
			link_nearest_field()
			return TRUE
		// Toggle a supression generator, enable or disable it
		if ("toggle_supression_generator")
			linked_stabiliser?.activated = !linked_stabiliser.activated
			return
