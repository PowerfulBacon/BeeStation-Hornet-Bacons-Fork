/* Bananium */

GLOBAL_LIST_INIT(bananium_recipes, list ( \
	new/datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	new/datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = TRUE, on_floor = TRUE), \
	))

STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/bananium)


STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/adamantine)


STACKSIZE_MACRO(/obj/item/stack/sheet/mineral/abductor)
