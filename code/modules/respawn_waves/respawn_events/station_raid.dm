/datum/respawn_event/station_raid
	var/points_remaining = 0

/datum/respawn_event/station_raid/generate_mob(turf/spawn_location, client/candidate)
	var/mob/living/carbon/human/created_mob = new(spawn_location)

/datum/outfit/raider
	name = "Station Raider (Unequipped)"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/space/syndicate
	mask = /obj/item/clothing/suit/space/syndicate
