//===============================
// SYNDICATE LOADOUTS
// (Nanotrasen loadouts are just standard jobs)
//===============================

/datum/outfit/pvp
	name = "PVP Loadout"

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/pinpointer/nuke/syndicate
	id = /obj/item/card/id/syndicate
	belt = /obj/item/gun/ballistic/automatic/pistol
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
		/obj/item/kitchen/knife/combat/survival)

/datum/outfit/pvp/captain
	name = "PVP Syndicate Captain"

	head = /obj/item/clothing/head/helmet/space/beret
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	belt = /obj/item/storage/belt/sabre
	ears = /obj/item/radio/headset/syndicate/alt/leader
	r_pocket = /obj/item/melee/transforming/energy/sword/saber/red
	glasses = /obj/item/clothing/glasses/thermal/eyepatch

/datum/outfit/pvp/medic
	name = "PVP Syndicate Medic"

	head = /obj/item/clothing/head/beret/med
	glasses = /obj/item/clothing/glasses/hud/health/night
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
		/obj/item/kitchen/knife/combat/survival=1,\
		/obj/item/storage/firstaid/tactical=1)

/datum/outfit/pvp/engineer
	name = "PVP Syndicate Engineer"

	head = /obj/item/clothing/head/beret/eng
	glasses = /obj/item/clothing/glasses/welding
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
		/obj/item/kitchen/knife/combat/survival=1,\
		/obj/item/construction/rcd/combat=1,
		/obj/item/rcd_ammo/large=2)
