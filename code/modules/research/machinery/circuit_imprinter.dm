/obj/machinery/rnd/production/circuit_imprinter
	name = "circuit imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	circuit = /obj/item/circuitboard/machine/circuit_imprinter
	categories = list(
								CATEGORY_AI_MODULES,
								CATEGORY_COMPUTER_BOARDS,
								CATEGORY_TELEPORTATION,
								CATEGORY_MEDICAL,
								CATEGORY_ENGINEERING,
								CATEGORY_EXOSUIT_MODULES,
								CATEGORY_HYDROPONICS,
								CATEGORY_TCOMM,
								CATEGORY_RESEARCH,
								CATEGORY_MACHINERY,
								CATEGORY_COMPUTER_PARTS,
								CATEGORY_SHUTTLE_MACHINERY,
								CATEGORY_CIRCUITRY
								)
	production_animation = "circuit_imprinter_ani"
	allowed_buildtypes = IMPRINTER
	consoleless_interface = TRUE
	requires_console = FALSE

/obj/machinery/rnd/production/circuit_imprinter/disconnect_console()
	linked_console.linked_imprinter = null
	..()

/obj/machinery/rnd/production/circuit_imprinter/calculate_efficiency()
	. = ..()
	var/total_rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating += M.rating * 2			//There is only one.
	total_rating = max(1, total_rating)
	efficiency_coeff = total_rating
