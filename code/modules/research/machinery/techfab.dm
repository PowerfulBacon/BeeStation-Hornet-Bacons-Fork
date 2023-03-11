/obj/machinery/rnd/production/techfab
	name = "technology fabricator"
	desc = "Produces researched prototypes with raw materials and energy."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/techfab
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
								CATEGORY_CIRCUITRY
								)
	console_link = FALSE
	production_animation = "protolathe_n"
	requires_console = FALSE
	consoleless_interface = TRUE
	allowed_buildtypes = PROTOLATHE | IMPRINTER
