/*
 * Detonating
 * Dominant Oil Slime extracts (Detonating <color> extract) are primed
 * like grenades and then provide an effect over an area after a fuse
 * timer elapses
 */

/obj/item/slimecross/detonating
	name = "detonating extract"
	desc = "It is pulsating and looks like it's about to burst."
	effect  = "detonating"
	icon_state = "burning" //temp
	var/primed = FALSE
	var/detonation_time = 60
	var/log_admin = FALSE
	var/log_message = "has done something"

/obj/item/slimecross/detonating/attack_self(mob/user)
	. = ..()
	if(primed)
		return
	if(!can_trigger(user))
		return
	prime(user)

/obj/item/slimecross/detonating/proc/can_trigger(mob/user)
	return TRUE

/obj/item/slimecross/detonating/proc/prime(mob/user)
	if(log_admin)
		message_admins("[ADMIN_LOOKUPFLW(user)] primed [src] for detonation.")
	user.visible_message("<span class='warning'>[user] primes [src]!</span>", "<span class='notice'>You prime [src].</span>")
	user.log_message("primed [src] for detonation.", LOG_ATTACK)
	playsound(src, 'sound/weapons/armbomb.ogg', 60)
	primed = TRUE
	addtimer(CALLBACK(src, .proc/explode, user), detonation_time, TIMER_UNIQUE)

/obj/item/slimecross/detonating/proc/explode(mob/user)
	if(log_admin)
		message_admins("[ADMIN_LOOKUPFLW(user)] has [log_message] using [src].")
	new /obj/effect/temp_visual/explosion(get_turf(src))
	user.log_message("has [log_message].", LOG_ATTACK)
	qdel(src)

//======================
// Grey
// Status: Working
//======================

/obj/item/slimecross/detonating/grey
	colour = "grey"
	effect_desc = "Provides 600 food to all slimes with 5 meters."
	log_admin = FALSE
	log_message = "fed all slimes in 5 meters"	//Was meant to be a 10x10 area, but that is not possible with a center, so 11x11 will do.

/obj/item/slimecross/detonating/grey/explode(mob/user)
	//Note: List of all slime mobs even at max should be quicker to iterate through than range(10)
	playsound(src, get_sfx("explosion"), 60)
	for(var/mob/living/simple_animal/slime/S in view(5, get_turf(src)))
		S.add_nutrition(600)
		new /obj/effect/temp_visual/love_heart(get_turf(S))
	..()

//======================
// Orange
// Status: Working
//======================

/obj/item/slimecross/detonating/orange
	colour = "orange"
	effect_desc = "Ignites everything within 3 meters."
	log_admin = TRUE
	log_message = "ignited all mobs in 3 meters"

/obj/item/slimecross/detonating/orange/explode(mob/user)
	var/list/ignited_mobs = list()
	playsound(src, get_sfx("explosion"), 60)
	for(var/mob/living/L in range(3, src))
		L.adjust_fire_stacks(5)
		L.IgniteMob()
		if(L.mind)
			L.log_message("was ignited by [key_name(user)] using [src].")
			ignited_mobs += key_name(L)
	if(LAZYLEN(ignited_mobs))
		message_admins("[ADMIN_LOOKUPFLW(user)] has [log_message] using [src].")
		user.log_message("ignited [ignited_mobs.Join(", ")] using [src].")
	..()

//======================
// Purple
// Status: Working
//======================

/obj/item/slimecross/detonating/purple
	colour = "purple"
	effect_desc = "Revives all mobs within 2 meters at the cost of a users soul."
	log_admin = FALSE
	log_message = "revived all mobs within 2 meters"

/obj/item/slimecross/detonating/purple/can_trigger(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.hellbound)
		to_chat(user, "<span class='warning'>You do not possess a soul!</span>")
		return FALSE
	return TRUE

/obj/item/slimecross/detonating/purple/prime(mob/user)
	. = ..()
	to_chat(user, "<span class='userdanger'>You feel empty...</span>")

