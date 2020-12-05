/datum/reagent/admin
	name = "Admin Juice"
	taste_description = "something higher than yourself"
	can_synth = FALSE

/datum/reagent/admin/singularity
	name = "Micro Singularity"
	taste_description = "density"
	can_synth = FALSE

/datum/reagent/admin/singularity/on_mob_metabolize(mob/living/L)
	. = ..()
	to_chat(L, "<span class='userdanger'>You feel an intense pain from inside.</span>")

// ===============
// Adminordrazine - Used in godmode.
// ===============

/datum/reagent/admin/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	description = "It's magic. We don't have to explain it"
	color = "#C8A5DC" // rgb: 200, 165, 220
	can_synth = FALSE
	taste_description = "badmins"

/datum/reagent/admin/adminordrazine/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_NODEATH, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_CONFUSEIMMUNE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_PUSHIMMUNE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_SHOCKIMMUNE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_RESISTCOLD, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_RESISTHEAT, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_RESISTHIGHPRESSURE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_RESISTLOWPRESSURE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_RADIMMUNE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_PIERCEIMMUNE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_NOFIRE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_NODISMEMBER, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_TOXIMMUNE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_NOLIMBDISABLE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_ANTIMAGIC, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_NOCRITDAMAGE, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_NOHARDCRIT, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_NOSOFTCRIT, ADMINORDRAZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_NOSTAMCRIT,ZINE_TRAIT)
	ADD_TRAIT(L, TRAIT_STRONG_GRABBER, ADMINORDRAZINE_TRAIT)

/datum/reagent/admin/adminordrazine/on_mob_end_metabolize(mob/living/L)
	. = ..()
	REMOVE_TRAIT(L, TRAIT_NODEATH, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_CONFUSEIMMUNE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_PUSHIMMUNE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_SHOCKIMMUNE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_RESISTCOLD, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_RESISTHEAT, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_RESISTHIGHPRESSURE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_RESISTLOWPRESSURE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_RADIMMUNE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_PIERCEIMMUNE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOFIRE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NODISMEMBER, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_TOXIMMUNE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOLIMBDISABLE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_ANTIMAGIC, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOCRITDAMAGE, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOHARDCRIT, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOSOFTCRIT, ADMINORDRAZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOSTAMCRIT,ZINE_TRAIT)
	REMOVE_TRAIT(L, TRAIT_STRONG_GRABBER, ADMINORDRAZINE_TRAIT)

/datum/reagent/admin/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
	M.setCloneLoss(0, 0)
	M.setOxyLoss(0, 0)
	M.radiation = 0
	M.heal_bodypart_damage(20,20)
	M.adjustToxLoss(-5, 0, TRUE)
	M.hallucination = 0
	REMOVE_TRAITS_NOT_IN(M, list(SPECIES_TRAIT, ROUNDSTART_TRAIT, ORGAN_TRAIT, ADMINORDRAZINE_TRAIT))
	M.set_blurriness(0)
	M.set_blindness(0)
	M.SetKnockdown(0, FALSE)
	M.SetStun(0, FALSE)
	M.SetUnconscious(0, FALSE)
	M.SetParalyzed(0, FALSE)
	M.SetImmobilized(0, FALSE)
	M.silent = FALSE
	M.dizziness = 0
	M.disgust = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.slurring = 0
	M.confused = 0
	M.SetSleeping(0, 0)
	M.jitteriness = 0
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = BLOOD_VOLUME_NORMAL
	M.cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
	for(var/organ in M.internal_organs)
		var/obj/item/organ/O = organ
		O.setOrganDamage(0)
	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.severity == DISEASE_SEVERITY_BENEFICIAL || D.severity == DISEASE_SEVERITY_POSITIVE)
			continue
		D.cure()
	..()
	. = 1

/datum/reagent/admin/adminordrazine/quantum_heal
	name = "Quantum Medicine"
	description = "Rare and experimental particles, that apparently swap the user's body with one from an alternate dimension where it's completely healthy."
	taste_description = "science"
