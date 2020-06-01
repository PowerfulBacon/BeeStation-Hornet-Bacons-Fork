//A set of resources / purchasable goods on the galactic market

/datum/galactic_market/resource_group
	var/name = ""
	var/list/resources	//Key = "resource name", value = resource datum
	var/resource_parent_datum = null
	var/buy_tax = 1.25	//Buying is more expensive.

	var/illegal = FALSE

/datum/galactic_market/resource_group/proc/generate_group_contents()
	if(isnull(resource_parent_datum))
		log_game("Galactic Market error: Resource group has no parent resource datum")
		return
	var/list/resource_datums = subtypesof(resource_parent_datum)
	resources = list()
	for(var/resource_datum in resource_datums)
		var/datum/galactic_market/resource/R = new resource_datum()
		R.category = src
		resources[R.resource_id] = R
	log_game("Loaded resource group [name] sucessfully.")

/datum/galactic_market/resource
	var/name = "Resource"
	var/desc = "A valuable resource found rarely across the galaxy."
	var/category = null
	var/resource_id = "resource"	//Just so there are definately no duplicates

	var/item_datum

	var/illegal = FALSE
	var/exists_in_db = FALSE

	//Cost Calculations
	var/market_fair_price = 10	//The price of the item if supply and demand are perfectly balanced
	var/base_supply_factor = 5000		//The value that the supply will drift towards over time if no sales happen.
										//If this is lower than the demand, the price will drift towards being higher and will be more stable for selling but not for buying and vice versa
	var/market_demand_factor = 5000		//The demand of this item (A constant that about equates to rarity) (The greater this value, the greater it will be affected by mass purchasing)

	//Production Calculations
	var/market_current_supply = 5000	//The current supply of the item (Starts as a constant but is persistant between rounds)
	var/supply_instability = 1			//How quickly the supply returns to it's default value (1 = supply is always base supply) (Higher values return slower and are more affected by mass buying)

	var/calculated_price = INFINITY

/datum/galactic_market/resource/New()
	. = ..()
	if(supply_instability == 0)
		log_runtime("Supply instability was set to 0 on the galactic resource [name]. Please change the config value of this.")
		supply_instability = 1
	update_resource()

/*
 * Oversupply causes price to reduce
 * Undersupply causes price to rise, the greater the difference the greater the increase in cost
 *
 * As the price rises, the supply increases due to mining being more worth
 * As the price drops, the supply decreases due to production being less valueable
*/

/datum/galactic_market/resource/proc/get_buy_tax()
	var/datum/galactic_market/resource_group/cat = category
	if(cat)
		return cat.buy_tax
	else
		return 1.25

/datum/galactic_market/resource/proc/update_resource()
	recalculate_supply()
	calculate_price()

/datum/galactic_market/resource/proc/calculate_price()
	calculated_price = (market_demand_factor / market_current_supply) * market_fair_price

// Calculate the supply value, the greater the difference in current supply and base supply, the greater the current supply will move towards the base supply.
/datum/galactic_market/resource/proc/recalculate_supply()
	if(market_current_supply <= 0)
		market_current_supply = 1
	var/percentage_difference = (base_supply_factor - market_current_supply) / market_current_supply
	market_current_supply += percentage_difference * (market_current_supply ** (1 / supply_instability))
