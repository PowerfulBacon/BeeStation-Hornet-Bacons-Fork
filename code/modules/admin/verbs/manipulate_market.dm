/client/proc/manipulate_market()
	set name = "Manipulate Galactic Market"
	set desc = "Opens the galactic market manipulator."
	set category = "Debug"
	var/datum/admins/admin_datum = src.holder
	if(!admin_datum)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!check_rights(R_DEBUG))
		to_chat(src, "Insufficient rights!")
		return
	admin_datum.admin_interface.open_ui(/datum/admin_ui/market_manipulator, usr)

/datum/admin_ui/market_manipulator
	a_ui_key = "marketmanip"
	a_ui_filename = "MarketManipulator"
	a_window_name = "market manipulator"
	a_ui_x = 900
	a_ui_y = 720
