GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/structure/blob,
		/obj/effect/rune,
		/obj/structure/spider/spiderling,
		/obj/item/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/beacon,
		/obj/singularity/narsie,
		/obj/singularity/wizard,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/quantumpad,
		/obj/machinery/clonepod,
		/obj/effect/mob_spawn,
		/obj/effect/hierophant,
		/obj/structure/receiving_pad,
		/obj/item/warp_cube,
		/obj/machinery/rnd/production, //print tracking beacons, send shuttle
		/obj/machinery/modular_fabricator/autolathe, //same
		/obj/item/projectile/beam/wormhole,
		/obj/effect/portal,
		/obj/item/shared_storage,
		/obj/structure/extraction_point,
		/obj/machinery/syndicatebomb,
		/obj/item/hilbertshotel,
		/obj/item/swapper,
		/obj/docking_port
	)))

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"

	dir = WEST
	port_direction = EAST
	width = 12
	dwidth = 5
	height = 7
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)

	//Shuttle spawns at centcom
	var/loaded = TRUE

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src

/obj/docking_port/mobile/proc/buy(datum/bank_account/paying_account)
	var/list/obj/miscboxes = list() //miscboxes are combo boxes that contain all small_item orders grouped
	var/list/misc_order_num = list() //list of strings of order numbers, so that the manifest can show all orders in a box
	var/list/misc_contents = list() //list of lists of items that each box will contain
	if(!SSshuttle.shoppinglist.len)
		return

	var/list/empty_turfs = list()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/turf/open/floor/T in shuttle_area)
			if(is_blocked_turf(T))
				continue
			empty_turfs += T

	var/value = 0
	var/purchases = 0
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!empty_turfs.len)
			break
		var/price = SO.pack.get_cost()
		var/datum/bank_account/D
		if(SO.paying_account) //Someone paid out of pocket
			//If we only want orders from a specific account, and the order
			//was from a different account, continue.
			if(paying_account && paying_account != SO.paying_account)
				continue
			D = SO.paying_account
			price *= 1.1 //TODO make this customizable by the quartermaster
		else
			//If we want cargo orders, but we only want orders
			//from a specific account, continue
			if(paying_account)
				continue
			D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			if(!D.adjust_money(-price))
				if(SO.paying_account)
					D.bank_card_talk("Cargo order #[SO.id] rejected due to lack of funds. Credits required: [price]")
				continue

		if(SO.paying_account)
			D.bank_card_talk("Cargo order #[SO.id] has shipped. [price] credits have been charged to your bank account.")
			var/datum/bank_account/department/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
			cargo.adjust_money(price - SO.pack.get_cost()) //Cargo gets the handling fee
		value += SO.pack.get_cost()
		SSshuttle.shoppinglist -= SO
		SSshuttle.orderhistory += SO

		if(SO.pack.small_item) //small_item means it gets piled in the miscbox
			if(SO.paying_account)
				if(!miscboxes.len || !miscboxes[D.account_holder]) //if there's no miscbox for this person
					miscboxes[D.account_holder] = new /obj/structure/closet/crate/secure/owned(pick_n_take(empty_turfs), SO.paying_account)
					miscboxes[D.account_holder].name = "small items crate - purchased by [D.account_holder]"
					misc_contents[D.account_holder] = list()
					miscboxes[D.account_holder].req_access = list()
				for (var/item in SO.pack.contains)
					misc_contents[D.account_holder] += item
				misc_order_num[D.account_holder] = "[misc_order_num[D.account_holder]]#[SO.id]  "
				if(SO.pack.access)
					miscboxes[D.account_holder].req_access += SO.pack.access
			else //No private payment, so we just stuff it all into a generic crate
				if(!miscboxes.len || !miscboxes["Cargo"])
					miscboxes["Cargo"] = new /obj/structure/closet/crate/secure(pick_n_take(empty_turfs))
					miscboxes["Cargo"].name = "small items crate"
					misc_contents["Cargo"] = list()
					miscboxes["Cargo"].req_access = list()
				for (var/item in SO.pack.contains)
					misc_contents["Cargo"] += item
					//new item(miscboxes["Cargo"])
				if(SO.pack.access)
					miscboxes["Cargo"].req_access += SO.pack.access
				misc_order_num["Cargo"] = "[misc_order_num["Cargo"]]#[SO.id]  "
		else
			SO.generate(pick_n_take(empty_turfs))

		SSblackbox.record_feedback("nested tally", "cargo_imports", 1, list("[SO.pack.get_cost()]", "[SO.pack.name]"))
		investigate_log("Order #[SO.id] ([SO.pack.name], placed by [key_name(SO.orderer_ckey)]), paid by [D.account_holder] has shipped.", INVESTIGATE_CARGO)
		if(SO.pack.dangerous)
			message_admins("\A [SO.pack.name] ordered by [ADMIN_LOOKUPFLW(SO.orderer_ckey)], paid by [D.account_holder] has shipped.")
		purchases++

	if(!paying_account)
		for(var/I in miscboxes)
			var/datum/supply_order/SO = new/datum/supply_order()
			SO.id = misc_order_num[I]
			SO.generateCombo(miscboxes[I], I, misc_contents[I])
			qdel(SO)

	var/datum/bank_account/cargo_budget = SSeconomy.get_dep_account(ACCOUNT_CAR)
	investigate_log("[purchases] orders in this shipment, worth [value] credits. [cargo_budget.account_balance] credits left.", INVESTIGATE_CARGO)

/obj/docking_port/mobile/supply/buy()
	. = ..()
	loaded = TRUE
