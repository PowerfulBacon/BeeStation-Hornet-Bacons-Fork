
/obj/item/nbodypart/organ/brain/simple_animal/kalo
	speak = list("Hissssss!", "Squeak!")
	speak_emote = list("hisses", "squeaks")
	emote_hear = list("hisses", "squeaks")
	emote_see = list("pounces")
	var/turns_since_scan = 0
	var/obj/item/reagent_containers/food/snacks/movement_target

/obj/item/nbodypart/organ/brain/simple_animal/kalo/handle_automated_action(mob/living/L)
	if(!L.is_concious() || L.resting || L.buckled)
		return
	turns_since_scan ++
	if(turns_since_scan > 20)
		turns_since_scan = 0

		//Movement target is gone
		if((movement_target) && !isturf(movement_target.loc))
			movement_target = null
			stop_automated_movement = FALSE

		//Find a movement target
		if(!movement_target || !(L in viewers(5, movement_target.loc)))
			stop_automated_movement = FALSE
			movement_target = locate(/obj/item/reagent_containers/food/snacks) in oview(5, src) //can smell things up to 5 blocks radius

		//Drink blood
		if(!movement_target)
			var/obj/effect/decal/cleanable/blood/B
			for(var/obj/effect/decal/cleanable/blood/O in oview(2, L))
				if (!istype(O, /obj/effect/decal/cleanable/blood/gibs) && !istype(O, /obj/effect/decal/cleanable/blood/innards)) //dont lick up gibs or innards
					B = O
					break
			if(B)
				stop_automated_movement = TRUE
				ai_move(L, B, 1)
				sleep(5)
				if (B.loc.x < src.x) L.setDir(WEST)
				else if (B.loc.x > src.x) L.setDir(EAST)
				else if (B.loc.y < src.y) L.setDir(SOUTH)
				else if (B.loc.y > src.y) L.setDir(NORTH)
				else L.setDir(SOUTH)
				//AI Cheat.
				//Will eat blood when in control of any mob.
				if(L.Adjacent(B))
					sleep(30) //take your time
					if(B && Adjacent(B)) //make sure it's still there and we're still there
						if(prob(60))
							INVOKE_ASYNC(L, /mob.proc/emote, "me", 1, "licks up \the [B]")
						qdel(B)
						L.adjustBruteLoss(-5)
						stop_automated_movement = 0

	if(movement_target)
		//Walk to movement target
		stop_automated_movement = TRUE
		ai_walk_to(L, movement_target, 1, L.movement_delay())
		//Eat!!!!
		if(L.Adjacent(movement_target) && isturf(movement_target.loc))
			//We are a human type and holding something
			if(L.get_active_held_item())
				L.drop_all_held_items()
			//Click on the movement target to eat.
			L.ClickOn(movement_target)
			//We picked it up (we are a human mobtype), try and eat it!
			if(L.get_active_held_item() == movement_target)
				L.ClickOn(L)

	if(prob(1))
		INVOKE_ASYNC(L, /mob.proc/emote, "me", 1, "pounces around!")
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2)) //ian dance but longer
				setDir(i)
				sleep(1)
