#define PICK_STYLE_RANDOM 1
#define PICK_STYLE_ORDERED 2
#define PICK_STYLE_ALL 3

/obj/effect/trap
	name = "nasty trap"
	desc = "doesn't do much, really..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "gavelblock"
	invisibility = INVISIBILITY_MAXIMUM //sorry ghosts and curators, my tricks will remain hidden
	var/reusable = FALSE //can it trigger more than once
	var/inuse = FALSE //used to make sure it dont get used when it shouldn't

/obj/effect/trap/proc/TrapEffect(AM)
	return TRUE

/obj/effect/trap/trigger //this only triggers other traps
	name = "pressure pad"
	desc = "seems flimsy"
	var/grounded = FALSE //does it ignore fliers
	var/pick_style = PICK_STYLE_ORDERED
	var/requirehuman = TRUE

/obj/effect/trap/trigger/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/trap/trigger/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER

	if(isturf(loc))
		if(ismob(AM) && grounded)
			var/mob/MM = AM
			if(!(MM.movement_type & FLYING))
				if(TrapEffect(AM))
					if(!reusable)
						qdel(src)
		else if(!requirehuman)
			if(TrapEffect(AM))
				if(!reusable)
					qdel(src)
		else if(ismob(AM))
			var/mob/MM = AM
			if(MM.mind)
				if(TrapEffect(AM))
					if(!reusable)
						qdel(src)

/obj/effect/trap/trigger/TrapEffect(AM)
	if(inuse)
		return FALSE
	else
		inuse = TRUE
	var/list/possibletraps = list()
	for(var/obj/effect/trap/nexus/payload in view(10, src))
		possibletraps += payload
	if(!LAZYLEN(possibletraps))
		qdel(src)
		return FALSE
	switch(pick_style)
		if(PICK_STYLE_RANDOM)
			var/obj/effect/trap/nexus/chosen = pick(possibletraps)
			if(chosen.TrapEffect(AM))
				if(!chosen.reusable)
					qdel(chosen)
				inuse = FALSE
				return TRUE
		if(PICK_STYLE_ORDERED)
			for(var/obj/effect/trap/nexus/chosen in possibletraps)
				if(chosen.TrapEffect(AM))
					if(!chosen.reusable)
						qdel(chosen)
					inuse = FALSE
					return TRUE
		if(PICK_STYLE_ALL)
			var/success = FALSE
			for(var/obj/effect/trap/nexus/chosen in possibletraps)
				if(chosen.TrapEffect(AM))
					if(!chosen.reusable)
						qdel(chosen)
					success = TRUE
			if(success)
				inuse = FALSE
				return TRUE
	inuse = FALSE
	return FALSE

/obj/effect/trap/trigger/all
	pick_style = PICK_STYLE_ALL

/obj/effect/trap/trigger/random
	pick_style = PICK_STYLE_RANDOM

/obj/effect/trap/trigger/reusable
	desc = "seems sturdy"
	reusable = TRUE

/obj/effect/trap/trigger/reusable/all
	pick_style = PICK_STYLE_ALL

/obj/effect/trap/trigger/reusable/random
	pick_style = PICK_STYLE_RANDOM

/obj/effect/trap/nexus //this trap is triggered by pressurepads. doesnt do anything alone
	icon_state = "madeyoulook"

/obj/effect/trap/nexus/doorbolt //a nasty little trap to put in a room with a simplemob
	name = "door bolter"
	desc = "locks an unfortunate victim in for a few seconds"
	var/locktime = 10 SECONDS

/obj/effect/trap/nexus/doorbolt/TrapEffect(AM)
	if(inuse)
		return FALSE
	else
		inuse = TRUE
	var/list/airlocks = list()
	for(var/obj/machinery/door/airlock/airlock in view(10, src))
		airlocks += airlock
		airlock.unbolt()//you think you're so smart, hm? I'm smarter.
		if(!airlock.density)
			if(!airlock.close())
				airlock.safe = FALSE
				airlock.close(3)//yank that bitch shut as hard as you can. this'll be noisy
				airlock.visible_message("<span class='warning'>[airlock] shudders for a second, and then grinds closed ominously.</span>")
		airlock.bolt()
	stoplag(locktime)
	for(var/obj/machinery/door/airlock/airlock in airlocks)
		airlock.unbolt()
	inuse = FALSE
	return TRUE

/obj/effect/trap/nexus/cluwnecurse
	name = "honk :0)"
	desc = "oh god..."

/obj/effect/trap/nexus/cluwnecurse/TrapEffect(AM)
	var/turf/T = get_turf(src)
	for(var/mob/living/carbon/human/C in range(5, src))
		if(C.mind)
			var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
			FC.force_target(C)
			FC.dontkill = TRUE
			FC.delete_after_target_killed = TRUE //it only affects the one to walk on the rune. when he dies, the rune is no longer usable
			message_admins("A hugbox floor cluwne has been spawned at [COORD(T)][ADMIN_JMP(T)] following [ADMIN_LOOKUPFLW(C)]")
			log_game("A hugbox floor cluwne has been spawned at [COORD(T)]")
			playsound(C,'sound/misc/honk_echo_distant.ogg', 30, 1)
			return TRUE
	return FALSE

