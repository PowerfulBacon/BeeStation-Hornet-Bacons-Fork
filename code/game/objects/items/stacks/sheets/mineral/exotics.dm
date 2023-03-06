/**********************
Exotic mineral Sheets
	Contains:
		- Bananium
		- Adamantine
		- Alien Alloy
**********************/

/* Bananium */

/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-bananium"
	item_state = "sheet-bananium"
	singular_name = "bananium sheet"
	sheettype = "bananium"
	materials = list(/datum/material/bananium=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/consumable/banana = 20)
	point_value = 50
	merge_type = /obj/item/stack/sheet/mineral/bananium

/obj/item/stack/sheet/mineral/bananium/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.bananium_recipes
	. = ..()


/* Adamantine */

/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	item_state = "sheet-adamantine"
	singular_name = "adamantine sheet"
	merge_type = /obj/item/stack/sheet/mineral/adamantine
	grind_results = list(/datum/reagent/liquidadamantine = 10)
