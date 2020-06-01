/obj/machinery/computer/galactic_market_console
	name = "galactic market console"
	desc = "Used to access, purchase and sell goods to and from the galactic market."
	icon_screen = "galactic_market"
	circuit = /obj/item/circuitboard/computer/galactic_market
	ui_x = 780
	ui_y = 750

	var/contraband = FALSE
	var/inserted_card = null

	var/list/current_order = list()
	var/list/amount_list = list()

	var/datum/bank_account/attatched_account

	light_color = "#E2853D"

/obj/machinery/computer/galactic_market_console/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	var/obj/item/circuitboard/computer/cargo/board = circuit
	contraband = board.contraband
	if (board.obj_flags & EMAGGED)
		obj_flags |= EMAGGED
	else
		obj_flags &= ~EMAGGED

/obj/machinery/computer/galactic_market_console/cargo/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	attatched_account = SSeconomy.get_dep_account(ACCOUNT_CAR)

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

/obj/machinery/computer/galactic_market_console/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	var/obj/item/card/id/C = I
	if(!istype(C))
		return
	if(!C.registered_account)
		to_chat(user, "<span class='warning'>Failed to locate ID bank account.</span>")
		return
	to_chat(user, "<span class='notice'>You connect the account[C.registered_name ? " of [C.registered_name]" : ""] to the console.</span>")
	attatched_account = C.registered_account

/obj/machinery/computer/galactic_market_console/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "GalacticMarket", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/galactic_market_console/ui_data(mob/user)
	var/list/data = list()
	data["account_name"] = attatched_account ? attatched_account.account_holder : "No account registered";
	data["money"] = attatched_account ? attatched_account.account_balance : 0
	data["amount_list"] = amount_list
	data["current_order"] = list()
	data["total_cost"] = 0
	for(var/order in current_order)
		var/amount = current_order[order]
		var/datum/galactic_market/resource/resource = SSgalactic_market.get_resource_from_id(order)
		var/cost = SSgalactic_market.estimate_cost(resource, text2num(amount)) * resource.get_buy_tax()
		data["current_order"] += list(list(
			"name" = order,
			"amount" = amount,
			"cost" = cost,
		))
		data["total_cost"] += cost
	data["categories"] = list()
	data["categories_hacked"] = list()
	for(var/G_key in SSgalactic_market.resource_groups)
		var/datum/galactic_market/resource_group/G =SSgalactic_market.resource_groups[G_key]
		var/list/category = list(
			"name" = G.name,
			"items" = list()
		)
		for(var/R_key in G.resources)
			var/datum/galactic_market/resource/R = G.resources[R_key]
			category["items"] += list(list(
				"name" = R.name,
				"id" = R.resource_id,
				"cost" = R.calculated_price * R.get_buy_tax(),
				"supply" = R.market_current_supply,
				"fairprice" = R.market_fair_price,
				"illegal" = R.illegal
			))
		if(G.illegal)
			data["categories_hacked"] += list(category)
		else
			data["categories"] += list(category)
	return data

/obj/machinery/computer/galactic_market_console/ui_act(action, params)
	switch(action)
		if("change_num")
			amount_list[params["id"]] = params["new"]
		if("add_to_basket")
			if(text2num(params["amount"]))
				if(current_order.Find(params["item"]))
					current_order[params["item"]] += text2num(params["amount"])
				else
					current_order[params["item"]] = text2num(params["amount"])
				var/datum/galactic_market/resource/R = SSgalactic_market.get_resource_from_id(params["item"])
				if(current_order[params["item"]] > R.market_current_supply)
					current_order[params["item"]] = R.market_current_supply
				else if(current_order[params["item"]] < 0)
					current_order[params["item"]] = 0
		if("buy")
			if(!attatched_account)
				return
			SSgalactic_market.read_galactic_market()
			var/orderCost = 0
			for(var/order in current_order)
				var/datum/galactic_market/resource/R = SSgalactic_market.get_resource_from_id(order)
				orderCost += SSgalactic_market.estimate_delta_money(R, -text2num(current_order[order])) * R.get_buy_tax()
			if(!attatched_account.adjust_money(orderCost))
				say("Insufficient funds, [-orderCost] credits required.")
				return
			//Find a nearby position
			var/list/obj_list = view(5, src)
			var/turf/open/selected_turf = pick(obj_list)
			var/turf/T = get_turf(selected_turf)
			if(!T)
				say("Error, unable to locate suitable bluespace translocation destination nearby.")
				return
			say("Order confirmed, thank you for your purchase. [-orderCost] credits have been withdrawn from your account.")
			//Subtract From Market
			for(var/order in current_order)
				var/datum/galactic_market/resource/R = SSgalactic_market.get_resource_from_id(order)
				R.market_current_supply -= text2num(current_order[order])
				SSgalactic_market.update_market_supply(R)
				//Create the materials nearby the console
				if(!R.item_datum)
					continue
				new /obj/effect/particle_effect/sparks(T)
				playsound(T, "sparks", 50, 1)
				for(var/i = 0; i < text2num(current_order[order]); i++)
					var/atom/spawned_object = new R.item_datum(T)
					if(spawned_object.vars["amount"])
						var/max_amount = spawned_object.vars["max_amount"]
						var/amount_to_add = min(max_amount, text2num(current_order[order]) - i)
						spawned_object.vars["amount"] = amount_to_add
						i += amount_to_add - 1
			current_order = list()
		if("clear")
			current_order = list()
	ui_interact(usr)
