/mob/living/simple_animal/hostile/curseblob
	name = "curse mass"
	desc = "A mass of purple... smoke?"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "curseblob"
	icon_living = "curseblob"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	weather_immunities = list("lava","ash")
	minbodytemp = 0
	maxbodytemp = INFINITY
	response_harm_continuous = "strikes"
	response_harm_simple = "strike"
	status_flags = 0
	mob_biotypes = list(MOB_SPIRIT)
	is_flying_animal = TRUE
	no_flying_animation = TRUE
	move_to_delay = 5
	vision_range = 20
	aggro_vision_range = 20
	maxHealth = 40 //easy to kill, but oh, will you be seeing a lot of them.
	health = 40
	melee_damage = 10
	melee_damage_type = BURN
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/effects/curseattack.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	sentience_type = SENTIENCE_BOSS
	layer = LARGE_MOB_LAYER
	a_intent = INTENT_HARM
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE
	hardattacks = TRUE //nasty_blocks wont help you here
	var/mob/living/set_target
	var/datum/move_loop/has_target/force_move/our_loop

/mob/living/simple_animal/hostile/curseblob/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 60 SECONDS)
	playsound(src, 'sound/effects/curse1.ogg', 100, 1, -1)

/mob/living/simple_animal/hostile/curseblob/Destroy()
	new /obj/effect/temp_visual/dir_setting/curse/blob(loc, dir)
	set_target = null
	return ..()

/mob/living/simple_animal/hostile/curseblob/Goto(move_target, delay, minimum_distance) //Observe
	if(check_for_target())
		return
	move_loop(target, delay)

/mob/living/simple_animal/hostile/curseblob/proc/move_loop(move_target, delay)
	if(our_loop)
		return
	our_loop = SSmove_manager.force_move(src, move_target, delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!our_loop)
		return
	RegisterSignal(move_target, COMSIG_MOB_STATCHANGE, PROC_REF(stat_change))
	RegisterSignal(move_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(target_z_change))
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(our_z_change))
	RegisterSignal(our_loop, COMSIG_PARENT_QDELETING, PROC_REF(handle_loop_end))

/mob/living/simple_animal/hostile/curseblob/proc/stat_change(datum/source, new_stat)
	SIGNAL_HANDLER
	if(new_stat != CONSCIOUS)
		qdel(src)

/mob/living/simple_animal/hostile/curseblob/proc/target_z_change(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	qdel(src)

/mob/living/simple_animal/hostile/curseblob/proc/our_z_change(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	qdel(src)

/mob/living/simple_animal/hostile/curseblob/proc/handle_loop_end()
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)

/mob/living/simple_animal/hostile/curseblob/handle_target_del(datum/source)
	. = ..()
	qdel(src)

/mob/living/simple_animal/hostile/curseblob/proc/check_for_target()
	if(QDELETED(src) || !set_target || set_target.stat != CONSCIOUS || set_target.z != z)
		return TRUE

/mob/living/simple_animal/hostile/curseblob/GiveTarget(new_target)
	if(check_for_target())
		return
	new_target = set_target
	. = ..()
	Goto(target, move_to_delay)

/mob/living/simple_animal/hostile/curseblob/LoseTarget() //we can't lose our target!
	if(check_for_target())
		return

//if it's not our target, we ignore it
/mob/living/simple_animal/hostile/curseblob/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == set_target)
		return FALSE
	if(istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if(P.firer == set_target)
			return FALSE

#define IGNORE_PROC_IF_NOT_TARGET(X) /mob/living/simple_animal/hostile/curseblob/##X(AM) { if (AM == set_target) return ..(); }

IGNORE_PROC_IF_NOT_TARGET(attack_hand)

IGNORE_PROC_IF_NOT_TARGET(attack_hulk)

IGNORE_PROC_IF_NOT_TARGET(attack_paw)

IGNORE_PROC_IF_NOT_TARGET(attack_alien)

IGNORE_PROC_IF_NOT_TARGET(attack_larva)

IGNORE_PROC_IF_NOT_TARGET(attack_animal)

IGNORE_PROC_IF_NOT_TARGET(attack_slime)

/mob/living/simple_animal/hostile/curseblob/bullet_act(obj/projectile/Proj)
	if(Proj.firer != set_target)
		return
	return ..()

/mob/living/simple_animal/hostile/curseblob/attacked_by(obj/item/I, mob/living/L)
	if(L != set_target)
		return
	return ..()

#undef IGNORE_PROC_IF_NOT_TARGET
