/obj/structure/closet/crate/secure/trading
	name = "trading crate"
	desc = "Packages goods up so that they can be sold to other factions."
	var/unique_id = 0
	/// Who purchased the crate, null if it hasn't been purchased
	var/datum/bank_account/purchased_by = null
	/// Is this crate on the market yet?
	var/on_market = FALSE
	/// The price this is listed for
	var/listed_price

/obj/structure/closet/crate/secure/trading/New(loc, ...)
	. = ..()
	var/static/crate_count = 0
	unique_id = ++crate_count

/obj/structure/closet/crate/secure/trading/Destroy()
	SSeconomy.active_trades -= src
	return ..()

/obj/structure/closet/crate/secure/trading/togglelock(mob/living/user, silent)
	// Must own the crate to open it
	if (purchased_by)
		return
	// Can open and close unpurchased crates as you please
	..()
	if (!on_market && locked)
		to_chat(user, span_notice("You can now list this crate for sale by scanning it with a price tagger."))
		return

/obj/structure/closet/crate/secure/trading/proc/set_price(mob/living/user, obj/item/price_tagger/tagger)
	if (purchased_by)
		to_chat(user, span_warning("The crate has already been purchased, you no longer own it!"))
		return
	if (on_market)
		SSeconomy.active_trades -= src
		on_market = FALSE
	var/result = tgui_input_number(user, "What price would you like to list these items for?", "Set price", max_value = 100000)
	if (!result)
		to_chat(user, span_notice("You decide not to list the crate on the market."))
		return
	to_chat(user, span_notice("You list the crate on the market for a price of [result] credits."))
	SSeconomy.active_trades += src
	on_market = TRUE
	listed_price = result
