//Hierophant overlays
/obj/effect/temp_visual/hierophant
	name = "vortex energy"
	layer = BELOW_MOB_LAYER
	var/mob/living/caster //who made this, anyway

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/hierophant)

/obj/effect/temp_visual/hierophant/Initialize(mapload, new_caster)
	. = ..()
	if(new_caster)
		caster = new_caster

/obj/effect/temp_visual/hierophant/squares
	icon_state = "hierophant_squares"
	duration = 3
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	randomdir = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/hierophant/squares)

/obj/effect/temp_visual/hierophant/squares/Initialize(mapload, new_caster)
	. = ..()
	if(ismineralturf(loc))
		var/turf/closed/mineral/M = loc
		M.gets_drilled(caster)

/obj/effect/temp_visual/hierophant/wall //smoothing and pooling were not friends, but pooling is dead.
	name = "vortex wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "hierophant_wall_temp-0"
	base_icon_state = "hierophant_wall_temp"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HIERO_WALL)
	canSmoothWith = list(SMOOTH_GROUP_HIERO_WALL)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	duration = 100

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/hierophant/wall)

/obj/effect/temp_visual/hierophant/wall/Initialize(mapload, new_caster)
	. = ..()
	QUEUE_SMOOTH_NEIGHBORS(src)
	QUEUE_SMOOTH(src)

/obj/effect/temp_visual/hierophant/wall/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/temp_visual/hierophant/chaser //a hierophant's chaser. follows target around, moving and producing a blast every speed deciseconds.
	duration = 98
	var/mob/living/target //what it's following
	var/turf/targetturf //what turf the target is actually on
	var/moving_dir //what dir it's moving in
	var/previous_moving_dir //what dir it was moving in before that
	var/more_previouser_moving_dir //what dir it was moving in before THAT
	var/moving = 0 //how many steps to move before recalculating
	var/standard_moving_before_recalc = 4 //how many times we step before recalculating normally
	var/tiles_per_step = 1 //how many tiles we move each step
	var/speed = 3 //how many deciseconds between each step
	var/currently_seeking = FALSE
	var/friendly_fire_check = FALSE //if blasts produced apply friendly fire
	var/monster_damage_boost = TRUE
	var/damage = 10

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/hierophant/chaser)

/obj/effect/temp_visual/hierophant/chaser/Initialize(mapload, new_caster, new_target, new_speed, is_friendly_fire)
	. = ..()
	target = new_target
	friendly_fire_check = is_friendly_fire
	if(new_speed)
		speed = new_speed
	addtimer(CALLBACK(src, PROC_REF(seek_target)), 1)

/obj/effect/temp_visual/hierophant/chaser/proc/get_target_dir()
	. = get_cardinal_dir(src, targetturf)
	if((. != previous_moving_dir && . == more_previouser_moving_dir) || . == 0) //we're alternating, recalculate
		var/list/cardinal_copy = GLOB.cardinals.Copy()
		cardinal_copy -= more_previouser_moving_dir
		. = pick(cardinal_copy)

/obj/effect/temp_visual/hierophant/chaser/proc/seek_target()
	if(!currently_seeking)
		currently_seeking = TRUE
		targetturf = get_turf(target)
		while(target && src && !QDELETED(src) && currently_seeking && x && y && targetturf) //can this target actually be sook out
			if(!moving) //we're out of tiles to move, find more and where the target is!
				more_previouser_moving_dir = previous_moving_dir
				previous_moving_dir = moving_dir
				moving_dir = get_target_dir()
				var/standard_target_dir = get_cardinal_dir(src, targetturf)
				if((standard_target_dir != previous_moving_dir && standard_target_dir == more_previouser_moving_dir) || standard_target_dir == 0)
					moving = 1 //we would be repeating, only move a tile before checking
				else
					moving = standard_moving_before_recalc
			if(moving) //move in the dir we're moving in right now
				var/turf/T = get_turf(src)
				for(var/i in 1 to tiles_per_step)
					var/maybe_new_turf = get_step(T, moving_dir)
					if(maybe_new_turf)
						T = maybe_new_turf
					else
						break
				forceMove(T)
				make_blast() //make a blast, too
				moving--
				sleep(speed)
			targetturf = get_turf(target)
/obj/effect/temp_visual/hierophant/chaser/proc/make_blast()
	var/obj/effect/temp_visual/hierophant/blast/B = new(loc, caster, friendly_fire_check, TRUE)
	B.damage = damage
	B.monster_damage_boost = monster_damage_boost

