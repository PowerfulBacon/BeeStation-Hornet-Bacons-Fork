/obj/machinery/rnd/production/protolathe
	name = "protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe
	categories = list(
								CATEGORY_POWER,
								CATEGORY_MEDICAL,
								CATEGORY_BLUESPACE,
								CATEGORY_STOCK_PARTS,
								CATEGORY_EQUIPMENT,
								CATEGORY_TOOLS,
								CATEGORY_MINING,
								CATEGORY_ELECTRONICS,
								CATEGORY_WEAPONS,
								CATEGORY_AMMO,
								CATEGORY_COMPUTER_PARTS,
								CATEGORY_CIRCUITRY
								)
	production_animation = "protolathe_n"
	allowed_buildtypes = PROTOLATHE
	consoleless_interface = TRUE
	requires_console = FALSE

/obj/machinery/rnd/production/protolathe/disconnect_console()
	linked_console.linked_lathe = null
	..()