/obj/effect/trap/nexus/darkness
	name = "lightbreaker"
	desc = "for effect"

/obj/effect/trap/nexus/darkness/TrapEffect()
	for(var/obj/machinery/light/L in view(10, src))
		L.on = TRUE
		L.break_light_tube()
		L.on = FALSE
		stoplag()
	return TRUE

/obj/effect/trap/nexus/trickyspawner //attempts to spawn a simplemob somewhere out of sight, aggroed to the target
	name = "tricky little bastard"
	desc = "I don't think it's gonna do anything"
	var/crossattempts = 3
	var/crossed = 0
	var/mobs = 1
	reusable = TRUE
	var/mob/living/simple_animal/hostile/spawned = /mob/living/simple_animal/hostile/retaliate/spaceman

/obj/effect/trap/nexus/trickyspawner/Initialize(mapload)
	. = ..()
	crossattempts = rand(1, 10)

/obj/effect/trap/nexus/trickyspawner/TrapEffect(AM)
	crossed ++
	if(crossed <= crossattempts)
		return FALSE
	var/list/turfs = list()
	var/list/mobss = list()
	var/list/validturfs = list()
	var/turf/T = get_turf(src)
	for(var/turf/open/O in view(7, src))
		if(!isspaceturf(O))
			turfs += O
	for(var/mob/living/L in view(7, src))
		if(L.mind)
			mobss += L
	for(var/turf/turf as() in turfs)
		var/visible = FALSE
		for(var/mob/living/L as() in mobss)
			if(can_see(L, turf))
				visible = TRUE
		if(!visible)
			validturfs += T
	if(validturfs.len)
		T = pick(validturfs)
	if(mobs)
		var/mob/living/simple_animal/hostile/spawninstance = new spawned(T)
		spawninstance.target = AM
		if(istype(spawninstance, /mob/living/simple_animal/hostile/retaliate))
			var/mob/living/simple_animal/hostile/retaliate/R = spawninstance
			R.enemies += AM
		mobs--
		crossattempts = rand(1, 5)
		if(!mobs)
			reusable = FALSE
		return TRUE
	return TRUE

/obj/effect/trap/nexus/trickyspawner/catbutcher
	spawned = /mob/living/simple_animal/hostile/cat_butcherer/hugbox

/obj/effect/trap/nexus/trickyspawner/faithless
	spawned = /mob/living/simple_animal/hostile/faithless

/obj/effect/trap/nexus/trickyspawner/shitsec
	spawned = /mob/living/simple_animal/hostile/nanotrasen/hugbox

/obj/effect/trap/nexus/trickyspawner/eldritch //currently unused. if used, note these guys are quite powerful with a whopping 35 melee
	spawned = /mob/living/simple_animal/hostile/netherworld

/obj/effect/trap/nexus/trickyspawner/spookyskeleton
	spawned = /mob/living/simple_animal/hostile/skeleton

/obj/effect/trap/nexus/trickyspawner/zombie
	spawned = /mob/living/simple_animal/hostile/zombie/hugbox

/obj/effect/trap/nexus/trickyspawner/xeno
	spawned = /mob/living/simple_animal/hostile/alien/hugbox

/obj/effect/trap/nexus/trickyspawner/honkling
	mobs = 5 //honklings are annoying, but nearly harmless.
	spawned = /mob/living/simple_animal/hostile/retaliate/clown/honkling

/obj/effect/trap/nexus/trickyspawner/clownmutant
	spawned = /mob/living/simple_animal/hostile/retaliate/clown/mutant

/obj/effect/trap/nexus/trickyspawner/tree
	spawned = /mob/living/simple_animal/hostile/tree


#undef PICK_STYLE_RANDOM
#undef PICK_STYLE_ORDERED
#undef PICK_STYLE_ALL


/mob/living/simple_animal/hostile/nanotrasen/hugbox
	loot = list(/obj/effect/gibspawner/human)//no gamer gear, sorry!
	mobchatspan = "headofsecurity"
	del_on_death = TRUE

/mob/living/simple_animal/hostile/zombie/hugbox
	melee_damage = 12 //zombies have a base of 21, a bit much
	stat_attack = CONSCIOUS
	mobchatspan = "chaplain"
	discovery_points = 1000

/mob/living/simple_animal/hostile/alien/hugbox
	health = 60 //they go down easy, to lull the player into a sense of false security
	maxHealth = 60
	mobchatspan = "researchdirector"
	discovery_points = 1000

/mob/living/simple_animal/hostile/cat_butcherer/hugbox //a cat butcher without a melee speed buff or a syringe gun. he's not too hard to take down, but can still go on catification rampages
	ranged = FALSE
	rapid_melee = 1
	loot = list(/obj/effect/mob_spawn/human/corpse/cat_butcher, /obj/item/circular_saw)
	mobchatspan = "medicaldoctor"