/obj/item/slimecross/detonating/purple/explode(mob/living/user)
	if(!istype(user))
		qdel(src)
		return
	playsound(src, 'sound/magic/staff_healing.ogg', 60)
	//Goodbye :salute:
	user.hellbound = TRUE
	//A noble sacrafice
	for(var/mob/living/L in range(2, src))
		L.revive(TRUE, FALSE)
		new /obj/effect/temp_visual/heal(get_turf(L))
	..()

//======================
// Blue
// Status: Working
//======================

/obj/item/slimecross/detonating/blue
	colour = "blue"
	effect_desc = "If there is less than 100 kPa of pressure in a space, the area will be filled with 100kPa of oxygen."
	log_admin = FALSE
	log_message = "created oxygen on all tiles within 3 meters"

/obj/item/slimecross/detonating/blue/explode(mob/user)
	playsound(src, 'sound/effects/spray.ogg', 60)
	for(var/turf/open/T in range(3, src))
		var/datum/gas_mixture/environment = T.return_air()
		if(environment.return_pressure() > ONE_ATMOSPHERE)
			continue
		var/pressure_needed = ONE_ATMOSPHERE - environment.return_pressure()
		environment.adjust_moles(/datum/gas/oxygen, pressure_needed*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))
	..()

//======================
// Metal
// Status: Working
//======================

/obj/item/slimecross/detonating/metal
	colour = "metal"
	effect_desc = "Attempts to place floors on all tiles within 3 meters."
	log_admin = FALSE
	log_message = "placed floor tiles on all space tiles within 3 meters"

/obj/item/slimecross/detonating/metal/explode(mob/user)
	playsound(src, 'sound/items/deconstruct.ogg', 60)
	var/sanity = 7 * 7	//7x7 area
	var/list/checked = list()
	var/list/to_check = list(get_turf(src))
	while(sanity >= 0 && LAZYLEN(to_check))
		sanity --
		var/turf/T = to_check[1]
		if(isclosedturf(T))
			to_check -= T
			CHECK_TICK
			continue
		//Check if we are solid, or something on us is solid
		var/stop = FALSE
		for(var/atom/A in T)
			if(A.density)
				stop = TRUE
				break
		if(stop)
			to_check -= T
			CHECK_TICK
			continue
		//Check in cardinal directions
		var/edge = FALSE
		for(var/direction in list(1, 2, 4, 8))
			var/turf/next = get_step(T, direction)
			if(get_dist(get_turf(src), next) > 3)
				edge = TRUE
				continue
			if(next in checked)
				continue
			to_check += next
			checked += next
		//Change turf
		if(edge)
			T.PlaceOnTop(/turf/closed/wall)
		else if(isspaceturf(T))
			T.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		else if(isplatingturf(T))
			T.PlaceOnTop(/turf/open/floor/plasteel)
		to_check -= T
		CHECK_TICK
	..()

//======================
// Yellow
// Status: Working
//======================

/obj/item/slimecross/detonating/yellow
	colour = "yellow"
	effect_desc = "Creates a large Tesla Shock reaction and a moderate electromagnetic pulse."
	log_admin = TRUE
	log_message = "created a tesla shock and an EMP blast"

/obj/item/slimecross/detonating/yellow/explode(mob/user)
	playsound(src, 'sound/effects/empulse.ogg', 60)
	tesla_zap(src, 7, 20000)
	empulse(src, 4, 10)
	..()

//======================
// Dark Purple
// Status: Working
//======================

/obj/item/slimecross/detonating/dark_purple
	colour = "dark purple"
	effect_desc = "Converts walls and floors in a 7x7 area to plasma."
	log_admin = TRUE
	log_message = "converted nearby walls into plasma"

/obj/item/slimecross/detonating/dark_purple/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	for(var/turf/T in range(3, src))
		if(isspaceturf(T) || isindestructiblefloor(T) || isindestructiblewall(T))
			continue
		if(isopenturf(T))
			T.ChangeTurf(/turf/open/floor/mineral/plasma)
		else if(isclosedturf(T))
			T.ChangeTurf(/turf/closed/wall/mineral/plasma)
	..()

//======================
// Dark Blue
// Status: Working
//======================

