/*
 Mecha Pilots!
 by Remie Richards

 Updated to brain AI by powerfulbacon.
 Using the new type, the mecha pilot mob is assumed to be a human. They will attempt to hack and enter mechs and robust anyone around them with their MECH.

 Will try to hack and enter nearby mechs.
 Will use the mech for combat.
 Will attack using its strongest weapon.

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

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot
	var/obj/mecha/mecha //Ref to pilot's mecha instance

	var/mech_breaches_walls = FALSE

	var/required_mecha_charge = 7500 //If the pilot doesn't have a mecha, what charge does a potential Grand Theft Mecha need? (Defaults to half a battery)
	var/mecha_charge_evacuate = 50 //Amount of charge at which the pilot tries to abandon the mecha

	//Vars that control when the pilot uses their mecha's abilities (if the mecha has that ability)
	var/threat_use_mecha_smoke = 5 //5 mobs is enough to engage crowd control
	var/defense_mode_chance = 35 //Chance to engage Defense mode when damaged
	var/smoke_chance = 20 //Chance to deploy smoke for crowd control
	var/retreat_chance = 40 //Chance to run away

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/handle_ai(mob/living/L)
	//Update mech
	if(istype(L.loc, /obj/mecha))
		if(!mecha)
			mecha = L.loc
			allow_movement_on_non_turfs = TRUE
			L.targets_from = WEAKREF(mecha)
			//Check mecha force
			if(mecha.force > 20 || mecha.phasing_action?.owner)
				//We can go through walls now
				ai_autowalk_ignore_walls = TRUE
				mech_breaches_walls = TRUE
			//Check ranged weapons
			if(get_mecha_equip_by_flag(MECHA_RANGED))
				is_ranged_mob = TRUE
				minimum_distance = 5
			//Enable mecha internals
			if(!mecha.use_internal_tank && mecha.internals_action?.owner)
				mecha.internals_action.Activate()
			//Enable mecha light
			if(!mecha.light_range && mecha.lights_action?.owner)
				mecha.lights_action.Activate()
	else if(mecha)
		L.targets_from = null
		mecha = null
		is_ranged_mob = FALSE
		minimum_distance = 1
		allow_movement_on_non_turfs = FALSE
		ai_autowalk_ignore_walls = FALSE
		mech_breaches_walls = FALSE
	//Do normal stuff
	. = ..()

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/handle_automated_movement(mob/living/L)
	//If idle and in a damaged mech, get out and repair it before getting back in.
	if(AIStatus == AI_IDLE && mecha && mecha.obj_integrity < mecha.max_integrity*0.75)
		//Get out.
		//Repair.
		//Get back in.
		return
	. = ..()

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/handle_automated_action(mob/living/L)
	if(!mecha && ishuman(L) && !istype(target, /obj/mecha))
		for(var/obj/mecha/combat/C in view(owner_body.get_ai_vision_range(), L))
			if(is_valid_mecha(C))
				L.say(pick("Spotted my new ride.", "Moving to exosuit.", "Securing exosuit.", "Got myself a new ride boys."))
				GiveTarget(C)
				minimum_distance = 1
				is_ranged_mob = FALSE
				break
	if(mecha)
		var/list/possible_threats = PossibleThreats(L)
		var/threat_count = possible_threats.len

		var/can_eject = mecha.eject_action?.owner

		//Low Charge - Eject
		if(!mecha.has_charge(mecha_charge_evacuate) && can_eject)
			L.say(pick(\
				"Got critical charge here, going to have to eject!",\
				"Bingo power, ejecting.",\
				"That's all I had left."\
			))
			mecha.eject_action.Activate()
			return

		//Too Much Damage - Eject
		if(mecha.obj_integrity < mecha.max_integrity*0.1)
			L.say(pick(\
				"I am critically hit, got to eject.",\
				"Shit, going down.",\
				"Ejecting, cover me!"\
			))
			mecha.eject_action.Activate()
			return

		//Smoke if there's too many targets	- Smoke Power
		if(threat_count >= threat_use_mecha_smoke && prob(smoke_chance))
			if(mecha.smoke_action && mecha.smoke_action.owner && mecha.smoke)
				L.say(pick(\
					"Shit, got a lot of them on me, need backup.",\
					"Popping smokes.",\
					"I need backup here.",\
					"Under heavy fire, I can't do this alone.",\
					"More than I can fucking count here, popping a smoke screen."\
				))
				mecha.smoke_action.Activate()

		//Heavy damage - Defense Power or Retreat
		if(mecha.obj_integrity < mecha.max_integrity*0.25)
			if(prob(defense_mode_chance))
				if(mecha.defense_action && mecha.defense_action.owner && !mecha.defense_mode)
					L.say(pick(\
						"Shields online.",\
						"Taking heavy fire, engaging shields.",\
						"Let's see if they can hit me now."\
					))
					mecha.leg_overload_mode = 0
					mecha.defense_action.Activate(TRUE)
					addtimer(CALLBACK(mecha.defense_action, /datum/action/innate/mecha/mech_defense_mode.proc/Activate, FALSE), 100) //10 seconds of defense, then toggle off

			else if(prob(retreat_chance))
				//Speed boost if possible
				if(mecha.overload_action && mecha.overload_action.owner && !mecha.leg_overload_mode)
					mecha.overload_action.Activate(TRUE)
					addtimer(CALLBACK(mecha.overload_action, /datum/action/innate/mecha/mech_defense_mode.proc/Activate, FALSE), 100) //10 seconds of speeeeed, then toggle off

				L.say(pick(\
					"Taking heavy fire, falling back!",\
					"I'm critically hit, need backup!",\
					"You're on your own, I need to fallback and repair.",\
					"Fuck, I can't do this shit much longer."\
				))
				retreat_distance = 50
				spawn(100)
					retreat_distance = 0

		//Internal Damage.
		//Fix control unit damage
		if(mecha.internal_damage & MECHA_INT_CONTROL_LOST)
			L.say("Control unit reset.")
			mecha.stationary_repair(mecha.loc)

		//FIRE!!!
		if(mecha.internal_damage & MECHA_INT_FIRE)
			L.say(pick("Fuck, fuck, fuck.", "Got a cabin fire!", "Cabin fire, ejecting!", "Oh shit, got an internal fire, ejecting!"))
			mecha.eject_action.Activate()

	//Do default stuff
	. = ..()

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/MeleeAction(mob/living/L, patience)
	//Lets try and climb in mechs. Only works for us humans.
	if(istype(target, /obj/mecha) && ishuman(L))
		//Try and drag ourselves into the mech.
		target.MouseDrop_T(L, L)
		return
	//Select a melee weapon
	if(mecha)
		//Do the special thing
		var/list/possible_weapons = get_mecha_equip_by_flag(MECHA_MELEE)
		if(possible_weapons.len)
			var/obj/item/mecha_parts/mecha_equipment/ME = pick(possible_weapons)
			mecha_face_target(target)
			if(ME.action(target))
				ME.start_cooldown()
				return
		//Normal melee PUNCH!
		if(mecha.melee_can_hit)
			mecha_face_target(target)
			target.mech_melee_attack(mecha)
	//Do normal killing
	. = ..()

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/get_vision(range, source)
	if(mech_breaches_walls)
		return orange(range, source)
	return oview(range, source)

//Phazing
/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/ai_walk_to(mob/living/L, atom/Target, Min = 0, Lag = 0)
	//Dont wait for this, it sleeps.
	set waitfor = FALSE

	if(!Target)
		ai_autowalk_num ++
		return FALSE

	//Keep on walking
	if(Target == ai_autowalk_target)
		return

	ai_autowalk_num ++

	var/cur_autowalk = ai_autowalk_num
	while(ai_autowalk_num == cur_autowalk)
		if(QDELETED(L) || QDELETED(Target))
			return
		var/our_pos = L
		//Handle finding paths while in mechas and lockers etc.
		if(!isturf(L.loc))
			our_pos = L.loc
		var/step_pos
		if(!ai_autowalk_ignore_walls)
			//avoid walls
			step_pos = get_step_to(our_pos, get_turf(Target), Min)
		else
			//Go through walls
			step_pos = get_step_towards(our_pos, get_turf(Target))
		if(step_pos)
			if(!ai_move(L, step_pos, get_dir(L, step_pos)) && mecha.phasing_action?.owner && !mecha.phasing)
				mecha.phasing_action.Activate()
				if(mecha.phasing)
					//Move while phasing
					ai_move(L, step_pos, get_dir(L, step_pos))
					//Stop phasing
					mecha.phasing_action.Activate()
		sleep(max(Lag, 1))

//Choose a random weapon
/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/RangedAction(mob/living/L)
	if(mecha)
		//Reload and choose a weapon
		mecha_reload()
		mecha_face_target(target)
		var/list/possible_weapons = get_mecha_equip_by_flag(MECHA_RANGED)
		if(possible_weapons.len)
			var/obj/item/mecha_parts/mecha_equipment/ME = pick(possible_weapons) //so we don't favor mecha.equipment[1] forever
			if(ME.action(target))
				if(prob(20))
					L.say(pick("[ME] systems online!", "Gotcha.", "Lets see how you like the taste of this!", "My [ME] doesn't miss!"))
				ME.start_cooldown()
				return
	L.ClickOn(target)

//Gets the mech we are inside.
/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/proc/get_mech(mob/living/L)
	if(istype(L.loc, /obj/mecha))
		return L.loc
	return null

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/proc/is_valid_mecha(mob/living/L, obj/mecha/M)
	if(!M)
		return FALSE
	if(M.occupant)
		return FALSE
	//Only humans can enter mechs
	if(!ishuman(L))
		return FALSE
	if(M.dna_lock)
		var/mob/living/carbon/C = L
		if(!C.has_dna())
			return FALSE
		if(C.dna.unique_enzymes != M.dna_lock)
			return FALSE
	if(!M.operation_allowed(L))
		return FALSE
	if(M.mecha.internal_damage & MECHA_INT_FIRE)
		return FALSE
	//Repair mech
	if(!M.has_charge(required_mecha_charge))
		return FALSE
	if(M.obj_integrity < M.max_integrity*0.5)
		return FALSE
	//Unbuckle
	if(L.buckled)
		L.buckled.unbuckle_mob(L)
	return 1

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/proc/mecha_face_target(atom/A)
	if(mecha)
		var/dirto = get_dir(mecha,A)
		if(mecha.dir != dirto) //checking, because otherwise the mecha makes too many turn noises
			mecha.mechturn(dirto)

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/proc/mecha_reload()
	if(mecha)
		for(var/equip in mecha.equipment)
			var/obj/item/mecha_parts/mecha_equipment/ME = equip
			if(ME.needs_rearm())
				ME.rearm()

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/proc/get_mecha_equip_by_flag(flag = MECHA_RANGED)
	. = list()
	if(mecha)
		for(var/equip in mecha.equipment)
			var/obj/item/mecha_parts/mecha_equipment/ME = equip
			if((ME.range & flag) && ME.action_checks(ME)) //this looks weird, but action_checks() just needs any atom, so I spoofed it here
				. += ME

/obj/item/nbodypart/organ/brain/simple_animal/hostile/mecha_pilot/EscapeConfinement(mob/living/L)
	if(mecha && L.loc == mecha)
		return FALSE
	. = ..()
