/obj/machinery/computer/flux_controller
	name = "flux vacuum computer"
	desc = "A computer which monitors and manages the containment of anomalies."
	var/obj/machinery/power/flux_vacuum_generator/connected

/obj/machinery/computer/flux_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "FluxVacuum")
		ui.open()

/obj/machinery/computer/flux_controller/ui_data(mob/user)
	var/list/data = list()
	return data

/obj/machinery/computer/flux_controller/ui_act(action, params)
	if (..())
		return
	switch (action)
		if ("activate")
			return
		if ("reconnect")
			var/located = locate(/obj/machinery/power/flux_vacuum_generator) in range(5, src)
			if (located)
				connect(located)
				say("Successfully connected to flux vacuum generator.")
			else
				say("Could not locate nearby flux vacuum generator within 5 meters.")
			return

/obj/machinery/computer/flux_controller/proc/connect(obj/machinery/power/flux_vacuum_generator/value)
	if (connected)
		disconnect()
	connected = value
	RegisterSignal(connected, COMSIG_PARENT_QDELETING, PROC_REF(disconnect))

/obj/machinery/computer/flux_controller/proc/disconnect()
	SIGNAL_HANDLER
	UnregisterSignal(connected, COMSIG_PARENT_QDELETING)