/obj/item/slimecross/detonating/dark_blue
	colour = "dark blue"
	effect_desc = "Snap freezes the area, making everyone very cold and sharply plunging the air temperature."
	log_admin = TRUE
	log_message = "froze the area around them"

/obj/item/slimecross/detonating/dark_blue/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	for(var/turf/T in range(1, src))
		var/datum/gas_mixture/environment = T.return_air()
		environment.set_temperature(TCMB)
	for(var/mob/living/carbon/human/H in range(3, src))
		H.bodytemperature = BODYTEMP_COLD_DAMAGE_LIMIT - 20
	..()

//======================
// Silver
// Status: Working
//======================

/obj/item/slimecross/detonating/silver
	colour = "dark blue"
	effect_desc = "Fattens everyone within a 9x9 area."
	log_admin = TRUE
	log_message = "fattened everyone within 4 tiles"

/obj/item/slimecross/detonating/silver/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	for(var/mob/living/carbon/human/H in range(4, src))
		H.nutrition = NUTRITION_LEVEL_FAT + 50
	..()

//======================
// Bluespace
// Status: Working
//======================

/obj/item/slimecross/detonating/bluespace
	colour = "bluespace"
	effect_desc = "Alt click to store a location. Upon detonation triggers a powerful vacuum force and opens a wormhole to that location for 10 seconds."
	log_admin = TRUE
	log_message = "teleported created a bluespace wormhole"
	var/stored_location

/obj/item/slimecross/detonating/bluespace/AltClick(mob/user)
	if(!isliving(user))
		return ..()
	var/mob/living/L = user
	if(!L.canUseTopic(src, BE_CLOSE))
		return ..()
	to_chat(user, "<span class='notice'>You mark the current location.</span>")
	stored_location = get_turf(src)

/obj/item/slimecross/detonating/bluespace/can_trigger(mob/user)
	if(!stored_location)
		to_chat(user, "<span class='warning'>Store a location first!</span>")
		return FALSE
	return ..()

/obj/item/slimecross/detonating/bluespace/explode(mob/user)
	if(!stored_location)
		//Shouldn't be possible
		qdel(src)
	playsound(src, get_sfx("explosion"), 60)
	var/obj/effect/portal/anom/P = new(get_turf(src))
	var/obj/effect/portal/anom/target = new(stored_location)
	target.alpha = 0
	addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, P), 10 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, target), 10 SECONDS)
	P.link_portal(target)
	goonchem_vortex(get_turf(src), 0, 12)
	..()

//======================
// Sepia
// Status: Needs testing
//======================

/obj/item/slimecross/detonating/sepia
	colour = "sepia"
	effect_desc = "Slows time for projectiles mobs in a wide area, for 20 seconds and works through walls."
	log_admin = TRUE
	log_message = "froze nearby players"

/obj/item/slimecross/detonating/sepia/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	make_field(/datum/proximity_monitor/advanced/sepia_field, list("current_range" = 4, "host" = get_turf(src)))
	..()

/datum/proximity_monitor/advanced/sepia_field
	name = "\improper Reality Dissociation Field"
	setup_field_turfs = TRUE
	requires_processing = TRUE
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	var/list/tracked

/datum/proximity_monitor/advanced/sepia_field/Initialize()
	. = ..()
	addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, src), 20 SECONDS)

/datum/proximity_monitor/advanced/sepia_field/Destroy()
	. = ..()
	for(var/A in tracked)
		unapply_effect(A)

/datum/proximity_monitor/advanced/sepia_field/proc/apply_effect(atom/A)
	if(A in tracked)
		return
	A.add_atom_colour(list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0), TEMPORARY_COLOUR_PRIORITY)
	tracked += A
	if(isprojectile(A))
		var/obj/item/projectile/P = A
		P.speed *= 0.5
	else if(isliving(A))
		var/mob/living/L = A
		L.add_movespeed_modifier(MOVESPEED_ID_DETONATING, update = TRUE, priority=100, multiplicative_slowdown=2)
	if(ismovableatom(A))
		var/atom/movable/AM = A
		if(AM.throwing)
			var/datum/thrownthing/T = AM
			T.speed *= 0.5

