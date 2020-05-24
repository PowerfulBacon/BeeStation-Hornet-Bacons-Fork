//Materials:
//Materials should be stupid to buy on the galactic market, making it better to mine/buy and process into better goods
//otherwise cargo will just sell all the mats for money

//To achieve this most materials have a lower demand than supply, meaning they will drift towards being cheaper.
//To not completely invalidate mining, most rarer resources are very unstable
//and the market will quickly collapse if they are bought on mass, making it unviable

/datum/galactic_market/resource_group/materials
	name = "Materials"
	resource_parent_datum = /datum/galactic_market/resource/material

/datum/galactic_market/resource/material
	category = "Materials"
	desc = "cm3 of unobtainium."
	var/material_id = null

/datum/galactic_market/resource/material/bananium
	name = "Bananium"
	resource_id = "s_bananium"
	material_id = null
	market_fair_price = 1000	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 300
	market_demand_factor = 320
	supply_instability = 2.3
	illegal = TRUE

/datum/galactic_market/resource/material/diamond
	name = "Diamond"
	resource_id = "s_diamond"
	material_id = null
	market_fair_price = 500	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 500
	market_demand_factor = 500
	supply_instability = 1.8

//Plasma is highly unstable, but pretty common on lavaland
//So market crashes shouldn't be too easy
/datum/galactic_market/resource/material/plasma
	name = "Plasma"
	resource_id = "s_plasma"
	material_id = null
	market_fair_price = 90	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 1500
	market_demand_factor = 5000
	supply_instability = 1.6

/datum/galactic_market/resource/material/uranium
	name = "Uranium"
	resource_id = "s_uranium"
	material_id = null
	market_fair_price = 100	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 2000
	market_demand_factor = 2000
	supply_instability = 1.5

/datum/galactic_market/resource/material/gold
	name = "Gold"
	resource_id = "s_gold"
	material_id = null
	market_fair_price = 120	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 2000
	market_demand_factor = 2000
	supply_instability = 1.5

/datum/galactic_market/resource/material/copper
	name = "Copper"
	resource_id = "s_copper"
	material_id = null
	market_fair_price = 15	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 20000
	market_demand_factor = 20000
	supply_instability = 1.2

/datum/galactic_market/resource/material/silver
	name = "Silver"
	resource_id = "s_silver"
	material_id = null
	market_fair_price = 50	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 15000
	market_demand_factor = 15000
	supply_instability = 1.15

/datum/galactic_market/resource/material/titanuim
	name = "Titanium"
	resource_id = "s_titanium"
	material_id = null
	market_fair_price = 125	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 12000
	market_demand_factor = 12000
	supply_instability = 1.24

/datum/galactic_market/resource/material/iron
	name = "Iron Sheets"
	resource_id = "s_iron"
	material_id = null
	market_fair_price = 5	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 20000
	market_demand_factor = 20000
	supply_instability = 1.1

/datum/galactic_market/resource/material/glass
	name = "Glass Sheets"
	resource_id = "s_glass"
	material_id = null
	market_fair_price = 5	//The price of the item if supply and demand are perfectly balanced
	base_supply_factor = 20000
	market_demand_factor = 20000
	supply_instability = 1.1
