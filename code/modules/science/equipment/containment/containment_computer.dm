/obj/machinery/computer/containment
	name = "anomaly containment management computer"
	desc = "A computer which monitors and manages the containment of anomalies."

/obj/machinery/computer/containment/ui_data(mob/user)
	var/list/data = list()
	return data

/obj/machinery/computer/containment/ui_act(action, params)
	if (..())
		return
	switch (action)
		// Toggle a supression generator, enable or disable it
		if ("toggle_supression_generator")
			return
