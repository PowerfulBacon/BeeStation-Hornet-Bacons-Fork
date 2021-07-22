/mob/living/proc/Life(seconds, times_fired)
	set waitfor = FALSE
	set invisibility = 0

	body.life(seconds, times_fired)

	if((movement_type & FLYING) && !(movement_type & FLOATING))	//TODO: Better floating
		float(on = TRUE)

	if (notransform)
		return
	if(!loc)
		return

	if(!body.has_status_effect(STATUS_EFFECT_STASIS))

		if(is_alive())
			//Mutations and radiation
			handle_mutations_and_radiation()

		if(is_alive())
			//Breathing, if applicable
			handle_breathing(times_fired)

		handle_diseases()// DEAD check is in the proc itself; we want it to spread even if the mob is dead, but to handle its disease-y properties only if you're not.

		if (QDELETED(src)) // diseases can qdel the mob via transformations
			return

		if(is_alive())
			//Random events (vomiting etc)
			handle_random_events()

		//Handle temperature/pressure differences between body and environment
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			handle_environment(environment)

		//Handle gravity
		var/gravity = has_gravity()
		update_gravity(gravity)

		if(gravity > STANDARD_GRAVITY)
			if(!get_filter("gravity"))
				add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
			INVOKE_ASYNC(src, .proc/gravity_pulse_animation)
			handle_high_gravity(gravity)

		if(is_alive())
			handle_traits() // eye, ear, brain damages

	handle_fire()

	if(machine)
		machine.check_eye(src)

	if(is_alive())
		return 1

/mob/living/proc/apply_ai_digital_invisibility(invis_source)
	if(HAS_TRAIT(src,TRAIT_DIGINVIS)) //AI unable to see mob
		ADD_TRAIT(src, TRAIT_DIGINVIS, invis_source)
		return
	ADD_TRAIT(src, TRAIT_DIGINVIS, invis_source)
	if(!digitaldisguise)
		digitaldisguise = image(loc = src)
	digitaldisguise.override = TRUE
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		AI.client?.images |= digitaldisguise

/mob/living/proc/unapply_ai_digital_invisibility(invis_source)
	REMOVE_TRAIT(src, TRAIT_DIGINVIS, invis_source)
	if(!HAS_TRAIT(src, TRAIT_DIGINVIS))
		for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
			AI.client?.images -= digitaldisguise
		digitaldisguise = null

/mob/living/proc/handle_breathing(times_fired)
	return

/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals
	return

/mob/living/proc/handle_diseases()
	return

/mob/living/proc/handle_random_events()
	return

/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/proc/handle_fire()
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return TRUE //the mob is no longer on fire, no need to do the rest.
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.1) //the fire is slowly consumed
	else
		ExtinguishMob()
		return TRUE //mob was put out, on_fire = FALSE via ExtinguishMob(), no need to update everything down the chain.
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.get_moles(/datum/gas/oxygen) < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return TRUE
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

/mob/living/proc/handle_traits()
	//Eyes
	if(eye_blind)			//blindness, heals slowly over time
		if(is_concious() && !(HAS_TRAIT(src, TRAIT_BLIND)))
			eye_blind = max(eye_blind-1,0)
			if(client && !eye_blind)
				clear_alert("blind")
				clear_fullscreen("blind")
		else
			eye_blind = max(eye_blind-1,1)
	else if(eye_blurry)			//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)
		if(client)
			update_eye_blur()

/mob/living/proc/update_damage_hud()
	return

/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	INVOKE_ASYNC(src, .proc/gravity_pulse_animation)

/mob/living/proc/gravity_pulse_animation()
	animate(get_filter("gravity"), y = 1, time = 10)
	sleep(10)
	animate(get_filter("gravity"), y = 0, time = 10)

/mob/living/proc/handle_high_gravity(gravity)
	if(gravity >= GRAVITY_DAMAGE_TRESHOLD) //Aka gravity values of 3 or more
		var/grav_stregth = gravity - GRAVITY_DAMAGE_TRESHOLD
		adjustBruteLoss(min(grav_stregth,3))