/obj/effect/temp_visual/hierophant/telegraph
	icon = 'icons/effects/96x96.dmi'
	icon_state = "hierophant_telegraph"
	pixel_x = -32
	pixel_y = -32
	duration = 3

/obj/effect/temp_visual/hierophant/telegraph/diagonal
	icon_state = "hierophant_telegraph_diagonal"

/obj/effect/temp_visual/hierophant/telegraph/cardinal
	icon_state = "hierophant_telegraph_cardinal"

/obj/effect/temp_visual/hierophant/telegraph/teleport
	icon_state = "hierophant_telegraph_teleport"
	duration = 9

/obj/effect/temp_visual/hierophant/telegraph/edge
	icon_state = "hierophant_telegraph_edge"
	duration = 40

/obj/effect/temp_visual/hierophant/blast
	icon_state = "hierophant_blast"
	name = "vortex blast"
	light_range = 2
	light_power = 2
	desc = "Get out of the way!"
	duration = 9
	var/damage = 10 //how much damage do we do?
	var/monster_damage_boost = TRUE //do we deal extra damage to monsters? Used by the boss
	var/list/hit_things = list() //we hit these already, ignore them
	var/friendly_fire_check = FALSE
	var/bursting = FALSE //if we're bursting and need to hit anyone crossing us

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/hierophant/blast)

/obj/effect/temp_visual/hierophant/blast/Initialize(mapload, new_caster, friendly_fire, defuse)
	. = ..()
	friendly_fire_check = friendly_fire
	if(new_caster)
		hit_things += new_caster
	if(ismineralturf(loc)) //drill mineral turfs
		var/turf/closed/mineral/M = loc
		M.gets_drilled(caster)
		if(defuse && istype(loc, /turf/closed/mineral/gibtonite))
			var/turf/closed/mineral/gibtonite/G = loc
			G.defuse()
	INVOKE_ASYNC(src, PROC_REF(blast))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/temp_visual/hierophant/blast/proc/blast()
	var/turf/T = get_turf(src)
	if(!T)
		return
	playsound(T,'sound/magic/blind.ogg', 125, 1, -5) //make a sound
	sleep(6) //wait a little
	bursting = TRUE
	do_damage(T) //do damage and mark us as bursting
	sleep(1.3) //slightly forgiving; the burst animation is 1.5 deciseconds
	bursting = FALSE //we no longer damage crossers

/obj/effect/temp_visual/hierophant/blast/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(bursting)
		do_damage(get_turf(src))

/obj/effect/temp_visual/hierophant/blast/proc/do_damage(turf/T)
	if(!damage)
		return
	for(var/mob/living/L in T.contents - hit_things) //find and damage mobs...
		hit_things += L
		if((friendly_fire_check && caster && caster.faction_check_mob(L)) || L.stat == DEAD)
			continue
		if(L.client)
			flash_color(L.client, "#660099", 1)
		playsound(L,'sound/weapons/sear.ogg', 50, 1, -4)
		to_chat(L, span_userdanger("You're struck by a [name]!"))
		var/limb_to_hit = L.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
		var/armor = L.run_armor_check(limb_to_hit, MELEE, "Your armor absorbs [src]!", "Your armor blocks part of [src]!", 50, "Your armor was penetrated by [src]!")
		L.apply_damage(damage, BURN, limb_to_hit, armor)
		if(ishostile(L))
			var/mob/living/simple_animal/hostile/H = L //mobs find and damage you...
			if(H.stat == CONSCIOUS && !H.target && H.AIStatus != AI_OFF && !H.client)
				if(!QDELETED(caster))
					if(get_dist(H, caster) <= H.aggro_vision_range)
						H.FindTarget(list(caster), 1)
					else
						H.Goto(get_turf(caster), H.move_to_delay, 3)
		if(monster_damage_boost && (ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid)))
			L.adjustBruteLoss(damage)
		if(caster)
			log_combat(caster, L, "struck with a [name]")
	for(var/obj/vehicle/sealed/mecha/M in T.contents - hit_things) //also damage mechs.
		hit_things += M
		for(var/O in M.occupants)
			var/mob/living/occupant = O
			if(friendly_fire_check && caster && caster.faction_check_mob(occupant))
				continue
			to_chat(occupant, span_userdanger("Your [M.name] is struck by a [name]!"))
			playsound(M,'sound/weapons/sear.ogg', 50, TRUE, -4)
			M.take_damage(damage, BURN, 0, 0)

/obj/effect/temp_visual/hierophant/blast/vortex
	damage = 25
