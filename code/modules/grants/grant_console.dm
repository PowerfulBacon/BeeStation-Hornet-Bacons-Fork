/obj/machinery/computer/grant
	name = "grant computer"
	desc = "A computer for managing grants issued by Nanotrasen."

/obj/machinery/computer/grant/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Grant", "Grant")
		ui.open()