/datum/proximity_monitor/advanced/sepia_field/proc/unapply_effect(atom/A)
	if(!(A in tracked))
		return
	A.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	tracked -= A
	if(isprojectile(A))
		var/obj/item/projectile/P = A
		P.speed *= 2
	else if(isliving(A))
		var/mob/living/L = A
		L.remove_movespeed_modifier(MOVESPEED_ID_DETONATING)
	if(ismovableatom(A))
		var/atom/movable/AM = A
		if(AM.throwing)
			var/datum/thrownthing/T = AM
			T.speed *= 2

/datum/proximity_monitor/advanced/sepia_field/field_turf_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_turf/F)
	. = ..()
	apply_effect(AM)

/datum/proximity_monitor/advanced/sepia_field/field_turf_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_turf/F)
	. = ..()
	if(!is_turf_in_field(get_turf(AM)))
		unapply_effect(AM)

/datum/proximity_monitor/advanced/sepia_field/setup_field_turf(turf/T)
	for(var/atom/movable/A in T.contents)
		if(A.throwing || isprojectile(A) || ismob(A))
			apply_effect(A)
	. = ..()

//======================
// Cerulean
// Status: Working
//======================

/obj/item/slimecross/detonating/cerulean
	colour = "cerulean"
	effect_desc = "Causes nearby animals to reproduce."
	log_admin = FALSE
	log_message = "caused nearby animals to reproduce"

/obj/item/slimecross/detonating/cerulean/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	var/limit = 20
	for(var/mob/living/simple_animal/SA in range(3, src))
		if(!LAZYLEN(SA.childtype))
			continue
		var/new_type = pick(SA.childtype)
		new new_type(get_turf(SA))
		new /obj/effect/temp_visual/love_heart(get_turf(SA))
		limit --
		if(limit <= 0)
			break
	..()

//======================
// Pyrite
// Status: Alt click doesn't work
//======================

/obj/item/slimecross/detonating/pyrite
	colour = "pyrite"
	effect_desc = "Creates a large foam reaction with a selected color."
	log_admin = FALSE
	log_message = "created a large foam reaction containing colourful reagent"
	var/static/list/colour_list = typecacheof(list(
		"red" = /datum/reagent/colorful_reagent/powder/red,
		"orange" = /datum/reagent/colorful_reagent/powder/orange,
		"yellow" = /datum/reagent/colorful_reagent/powder/yellow,
		"green" = /datum/reagent/colorful_reagent/powder/green,
		"blue" = /datum/reagent/colorful_reagent/powder/blue,
		"purple" = /datum/reagent/colorful_reagent/powder/purple,
		"black" = /datum/reagent/colorful_reagent/powder/black,
		"white" = /datum/reagent/colorful_reagent/powder/white
	))
	var/picked_colour

/obj/item/slimecross/detonating/pyrite/AltClick(mob/living/user)
	if(!istype(user))
		return ..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return ..()
	picked_colour = input(user, "Choose a color.", "Foam Colour") as null|anything in colour_list

/obj/item/slimecross/detonating/pyrite/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	var/datum/effect_system/foam_spread/color = new()
	//Setup reagents
	var/datum/reagents/R = new(200)
	if(picked_colour)
		R.add_reagent(colour_list[picked_colour], 200)
	else
		R.add_reagent(colour_list[pick(colour_list)], 200)
	//Go
	color.set_up(64, get_turf(src), R)
	color.start()
	..()

//======================
// Red
// Status: Working
//======================

/obj/item/slimecross/detonating/red
	colour = "red"
	effect_desc = "Covers everything nearby with blood."
	log_admin = TRUE
	log_message = "covered nearby objects in blood"

/obj/item/slimecross/detonating/red/Initialize()
	. = ..()
	create_reagents(10, INJECTABLE | DRAWABLE)

/obj/item/slimecross/detonating/red/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	//Are we injected with blood?
	var/datum/reagent/blood/blood = reagents.get_reagent(/datum/reagent/blood)
	//Cover floors in blood
	for(var/turf/open/T in range(5, src))
		var/obj/effect/decal/cleanable/blood/B = new(T)
		if(blood)
			B.add_blood_DNA(blood.data["blood_DNA"])
	//Cover self in blood
	for(var/mob/living/carbon/C in range(5, src))
		if(blood)
			for(var/datum/disease/D in blood.get_diseases())
				C.ForceContractDisease(D)
		C.bloody_hands = rand(2, 3)
		C.update_inv_gloves()
	..()

