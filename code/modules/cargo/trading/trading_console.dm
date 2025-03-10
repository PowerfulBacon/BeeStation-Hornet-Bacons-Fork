/obj/machinery/computer/trading_console
	name = "inter-faction trading console"
	desc = "A console used to buy and sell goods between different factions."
	var/datum/bank_account/linked_account

/obj/machinery/computer/trading_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Trading")
		ui.open()

/obj/machinery/computer/trading_console/ui_data(mob/user)
	var/list/data = list()
	data["account_name"] = linked_account.account_holder
	data["account_balance"] = linked_account.account_balance
	var/list/listed_crates = list()
	for (var/obj/structure/closet/crate/secure/trading/crate in SSeconomy.active_trades)
		var/list/contents_list = list()
		for (var/obj/content in crate.contents)
			if (istype(content, /obj/item/stack))
				var/obj/item/stack/stack = content
				contents_list[initial(content.name)] += stack.amount
			else
				contents_list[initial(content.name)] ++
		listed_crates += list(list(
			"id" = crate.unique_id,
			"price" = crate.listed_price,
			"name" = crate.name,
			"contents" = contents_list
		))
	data["listed_crates"] = listed_crates
	return data

/obj/machinery/computer/trading_console/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("purchase")
			var/id = text2num(params["id"])
