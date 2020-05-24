//Cross station market
//Gives a lot more dynamic to cargo
//One station is selling loads of resources? Buy them on the market while they are cheap,
//and sell them back at a higher price!

//Remember, Centcom still buys and sells materials, so alot of money can be made
//by buying things from the market and selling them to Centcom, but buying too much will
//drop the price, so its not exploitable forever.

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
