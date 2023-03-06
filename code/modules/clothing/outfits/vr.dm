/datum/outfit/vr
	name = "Basic VR"
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/sneakers/black
	ears = /obj/item/radio/headset
	id = /obj/item/card/id

/datum/outfit/vr/pre_equip(mob/living/carbon/human/H)
	H.dna.species.before_equip_job(null, H)

/datum/outfit/vr/post_equip(mob/living/carbon/human/H)
	var/obj/item/card/id/id = H.wear_id
	if (istype(id))
		id.access |= get_all_accesses()

/obj/item/paper/fluff/vr/fluke_ops
	name = "Where is my uplink?"
	info = "Use the radio in your backpack."