//======================
// Green
// Status: Working
//======================

/obj/item/slimecross/detonating/green
	colour = "green"
	effect_desc = "Applies a random mutation to all humans within a 9 tile radius."
	log_admin = TRUE
	log_message = "mutated nearby humans"

/obj/item/slimecross/detonating/green/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	var/datum/mutation/M = pick(GLOB.all_mutations)
	for(var/mob/living/carbon/human/H in view(9, src))
		H.dna.add_mutation(M)
	..()

//======================
// Pink
// Status: Testing
//======================

/obj/item/slimecross/detonating/pink
	colour = "pink"
	effect_desc = "Improves the mood of nearby mobs, but also decreases their capability to damage."
	log_admin = TRUE
	log_message = "weakened nearby humans"

/obj/item/slimecross/detonating/pink/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	for(var/mob/living/L in range(3, src))
		L.apply_status_effect(STATUS_EFFECT_RELAXED)
	..()

/datum/mood_event/relaxed
	description = "<span class='nicegreen'>I feel so relaxed, everyone is so friendly!</span>\n"
	mood_change = 12
	timeout = 45 SECONDS

/datum/status_effect/relaxed
	id = "relaxed"
	duration = 45 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	examine_text = "<span class='notice'>They are blushing and look like they don't want to fight.</span>"

/datum/status_effect/relaxed/on_apply()
	var/mob/living/L = owner
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "relaxed", /datum/mood_event/relaxed)
	L.damage_mod *= 0.8

/datum/status_effect/relaxed/on_remove()
	var/mob/living/L = owner
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "relaxed")
	L.damage_mod /= 0.8

//======================
// Gold
// Status: Working
//======================

/obj/item/slimecross/detonating/gold
	colour = "gold"
	effect_desc = "Summons ore is nearby stone."
	log_admin = FALSE
	log_message = "created ore in nearby stone"

/obj/item/slimecross/detonating/gold/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	for(var/turf/closed/mineral/M in view(4, src))
		if(prob(70))
			M.ChangeTurf(/turf/closed/mineral/random/high_chance/always)
	..()

//======================
// Oil
// Status: Working
//======================

/obj/item/slimecross/detonating/oil
	colour = "oil"
	effect_desc = "Comes into existance as gibtonite."

/obj/item/slimecross/detonating/oil/Initialize()
	. = ..()
	new /obj/item/twohanded/required/gibtonite/synthetic(get_turf(src))
	return INITIALIZE_HINT_QDEL

/obj/item/twohanded/required/gibtonite/synthetic
	name = "synthetic gibtonite"
	quality = GIBTONITE_QUALITY_HIGH

//======================
// Black
// Status: Working
//======================

/obj/item/slimecross/detonating/black
	colour = "black"
	effect_desc = "Blinds all players in sight range for 10 seconds, ignores eye protection. Aggressive or neutral simple mobs affected will stop moving and attack in a random direction as often as they're capable for the duration of the effect."
	log_admin = TRUE
	log_message = "blinded nearby mobs"

/obj/item/slimecross/detonating/black/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	for(var/mob/living/L in view(4, src))
		L.blind_eyes(5)	//10 seconds
	..()

//======================
// Light Pink
// Status: Working
//======================

/obj/item/slimecross/detonating/light_pink
	colour = "light pink"
	effect_desc = "Upon detonation will grant the holder 30 seconds of ghost vision."
	log_admin = FALSE
	log_message = "activated ghost vision"

/obj/item/slimecross/detonating/light_pink/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	if(!ismob(loc))
		return
	var/mob/holder = loc
	holder.see_invisible = SEE_INVISIBLE_OBSERVER
	addtimer(CALLBACK(holder, /mob.proc/set_see_invisible, initial(holder.see_invisible)), 30 SECONDS)
	..()

