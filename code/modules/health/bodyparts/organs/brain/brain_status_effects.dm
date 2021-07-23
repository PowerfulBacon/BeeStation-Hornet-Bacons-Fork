
/*
Alcohol Poisoning Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occassional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - light brain damage, passing out
91-100: Dangerously toxic - swift death
*/
#define BALLMER_POINTS 5
GLOBAL_LIST_INIT(ballmer_good_msg, list("Hey guys, what if we rolled out a bluespace wiring system so mice can't destroy the powergrid anymore?",
										"Hear me out here. What if, and this is just a theory, we made R&D controllable from our PDAs?",
										"I'm thinking we should roll out a git repository for our research under the AGPLv3 license so that we can share it among the other stations freely.",
										"I dunno about you guys, but IDs and PDAs being separate is clunky as fuck. Maybe we should merge them into a chip in our arms? That way they can't be stolen easily.",
										"Why the fuck aren't we just making every pair of shoes into galoshes? We have the technology."))
GLOBAL_LIST_INIT(ballmer_windows_me_msg, list("Yo man, what if, we like, uh, put a webserver that's automatically turned on with default admin passwords into every PDA?",
												"So like, you know how we separate our codebase from the master copy that runs on our consumer boxes? What if we merged the two and undid the separation between codebase and server?",
												"Dude, radical idea: H.O.N.K mechs but with no bananium required.",
												"Best idea ever: Disposal pipes instead of hallways.",
												"We should store bank records in a webscale datastore, like /dev/null.",
												"You ever wonder if /dev/null supports sharding?",
												"What if we use a language that was written on a napkin and created over 1 weekend for all of our servers?"))


/obj/item/nbodypart/organ/brain
	//===========
	//Status Effects
	//Stores the end time of the effect.
	//===========
	//Mob confusion
	var/confused = 0
	//How dizzy is the mob
	var/dizziness = 0
	//How drowsy is the mob
	var/drowsyness = 0
	var/drowsyticks = 0
	//Jittering
	var/jitteriness = 0
	var/jittered = FALSE
	//Stuttering
	var/stuttering = 0
	//Slurring
	var/slurring = 0
	//Cult slurring
	var/cultslurring = 0
	//Clock slurring
	var/clockslurring = 0
	//Silent
	var/silent = 0
	//Druggy
	var/druggy = 0
	var/ishigh = FALSE
	//Hallucinations
	var/hallucination = 0
	//Drunkness
	//This one is handled as a number, rather than a world.time value.
	var/drunkness = 0
	var/isdrunk = FALSE

