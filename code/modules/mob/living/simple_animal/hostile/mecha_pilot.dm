
/*
 Mecha Pilots!
 by Remie Richards

 Mecha pilot mobs are able to pilot Mecha to a rudimentary level
 This allows for certain mobs to be more of a threat (Because they're in a MECH)

 Mecha Pilots can either spawn with one, or steal one!

 (Inherits from syndicate just to avoid copy-paste)

 Featuring:
 * Mecha piloting skills
 * Uses Mecha equipment
 * Uses Mecha special abilities in specific situations
 * Pure Evil Incarnate

*/

/mob/living/carbon/human/mecha_pilot
	body_type = /datum/body/human/mecha_pilot
	var/spawn_mecha_type = /obj/mecha/combat/marauder/mauler/loaded

/mob/living/carbon/human/mecha_pilot/Initialize()
	. = ..()
	//Get syndie gear.
	var/datum/outfit/syndicate_empty/synd_empt = new()
	synd_empt.equip(src)
	//Spawn their mech.
	if(spawn_mecha_type)
		var/obj/mecha/M = new spawn_mecha_type (get_turf(src))
		//Force enter
		M.moved_inside(src)

/*
/mob/living/carbon/human/mecha_pilot/no_mech
	spawn_mecha_type = null
	search_objects = 2

/mob/living/carbon/human/mecha_pilot/no_mech/Initialize()
	. = ..()
	wanted_objects = typecacheof(/obj/mecha/combat, TRUE)

/mob/living/carbon/human/mecha_pilot/nanotrasen //nanotrasen are syndies! no it's just a weird path.
	name = "\improper Nanotrasen Mecha Pilot"
	desc = "Death to the Syndicate. This variant comes in MECHA DEATH flavour."
	icon_living = "nanotrasen"
	icon_state = "nanotrasen"
	faction = list("nanotrasen")
	spawn_mecha_type = /obj/mecha/combat/marauder/loaded

/mob/living/carbon/human/mecha_pilot/no_mech/nanotrasen
	name = "\improper Nanotrasen Mecha Pilot"
	desc = "Death to the Syndicate. This variant comes in MECHA DEATH flavour."
	icon_living = "nanotrasen"
	icon_state = "nanotrasen"
	faction = list("nanotrasen")
*/
