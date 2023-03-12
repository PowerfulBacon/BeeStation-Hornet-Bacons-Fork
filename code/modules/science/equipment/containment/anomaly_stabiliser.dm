/obj/machinery/anomaly_stabiliser
	name = "anomaly stabiliser"
	desc = "A high-powered laser which stabilises anomalies that it is pointed towards. \
		This newer model is a lot more portable than the previous generations, however is still \
		quite large and requires the target anomaly to be immobilised first."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	processing_flags = START_PROCESSING_MANUALLY
	density = TRUE
	anchored = FALSE
	var/toggled_on = FALSE

/obj/machinery/anomaly_stabiliser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnomalyStabiliser")
		ui.open()

/obj/machinery/anomaly_stabiliser/ui_data(mob/user)
	var/list/data = list()
	data["enabled"] = toggled_on
	return data

/obj/machinery/anomaly_stabiliser/ui_act(action, params)
	if (..())
		return
	switch (action)
		if ("toggle_stabiliser")
			toggled_on = !toggled_on
			return TRUE
