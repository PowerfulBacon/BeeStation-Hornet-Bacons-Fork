/datum/job/volkova_miner
	title = JOB_VOLKOVA_MINER
	description = "You belong to the Volkova extraction group, a company specialising in the extraction of rare minerals. Your job is to collect resources and sell them to Nanotrasen to turn as big a profit as possible."
	department_for_prefs = DEPT_NAME_VOLKOVA
	department_head = list(JOB_VOLKOVA_LEADER)
	supervisors = "the Volkova colony director"
	faction = "Volkova"
	total_positions = 3
	spawn_positions = 2
	selection_color = "#b1644a"
	// This role is high intensity, off-station and has immediate access to guns
	// we'll lock new players out of it so that they get a chance to learn the game
	// first for at least 1 round.
	exp_requirements = 60
	exp_type = EXP_TYPE_LIVING

	outfit = /datum/outfit/job/volkova_miner

	base_access = list()
	extra_access = list()

	departments = DEPT_BITFLAG_VOLKOVA
	bank_account_department = ACCOUNT_ENG_BITFLAG
	payment_per_department = list(ACCOUNT_VOL_ID = PAYCHECK_VOLKOVA_HEAD)

	display_order = JOB_DISPLAY_ORDER_VOLKOVA_MINER
	rpg_title = "Volcanist"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/atmospherics
	)

/datum/outfit/job/volkova_miner
	name = JOB_VOLKOVA_MINER
	jobtype = /datum/job/volkova_miner

	id = /obj/item/card/id/job/shaft_miner
	belt = /obj/item/modular_computer/tablet/pda/shaft_miner
	ears = /obj/item/radio/headset/headset_cargo/shaft_miner
	shoes = /obj/item/clothing/shoes/workboots/mining
	gloves = /obj/item/clothing/gloves/color/black
	uniform = /obj/item/clothing/under/volkva
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/survival
	r_pocket = /obj/item/storage/bag/ore
	backpack_contents = list(
		/obj/item/flashlight/seclite=1,\
		/obj/item/knife/combat/survival=1,\
		/obj/item/mining_voucher=1,\
		/obj/item/stack/marker_beacon/ten=1,\
		/obj/item/discovery_scanner=1)

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag
	box = /obj/item/storage/box/survival/mining

	chameleon_extras = /obj/item/gun/energy/recharge/kinetic_accelerator
