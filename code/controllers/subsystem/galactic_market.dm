/*
 * Cross station market
 * Gives a lot more dynamic to cargo
 * One station is selling loads of resources? Buy them on the market while they are cheap,
 * and sell them back at a higher price!
 *
 * Remember, Centcom still buys and sells materials, so alot of money can be made
 * by buying things from the market and selling them to Centcom, but buying too much will
 * drop the price, so its not exploitable forever.
 *
 *
 * === REALLY BORING MATHS I SPENT TOO LONG DOING, JUST TO AVOID AN EXPENSIVE FOR LOOP ===
 *
 * So the price of each object is calculated by y = dpx^{-1}
 * where y = price
 * x = quantity
 * and d and p are constants (d = demand value, p = price factor)
 *
 * If you want to find out how much buying multiple costs, you cannot
 * just do cost for 1 at price * amount, since the more you buy, the
 * more expensive each unit gets.
 *
 * In the equation we need to make, the gradient is the price at the contents
 * value, which is the previous equation
 *
 * To get the cumulative cost of items, we simple need to integrate and then
 * do some shit to the graph
 * y = dpln(x) + C (where C is an unknown constant)
 * would be the integral of the graph, however this only accounts
 * for the cost of the item / material starting at 0, and since its a 1/x
 * graph, the cost at 0 starts at a number that is undefined, but practically infinity
 * but its not infinity.
 * To offset this value, we need to find the point at which on the integral graph
 * the amount we want crosses the x axis point (amount, 0) lies on the graph
 * y = dpln(x) + C
 * y = 0, x = a (starting amount)
 * 0 = dpln(a) + C
 * C = -dpln(a)
 *
 * This gives us: y=dpln(x)-dpln(a)
 * (This is relative to the final amount of resources on the market)
 * To make this relative to the amount we are buying and selling, we simply
 * translate the graph to the left by the amount giving us
 * y=dpln(x+a)-dpln(a)
 * Where y = cost of order
 * x = amount ordering (or selling (in which case it is negative))
 * a = current amount on market
 * and d and p are the constant values from earlier.
 *
 * quite simple actually
 *
 * =======================================================
 * ======================Handling=========================
 * =======================================================
 * Buying:
 * Buying is pretty simple, upon buying things, put it in a reserver
 * and shove it on the supply shuttle when it docks.
 *
 * Selling:
 * The galactic market console and supply console can now send the ship
 * to 2 locations. Sending it to centcom, sells to centcom.
 * Sending to the galactic market hub, sells to the market.
 * If the ship is sent to the market hub it cannot collect centcom goods,
 * but can travel to centcom much quicker.
 *
*/

#define DATABASE_REFRESH_TIME 5 SECONDS

GLOBAL_VAR_INIT(last_db_refresh, 0)

SUBSYSTEM_DEF(galactic_market)
	name = "Galactic Market"
	priority = FIRE_PRIORITY_MARKET
	wait = 5 MINUTES	//The galactic market updates every 5 minutes.

	var/list/resource_groups = list()	//Key = "group name" value = resource gruop
	var/using_database = TRUE

/datum/controller/subsystem/galactic_market/Initialize(timeofday)
	if(!CONFIG_GET(flag/market_enabled))
		qdel(src)
		return FALSE
	generate_resource_groups()
	if(CONFIG_GET(flag/market_never_use_db) || !SSdbcore.Connect())
		using_database = FALSE
		log_game("Galactic Market initialisation failed(Code:4); using local server files.")
	else
		check_database()
	read_galactic_market()	//Access data from the galactic market
	return ..()

//Update the market for supply
//Notice: This occurs across all servers and should take into account this
/datum/controller/subsystem/galactic_market/fire()
	//Check if another server has updated the market recently
	return

//==============Setup - Get all resource groups==============
/datum/controller/subsystem/galactic_market/proc/generate_resource_groups()
	for(var/category_datum in subtypesof(/datum/galactic_market/resource_group))
		var/datum/galactic_market/resource_group/new_resource = new category_datum()
		new_resource.generate_group_contents()
		resource_groups[new_resource.name] = new_resource

//==============Database Checks================
//Access the database and see if it has the tables to support
//Galactic market. If not, create new tables for it

/datum/controller/subsystem/galactic_market/proc/check_database()
	GLOB.last_db_refresh = world.time
	var/datum/DBQuery/query_validate_database_existance = SSdbcore.NewQuery("SELECT 1 FROM [format_table_name("galactic_market_resources")] LIMIT 1")
	query_validate_database_existance.Execute()
	if(!query_validate_database_existance.warn_execute())
		using_database = FALSE
		qdel(query_validate_database_existance)
		log_game("Galactic Market initialisation failed (Code:5); using local server files.")
		return
	else
		qdel(query_validate_database_existance)
	if(!validate_resource_groups())
		using_database = FALSE
		return
	//Validate the table data, make sure all resources / purchasable items are being tracked
	log_game("Galactic Market using database, checks successful.")

