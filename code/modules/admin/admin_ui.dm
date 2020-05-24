/datum/admin_ui_manager
	var/list/open_uis = list()

/datum/admin_ui_manager/proc/open_ui(datum/admin_ui/ui_datum, mob/user)
	var/datum/admin_ui/new_ui = new ui_datum()
	open_uis |= new_ui
	new_ui.owner_manager = src
	new_ui.ui_interact(user, new_ui.a_ui_key)

/datum/admin_ui
	var/a_ui_key
	var/a_ui_filename
	var/a_window_name
	var/a_ui_x
	var/a_ui_y
	var/a_auto_update = TRUE

	var/owner_manager

/datum/admin_ui/ui_interact(mob/user, ui_key = "generic_admin_ui", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, a_ui_filename, a_window_name, a_ui_x, a_ui_y, master_ui, state)
		ui.set_autoupdate(a_auto_update)
		ui.open()

/datum/admin_ui/ui_close(mob/user)
	. = ..()
	owner_manager.open_uis -= src
	qdel(src)	//We don't need to exist once closed, our purpose has been fufilled and we can rest forever
