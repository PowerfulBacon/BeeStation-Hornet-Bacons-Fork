/mob/living/carbon/alien/get_eye_protection()
	return ..() + 2 //potential cyber implants + natural eye protection

/mob/living/carbon/alien/get_ear_protection()
	return 2 //no ears

/mob/living/carbon/alien/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..(AM, skipcatch = TRUE, hitpush = FALSE)


/*Code for aliens attacking aliens. Because aliens act on a hivemind, I don't see them as very aggressive with each other.
As such, they can either help or harm other aliens. Help works like the human help command while harm is a simple nibble.
In all, this is a lot like the monkey code. /N
*/
/mob/living/carbon/alien/attack_alien(mob/living/carbon/alien/M)
	if(isturf(loc) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	switch(M.a_intent)
		if("help")
			if(M == src && check_self_for_injuries())
				return
			set_resting(FALSE)
			AdjustStun(-60)
			AdjustKnockdown(-60)
			AdjustImmobilized(-60)
			AdjustParalyzed(-60)
			AdjustUnconscious(-60)
			AdjustSleeping(-100)
			visible_message("<span class='notice'>[M.name] nuzzles [src] trying to wake [p_them()] up!</span>")

		if("grab")
			grabbedby(M)

		else
			if(health > 1)
				M.do_attack_animation(src, ATTACK_EFFECT_BITE)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M.name] playfully bites [src]!</span>", \
						"<span class='userdanger'>[M.name] playfully bites you!</span>", null, COMBAT_MESSAGE_RANGE)
				apply_damage(/datum/damage_source/blunt/light, BRUTE, 1)
				log_combat(M, src, "attacked")
			else
				to_chat(M, "<span class='warning'>[name] is too injured for that.</span>")


/mob/living/carbon/alien/larva_attack_intercept(mob/living/carbon/alien/larva/L)
	return attack_alien(L)

/mob/living/carbon/alien/attack_paw(mob/living/carbon/monkey/M)
	if(!..())
		return
	if(stat != DEAD)
		M.deal_generic_attack(src)

/mob/living/carbon/alien/attack_hand(mob/living/carbon/human/M)
	if(..())	//to allow surgery to return properly.
		return

	switch(M.a_intent)
		if("harm", "disarm") //harm and disarm will do the same, I doubt trying to shove a xeno would go well for you
			if(HAS_TRAIT(M, TRAIT_PACIFISM))
				to_chat(M, "<span class='notice'>You don't want to hurt [src]!</span>")
				return
			playsound(loc, "punch", 25, 1, -1)
			visible_message("<span class='danger'>[M] punches [src]!</span>", \
					"<span class='userdanger'>[M] punches you!</span>", null, COMBAT_MESSAGE_RANGE)
			apply_damage(M.dna.species.damage_source_type, M.dna.species.damage_type, M.dna.species.punchdamage, ran_zone(M.zone_selected))
			log_combat(M, src, "attacked")
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)

		if("help")
			M.visible_message("<span class='notice'>[M] hugs [src] to make [src.p_them()] feel better!</span>", \
								"<span class='notice'>You hug [src] to make [src.p_them()] feel better!</span>")
			playsound(M.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if("grab")
			grabbedby(M)

/mob/living/carbon/alien/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	. = ..()
	if(QDELETED(src))
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
			return

		if(EXPLODE_HEAVY)
			take_overall_damage(60, 60)
			adjustEarDamage(30,120)

		if(EXPLODE_LIGHT)
			take_overall_damage(30,0)
			if(prob(50))
				Unconscious(20)
			adjustEarDamage(15,60)

/mob/living/carbon/alien/soundbang_act(intensity = 1, stun_pwr = 20, damage_pwr = 5, deafen_pwr = 15)
	return FALSE

/mob/living/carbon/alien/acid_act(acidpwr, acid_volume)
	return FALSE//aliens are immune to acid.
