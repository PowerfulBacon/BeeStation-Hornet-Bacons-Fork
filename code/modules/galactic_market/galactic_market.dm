
//Actually, this should be a subsystem

GLOBAL_DATUM_INIT(galactic_market_datum, /datum/galactic_market/galactic_market_manager, new)

/datum/galactic_market/galactic_market_manager
	var/list/resource_groups	//Key = "group name" value = resource gruop
	var/using_database = TRUE

/datum/galactic_market/New()
	. = ..()

/datum/galactic_market/proc/read_galactic_market()
	if(using_database)
		if(!SSdbcore.Connect())
			using_database = FALSE
			return read_galactic_market_from_file()
		return read_galactic_market_from_db()
	else
		return read_galactic_market_from_file()

/datum/galactic_market/proc/read_galactic_market_from_db()
	var/datum/DBQuery/query_read_resource = SSdbcore.NewQuery("SELECT resource_type, resource_category, resource_supply FROM [format_table_name("galactic_market_resources")]")
	if(query_read_resource.last_error)
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
	qdel(query_read_resource)

/datum/galactic_market/proc/read_galactic_market_from_file()
	return