/obj/item/nbodypart/organ/brain/proc/Confuse(amount)
	confused = max(confused + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Dizzy(amount)
	dizziness = max(dizziness + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Drowsy(amount)
	drowsyness = max(drowsyness + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Jitter(amount)
	jitteriness = max(jitteriness + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Stutter(amount)
	stuttering = max(stuttering + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Slur(amount)
	slurring = max(slurring + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/CultSlur(amount)
	cultslurring = max(cultslurring + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/ClockSlur(amount)
	clockslurring = max(clockslurring + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Silence(amount)
	silent = max(silent + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Drug(amount)
	druggy = max(druggy + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Hallucinate(amount)
	hallucination = max(hallucination + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/Drunk(amount)
	drunkness = max(drunkness + amount, world.time + amount)

/obj/item/nbodypart/organ/brain/proc/handle_status_effects()
	//Handle confusion
	if(confused)
		confused = max(0, confused - 1)

	var/mob/living/owner_mob = owner_body.owner
	var/restingpwr = 4 * owner_mob.resting

	//Handle Dizziness
	if(dizziness > world.time)
		var/client/C = owner_mob.client
		var/pixel_x_diff = 0
		var/pixel_y_diff = 0
		var/temp
		var/saved_dizz = dizziness
		//TODO: Does this even work?
		if(C)
			var/oldsrc = src
			var/amplitude = dizziness*(sin(dizziness * world.time) + 1) // This shit is annoying at high strength
			src = null
			spawn(0)
				if(C)
					temp = amplitude * sin(saved_dizz * world.time)
					pixel_x_diff += temp
					C.pixel_x += temp
					temp = amplitude * cos(saved_dizz * world.time)
					pixel_y_diff += temp
					C.pixel_y += temp
					sleep(3)
					if(C)
						temp = amplitude * sin(saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
					sleep(3)
					if(C)
						C.pixel_x -= pixel_x_diff
						C.pixel_y -= pixel_y_diff
			src = oldsrc
		dizziness = max(dizziness - restingpwr, 0)

	//Handle drowsyness
	if(drowsyness > world.time)
		drowsyness = max(drowsyness - restingpwr, 0)
		owner_mob.blur_eyes(2)
		drowsyticks ++
		//Approximately the same as prob(5)
		if(drowsyticks % 13 == 0)
			owner_mob.AdjustSleeping(20)
			owner_mob.Unconscious(100)
	else
		drowsyticks = 0

	//Handle Jitterness
	if(jitteriness > world.time)
		owner_mob.do_jitter_animation(jitteriness)
		jitteriness = max(jitteriness - restingpwr, 0)
		if(!jittered)
			SEND_SIGNAL(owner_mob, COMSIG_ADD_MOOD_EVENT, "jittery", /datum/mood_event/jittery)
			jittered = TRUE
	else if(jittered)
		SEND_SIGNAL(owner_mob, COMSIG_CLEAR_MOOD_EVENT, "jittery")
		jittered = FALSE

	//Druggyness
	if(druggy > world.time)
		if(!ishigh)
			owner_mob.overlay_fullscreen("high", /atom/movable/screen/fullscreen/high)
			owner_mob.throw_alert("high", /atom/movable/screen/alert/high)
			SEND_SIGNAL(owner_mob, COMSIG_ADD_MOOD_EVENT, "high", /datum/mood_event/high)
			owner_mob.sound_environment_override = SOUND_ENVIRONMENT_DRUGGED
			ishigh = TRUE
	else if(ishigh)
		owner_mob.clear_fullscreen("high")
		owner_mob.clear_alert("high")
		SEND_SIGNAL(owner_mob, COMSIG_CLEAR_MOOD_EVENT, "high")
		owner_mob.sound_environment_override = SOUND_ENVIRONMENT_NONE
		ishigh = FALSE

	//Hallucinations
	if(hallucination > world.time)
		handle_hallucinations()

	//Drunkness
	if(drunkness)
		handle_drunkness()

/obj/item/nbodypart/organ/brain/proc/handle_hallucinations()
	return

/obj/item/nbodypart/organ/brain/proc/handle_drunkness()
	var/mob/living/owner_mob = owner_body.owner

	drunkness = max(drunkness - (drunkness * 0.04) - 0.01, 0)

	if(drunkness >= 6)
		if(prob(25))
			Slur(2)
		jitteriness = max(jitteriness - 3, 0)
		if(HAS_TRAIT(owner_mob, TRAIT_DRUNK_HEALING))
			owner_mob.adjustBruteLoss(-0.12, FALSE)
			owner_mob.adjustFireLoss(-0.06, FALSE)
		if(!isdrunk)
			SEND_SIGNAL(owner_mob, COMSIG_ADD_MOOD_EVENT, "drunk", /datum/mood_event/drunk)
			isdrunk = TRUE
	else if(isdrunk)
		SEND_SIGNAL(owner_mob, COMSIG_CLEAR_MOOD_EVENT, "drunk")
		isdrunk = FALSE

	if(drunkness >= 11)
		slurring = max(slurring + 1.2, 5 + world.time)

	if(drunkness >= 41)
		if(prob(25))
			Confuse(2)
		dizziness = max(dizziness, world.time + 10)
		if(HAS_TRAIT(owner_mob, TRAIT_DRUNK_HEALING)) // effects stack with lower tiers
			owner_mob.adjustBruteLoss(-0.3, FALSE)
			owner_mob.adjustFireLoss(-0.15, FALSE)

	if(drunkness >= 51)
		if(prob(3))
			Confuse(25)
			//owner_mob.vomit() // vomiting clears toxloss, consider this a blessing
		dizziness = max(dizziness, world.time + 25)

	if(drunkness >= 61)
		if(prob(50))
			owner_mob.blur_eyes(5)
		if(HAS_TRAIT(owner_mob, TRAIT_DRUNK_HEALING))
			owner_mob.adjustBruteLoss(-0.4, FALSE)
			owner_mob.adjustFireLoss(-0.2, FALSE)

	if(drunkness >= 71)
		owner_mob.blur_eyes(5)

	if(drunkness >= 81)
		owner_mob.adjustToxLoss(1)
		if(prob(5) && owner_mob.is_concious())
			to_chat(owner_mob, "<span class='warning'>Maybe you should lie down for a bit.</span>")

	if(drunkness >= 91)
		owner_mob.adjustToxLoss(1)
		owner_mob.body.apply_injury(BP_BRAIN, /datum/injury/organ_damage, 0.1)
		if(prob(20) && owner_mob.is_concious())
			if(SSshuttle.emergency.mode == SHUTTLE_DOCKED && is_station_level(owner_mob.z)) //QoL mainly
				to_chat(owner_mob, "<span class='warning'>You're so tired, but you can't miss that shuttle.</span>")
			else
				to_chat(owner_mob, "<span class='warning'>Just a quick nap.</span>")
				owner_mob.Sleeping(900)

	if(drunkness >= 101)
		owner_mob.adjustToxLoss(2) //Let's be honest you shouldn't be alive by now
