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

	id = /obj/item/card/id/job/atmospheric_technician
	belt = /obj/item/storage/belt/utility/atmostech
	l_pocket = /obj/item/modular_computer/tablet/pda/atmospheric_technician
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	r_pocket = /obj/item/analyzer

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer
	pda_slot = ITEM_SLOT_LPOCKET
