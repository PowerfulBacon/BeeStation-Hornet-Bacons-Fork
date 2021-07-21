
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

/*/mob/living/carbon/human/mecha_pilot
	name = "Syndicate Mecha Pilot"
	desc = "Death to Nanotrasen. This variant comes in MECHA DEATH flavour."
	wanted_objects = list()
	search_objects = 0
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)

	var/spawn_mecha_type = /obj/mecha/combat/marauder/mauler/loaded
	var/obj/mecha/mecha //Ref to pilot's mecha instance
	var/required_mecha_charge = 7500 //If the pilot doesn't have a mecha, what charge does a potential Grand Theft Mecha need? (Defaults to half a battery)
	var/mecha_charge_evacuate = 50 //Amount of charge at which the pilot tries to abandon the mecha

	//Vars that control when the pilot uses their mecha's abilities (if the mecha has that ability)
	var/threat_use_mecha_smoke = 5 //5 mobs is enough to engage crowd control
	var/defense_mode_chance = 35 //Chance to engage Defense mode when damaged
	var/smoke_chance = 20 //Chance to deploy smoke for crowd control
	var/retreat_chance = 40 //Chance to run away

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


/mob/living/carbon/human/mecha_pilot/Initialize()
	. = ..()
	if(spawn_mecha_type)
		var/obj/mecha/M = new spawn_mecha_type (get_turf(src))
		if(istype(M))
			enter_mecha(M)

//Pick a ranged weapon/tool
//Fire it
/mob/living/carbon/human/mecha_pilot/OpenFire(atom/A)
	if(mecha)
		mecha_reload()
		mecha_face_target(A)
		var/list/possible_weapons = get_mecha_equip_by_flag(MECHA_RANGED)
		if(possible_weapons.len)
			var/obj/item/mecha_parts/mecha_equipment/ME = pick(possible_weapons) //so we don't favor mecha.equipment[1] forever
			if(ME.action(A))
				ME.start_cooldown()
				return

	else
		..()


/mob/living/carbon/human/mecha_pilot/AttackingTarget(mob/living/clicked_on)
	if(mecha)
		var/list/possible_weapons = get_mecha_equip_by_flag(MECHA_MELEE)
		if(possible_weapons.len)
			var/obj/item/mecha_parts/mecha_equipment/ME = pick(possible_weapons)
			mecha_face_target(target)
			if(ME.action(target))
				ME.start_cooldown()
				return

		if(mecha.melee_can_hit)
			mecha_face_target(target)
			target.mech_melee_attack(mecha)
	else
		if(ismecha(target))
			var/obj/mecha/M = target
			if(is_valid_mecha(M))
				enter_mecha(M)
				return
			else
				if(!CanAiAttack(M))
					LoseTarget()
					return

		return target.attack_animal(src)

/mob/living/carbon/human/mecha_pilot/death(gibbed)
	if(mecha)
		mecha.aimob_exit_mech(src)
	..()

/mob/living/carbon/human/mecha_pilot/gib()
	if(mecha)
		mecha.aimob_exit_mech(src)
	..()


//Yes they actually try and pull this shit
//~simple animals~
/mob/living/carbon/human/mecha_pilot/CanAiAttack(atom/the_target)
	if(ismecha(the_target))
		var/obj/mecha/M = the_target
		if(mecha)
			if(M == mecha || !CanAiAttack(M.occupant))
				return 0
		else //we're not in a mecha, so we check if we can steal it instead.
			if(is_valid_mecha(M))
				return 1
			else if (M.occupant && CanAiAttack(M.occupant))
				return 1
			else
				return 0

	. = ..()
*/