/datum/controller/subsystem/galactic_market/proc/validate_resource_groups()
	read_galactic_market_from_db()
	var/sql_query = "INSERT INTO [format_table_name("galactic_market_resources")] (\
		resource_type,\
		resource_category,\
		resource_amount\
	)\
	VALUES"
	var/sql_needed = FALSE
	for(var/group_key in resource_groups)
		var/datum/galactic_market/resource_group/RG = resource_groups[group_key]
		for(var/resource_key in RG.resources)
			var/datum/galactic_market/resource/R = RG.resources[resource_key]
			if(R.exists_in_db)
				continue
			if(sql_needed)
				sql_query += "),"
			else
				sql_needed = TRUE
			sql_query += "(\
				'[R.resource_id]',\
				'[RG.name]',\
				'[R.base_supply_factor]'"
			log_game("Validating [R.resource_id]")
	if(!sql_needed)
		log_game("Galactic Market up to date!")
		return TRUE
	sql_query += ");"
	var/datum/DBQuery/query_fill_database = SSdbcore.NewQuery(sql_query)
	if(!query_fill_database.warn_execute())
		qdel(query_fill_database)
		log_game("Failed to validate galactic market resources, falling back to local file GM.")
		return FALSE
	qdel(query_fill_database)
	return TRUE

//================Altering data================
/*
 *This writes the current resource amount to the market
 *Using this is dangerous, since it assumes the resource has it's amount synced already
*/
/datum/controller/subsystem/galactic_market/proc/update_market_supply(datum/galactic_market/resource/R)
	if(using_database)
		if(!SSdbcore.Connect())
			message_admins("Failed to establish database connection, galactic market will not be cross server.")
			using_database = FALSE
			update_market_supply(R)
			return
		var/datum/DBQuery/query_write_resource = SSdbcore.NewQuery("UPDATE [format_table_name("galactic_market_resources")] SET resource_amount = [R.market_current_supply] WHERE resource_type = [R.resource_id]")
		query_write_resource.Execute()
		qdel(query_write_resource)
	else
		return

//The reason this is estimate is because the market could have been updated
//while we were fucking about in the computer
//amount_change : (POSITIVE IS SELLING TO MARKET, NEGATIVE IS BUYING FROM) (amount_change is the amount of resource change from the markets perspective)
//Output: The amount of money that you will make from the purchase (negative for costing)
//These are not interchangeable, as buying 10 costs a different amount to selling 10
//Positive - Round down
//Negative - Round up (we always scam the crew, never the market)
/datum/controller/subsystem/galactic_market/proc/estimate_delta_money(datum/galactic_market/resource/R, amount_change)
	var/exact_value = (R.market_demand_factor * R.market_fair_price * log(amount_change + R.market_current_supply)) - (R.market_demand_factor * R.market_fair_price * log(R.market_current_supply))
	if(exact_value > 0)
		return FLOOR(exact_value, 1)
	return FLOOR(exact_value + 0.9999, 1)

/datum/controller/subsystem/galactic_market/proc/estimate_cost(datum/galactic_market/resource/R, amount_buying)
	return estimate_delta_money(R, -amount_buying)

//Reads it first before calculating the cost
/datum/controller/subsystem/galactic_market/proc/calculate_delta_money(datum/galactic_market/resource/R, amount_change)
	read_galactic_market()
	estimate_delta_money(R, amount_change)

//================Reading the market data================

/datum/controller/subsystem/galactic_market/proc/read_galactic_market()
	if(using_database)
		if(!SSdbcore.Connect())
			message_admins("Failed to establish database connection, galactic market will not be cross server.")
			using_database = FALSE
			return read_galactic_market_from_file()
		return read_galactic_market_from_db()
	else
		return read_galactic_market_from_file()

/datum/controller/subsystem/galactic_market/proc/read_galactic_market_from_db()
	var/datum/DBQuery/query_read_resource = SSdbcore.NewQuery("SELECT resource_type, resource_category, resource_amount FROM [format_table_name("galactic_market_resources")]")
	if(!query_read_resource.warn_execute())
		qdel(query_read_resource)
		return
	while(query_read_resource.NextRow())
		var/resource_type = query_read_resource.item[1]
		var/resource_category = query_read_resource.item[2]
		var/resource_amount = query_read_resource.item[3]

		var/datum/galactic_market/resource_group/resource_category_datum = resource_groups[resource_category]
		if(!resource_category_datum)
			continue
		var/datum/galactic_market/resource/resource_datum = resource_category_datum.resources[resource_type]
		if(!resource_datum)
			continue
		resource_datum.market_current_supply = resource_amount
		resource_datum.exists_in_db = TRUE
	qdel(query_read_resource)

/datum/controller/subsystem/galactic_market/proc/read_galactic_market_from_file()
	return
