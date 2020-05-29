/obj/machinery/computer/galactic_market_console
	name = "galactic market console"
	desc = "Used to access, purchase and sell goods to and from the galactic market."
	icon_screen = "galactic_market"
	circuit = /obj/item/circuitboard/computer/galactic_market
	ui_x = 780
	ui_y = 750

	var/contraband = FALSE
	var/inserted_card = null

	light_color = "#E2853D"

/obj/machinery/computer/galactic_market_console/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	var/obj/item/circuitboard/computer/cargo/board = circuit
	contraband = board.contraband
	if (board.obj_flags & EMAGGED)
		obj_flags |= EMAGGED
	else
		obj_flags &= ~EMAGGED

/obj/machinery/computer/galactic_market_console/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	user.visible_message("<span class='warning'>[user] swipes a suspicious card through [src]!</span>",
	"<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

	obj_flags |= EMAGGED
	contraband = TRUE

	// This also permamently sets this on the circuit board
	var/obj/item/circuitboard/computer/galactic_market/board = circuit
	board.contraband = TRUE
	board.obj_flags |= EMAGGED
	update_static_data(user)

/obj/machinery/computer/galactic_market_console/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "GalacticMarket", name, ui_x, ui_y, master_ui, state)
		ui.open()
