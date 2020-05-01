/datum/quest_system/quest/protect_pet
	name = "Look after pet."
	desc = "%faction wants you to look after their beloved"
	factions = list(/datum/quest_system/faction/felinids)
	completion_reputation_change = 4
	failure_reputation_change = -6

	var/datum/weakref/pet_ref

/datum/quest_system/quest/on_accept()
	//spawn a corgi
	var/mob/living/simple_animal/pet/dog/corgi/cool_dog = new()
	cool_dog.name = pick("Liam", "Harold", "Jeramire", "Ilo")
	pet_ref = WEAKREF(cool_dog)

	//Send in the corgi
	var/obj/structure/closet/supplypod/bluespacepod/pod = new(locate(/area/bridge) in GLOB.sortedAreas)
	pod.explosionSize = list(0,0,0,0)
	cool_dog.forceMove(pod)

	new /obj/effect/DPtarget(get_turf(src), pod)

/datum/quest_system/quest/on_finished()
	//Retrieve the dog
	var/mob/living/simple_animal/pet/dog/corgi/cool_dog = pet_ref.resolve()
	if(!cool_dog)
		return -1
	//Don't run away stupid dog :(
	cool_dog.Immobilize(300)
	//In case the dog escapes capture, just gib it
	addtimer(CALLBACK(src, .proc/destroy_dog), 100)

/datum/quest_system/quest/proc/destroy_dog()
	var/mob/living/simple_animal/pet/dog/corgi/cool_dog = pet_ref.resolve()
	if(!cool_dog)
		return -1
	cool_dog.gib()

/datum/quest_system/quest/check_completion
	var/mob/living/simple_animal/pet/dog/corgi/cool_dog = pet_ref.resolve()
	return cool_dog ? (cool_dog.health > 0 ? QUEST_COMPLETED : QUEST_FAILED) : QUEST_FAILED