//======================
// Adamantine
// Status: Working (Somewhat dodgy - Could be remade into an actual object and buckle mobs to it)
//======================

/obj/item/slimecross/detonating/adamantine
	colour = "adamantine"
	effect_desc = "Coats, floors, walls, air locks and players in a thin adamantine shell - Players are prevented from moving until they resist free, air locks are unable to be operated until the shell is smashed off. Walls and Floors may not be interacted with via tools until the coating is smashed off of them as well. Adamantine is reflective to laser weaponry."
	log_admin = TRUE
	log_message = "coated nearby things in adamantine"

/obj/item/slimecross/detonating/adamantine/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	for(var/atom/A in range(4, src))
		if(isturf(A) || ismob(A) || isitem(A) || ismachinery(A) || isstructure(A))
			A.AddComponent(/datum/component/coated)
	..()

/datum/component/coated
	dupe_mode = COMPONENT_DUPE_UNIQUE

GLOBAL_LIST_INIT(adamantine_color_matrix, list("#4074d4", "#5290b9", "#846fce"))

/datum/component/coated/Initialize(...)
	var/atom/A = parent
	if(!(A.flags_1 & ADAMANTINE_COATED_1))
		A.name = "coated [A.name]"
		A.add_atom_colour(GLOB.adamantine_color_matrix, TEMPORARY_COLOUR_PRIORITY)
		A.flags_1 |= ADAMANTINE_COATED_1
	else
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/remove_coating)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/remove_coating)
	RegisterSignal(parent, COMSIG_MOB_HAND_ATTACKED, .proc/remove_coating)
	if(isliving(A))
		RegisterSignal(parent, COMSIG_LIVING_RESIST, .proc/try_break_out)
		RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, .proc/block_pre_move)

/datum/component/coated/proc/try_break_out()
	var/mob/living/L = parent
	to_chat(L, "<span class='notice'>You begin breaking out of the adamantine coating!</span>")
	if(do_after(L, 100, target=get_turf(L)))
		to_chat(L, "<span class='notice'>You smash the outer shell of the adamantine coating!</span>")
		remove_coating()

/datum/component/coated/proc/block_pre_move()
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/component/coated/proc/remove_coating()
	var/atom/A = parent
	if(A.flags_1 & ADAMANTINE_COATED_1)
		playsound(A, 'sound/effects/snap.ogg', 40)
		A.name = replacetext(A.name, "coated ", "")
		A.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, GLOB.adamantine_color_matrix)
		A.flags_1 &= ~ADAMANTINE_COATED_1
	qdel(src)

//======================
// Rainbow
// Status: Working
//======================

/obj/item/slimecross/detonating/rainbow
	colour = "rainbow"
	effect_desc = "Will explode, foam or create smoke when detonated."
	log_admin = TRUE
	log_message = "activated a rainbow slime grenade (usually bad!)"

/obj/item/slimecross/detonating/rainbow/explode(mob/user)
	playsound(src, get_sfx("explosion"), 60)
	if(prob(33))
		//Explode
		switch(rand(1, 3))
			if(1)
				tesla_zap(get_turf(src), 7, 20000)
			if(2)
				empulse(get_turf(src), 4, 10, TRUE)
			if(3)
				explosion(get_turf(src), 2, 4, 8)
	else
		var/datum/reagents/holder = new(60)
		for(var/i in 1 to 3)
			holder.add_reagent(pick(list(
				/datum/reagent/medicine/regen_jelly,
				/datum/reagent/medicine/omnizine,
				/datum/reagent/medicine/strange_reagent,
				/datum/reagent/drug/space_drugs,
				/datum/reagent/medicine/mine_salve,
				/datum/reagent/toxin/bonehurtingjuice,
				/datum/reagent/lube,
				/datum/reagent/medicine/tricordrazine,
				/datum/reagent/toxin/zombiepowder)), 20)
		if(prob(50))
			var/datum/effect_system/smoke_spread/S = new()
			S.set_up(6, get_turf(src), holder)
			S.start()
		else
			var/datum/effect_system/foam_spread/S = new()
			S.set_up(64, get_turf(src), holder)
			S.start()
	..()
