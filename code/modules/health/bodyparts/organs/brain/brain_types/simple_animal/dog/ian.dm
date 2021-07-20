
/obj/item/nbodypart/organ/brain/simple_animal/dog/ian
	var/turns_since_scan = 0
	var/obj/movement_target

/obj/item/nbodypart/organ/brain/simple_animal/dog/ian/handle_ai(mob/living/L)
	//Do automated stuff
	. = ..()
	//Feeding, chasing food, FOOOOODDDD
	if(L.is_concious() && !L.resting && !L.buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if(!movement_target || !(L in viewers(3, movement_target.loc)))
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/reagent_containers/food/snacks/S in oview(3, L))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				stop_automated_movement = 1
				L.step_to(L,movement_target,1)
				sleep(3)
				L.step_to(L,movement_target,1)
				sleep(3)
				L.step_to(L,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
					var/turf/T = get_turf(movement_target)
					if(!T)
						return
					if (T.x < L.x)
						L.setDir(WEST)
					else if (T.x > L.x)
						L.setDir(EAST)
					else if (T.y < L.y)
						L.setDir(SOUTH)
					else if (T.y > L.y)
						L.setDir(NORTH)
					else
						L.setDir(SOUTH)

					if(!Adjacent(movement_target)) //can't reach food through windows.
						return

					if(isturf(movement_target.loc) )
						movement_target.attack_animal(L)
					else if(ishuman(movement_target.loc) )
						if(prob(20))
							INVOKE_ASYNC(L, /mob.proc/emote, "me", 1, "stares at [movement_target.loc]'s [movement_target] with a sad puppy-face")

		if(prob(1))
			INVOKE_ASYNC(L, /mob.proc/emote, "me", 1, pick("dances around.","chases its tail!"))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					L.setDir(i)
					sleep(1)
