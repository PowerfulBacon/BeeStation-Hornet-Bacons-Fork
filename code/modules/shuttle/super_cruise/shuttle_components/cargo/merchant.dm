/datum/merchant
	/// Can this merchant purchase things from the ship?
	var/can_buy = TRUE
	/// Export categories
	var/export_categories = EXPORT_CARGO

/datum/merchant/proc/sell_item(atom/movable/item)
	// Calculate value and check blacklist
	for (var/atom/movable/content in item.GetAllContents())
		if(is_type_in_typecache(content, GLOB.blacklisted_cargo_types))
			return FALSE
	var/turf/money_delivery = get_turf(item)
	var/datum/export_report/ex = new
	// Perform export
	bounty_ship_item_and_contents(item, FALSE)
	if (!item.anchored || istype(item, /obj/mecha))
		export_item_and_contents(item, export_categories, dry_run = FALSE, external_report = ex)
	else
		export_contents(item, export_categories, dry_run = FALSE, external_report = ex)
	// Deliver the money
	var/value = 0
	for(var/datum/export/E in ex.total_amount)
		value += ex.total_value[E]
	if (value)
		new /obj/item/holochip(money_delivery, value)
	return TRUE
