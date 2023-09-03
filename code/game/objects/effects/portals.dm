
/proc/create_portal_pair(turf/source, turf/destination, _creator = null, _lifespan = 300, accuracy = 0, newtype = /obj/effect/portal, atmos_link_override)
	if(!istype(source) || !istype(destination))
		return
	var/turf/actual_destination = get_teleport_turf(destination, accuracy)
	var/obj/effect/portal/P1 = new newtype(source, _creator, _lifespan, null, FALSE, null, atmos_link_override)
	var/obj/effect/portal/P2 = new newtype(actual_destination, _creator, _lifespan, P1, TRUE, null, atmos_link_override)
	if(!istype(P1)||!istype(P2))
		return
	P1.link_portal(P2)
	P1.hardlinked = TRUE
	return list(P1, P2)

/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	anchored = TRUE
	density = TRUE // dense for receiving bumbs
	layer = HIGH_OBJ_LAYER
	var/mech_sized = FALSE
	var/obj/effect/portal/linked
	var/hardlinked = TRUE			//Requires a linked portal at all times. Destroy if there's no linked portal, if there is destroy it when this one is deleted.
	var/teleport_channel = TELEPORT_CHANNEL_BLUESPACE
	var/creator
	var/turf/hard_target			//For when a portal needs a hard target and isn't to be linked.
	var/atmos_link = FALSE			//Link source/destination atmos.
	var/turf/open/atmos_source		//Atmos link source
	var/turf/open/atmos_destination	//Atmos link destination
	var/allow_anchored = FALSE
	var/innate_accuracy_penalty = 0
	var/last_effect = 0
	// Are we currently being dispelled from a hand teleporter?
	var/is_dispeling = FALSE

/obj/effect/portal/proc/dispel()
	if (is_dispeling)
		return
	is_dispeling = TRUE
	animate(src, 1 SECONDS, transform = matrix() * 1.2, easing = SINE_EASING)
	animate(transform = matrix() * 0.6, 1.7 SECONDS, easing = QUAD_EASING)
	animate(transform = matrix() * 0, alpha = 0, 0.3 SECONDS, easing = QUAD_EASING)
	QDEL_IN(src, 3 SECONDS)
	if (linked)
		linked.dispel()

/obj/effect/portal/anom
	name = "wormhole"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	layer = RIPPLE_LAYER
	mech_sized = TRUE
	teleport_channel = TELEPORT_CHANNEL_WORMHOLE

/obj/effect/portal/Move(newloc)
	for(var/T in newloc)
		if(istype(T, /obj/effect/portal))
			return FALSE
	return ..()

/obj/effect/portal/item_interact(obj/item/W, mob/user, params)
	if(user && Adjacent(user))
		teleport(user)
		return TRUE
	return ..()

/obj/effect/portal/Bumped(atom/movable/bumper)
	teleport(bumper)

/obj/effect/portal/newtonian_move(direction, instant = FALSE) // Prevents portals spawned by jaunter/handtele from floating into space when relocated to an adjacent tile.
	return TRUE

/obj/effect/portal/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(HAS_TRAIT(mover, TRAIT_NO_TELEPORT))
		return TRUE

/obj/effect/portal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(Adjacent(user))
		teleport(user)

/obj/effect/portal/attack_robot(mob/living/user)
	if(Adjacent(user))
		teleport(user)

/obj/effect/portal/Initialize(mapload, _creator, _lifespan = 0, obj/effect/portal/_linked, automatic_link = FALSE, turf/hard_target_override, atmos_link_override)
	. = ..()
	GLOB.portals += src
	if(!istype(_linked) && automatic_link)
		. = INITIALIZE_HINT_QDEL
		CRASH("Somebody fucked up.")
	if(_lifespan > 0)
		addtimer(CALLBACK(src, PROC_REF(dispel)), _lifespan)
	if(!isnull(atmos_link_override))
		atmos_link = atmos_link_override
	link_portal(_linked)
	hardlinked = automatic_link
	creator = _creator
	if(isturf(hard_target_override))
		hard_target = hard_target_override

/obj/effect/portal/singularity_pull()
	return

/obj/effect/portal/singularity_act()
	return

/obj/effect/portal/proc/link_portal(obj/effect/portal/newlink)
	linked = newlink
	if(atmos_link)
		link_atmos()

/obj/effect/portal/proc/link_atmos()
	if(atmos_source || atmos_destination)
		unlink_atmos()
	if(!isopenturf(get_turf(src)))
		return FALSE
	if(linked)
		if(isopenturf(get_turf(linked)))
			atmos_source = get_turf(src)
			atmos_destination = get_turf(linked)
	else if(hard_target)
		if(isopenturf(hard_target))
			atmos_source = get_turf(src)
			atmos_destination = hard_target
	else
		return FALSE
	if(!istype(atmos_source) || !istype(atmos_destination))
		return FALSE
	LAZYINITLIST(atmos_source.atmos_adjacent_turfs)
	LAZYINITLIST(atmos_destination.atmos_adjacent_turfs)
	if(atmos_source.atmos_adjacent_turfs[atmos_destination] || atmos_destination.atmos_adjacent_turfs[atmos_source])	//Already linked!
		return FALSE
	atmos_source.atmos_adjacent_turfs[atmos_destination] = TRUE
	atmos_destination.atmos_adjacent_turfs[atmos_source] = TRUE
	atmos_source.air_update_turf(FALSE)
	atmos_destination.air_update_turf(FALSE)

/obj/effect/portal/proc/unlink_atmos()
	if(istype(atmos_source))
		if(istype(atmos_destination) && !atmos_source.Adjacent(atmos_destination) && !CANATMOSPASS(atmos_destination, atmos_source))
			LAZYREMOVE(atmos_source.atmos_adjacent_turfs, atmos_destination)
		atmos_source = null
	if(istype(atmos_destination))
		if(istype(atmos_source) && !atmos_destination.Adjacent(atmos_source) && !CANATMOSPASS(atmos_source, atmos_destination))
			LAZYREMOVE(atmos_destination.atmos_adjacent_turfs, atmos_source)
		atmos_destination = null

/obj/effect/portal/Destroy(force)				//Calls on_portal_destroy(destroyed portal, location of destroyed portal) on creator if creator has such call.
	if(creator && hascall(creator, "on_portal_destroy"))
		call(creator, "on_portal_destroy")(src, src.loc)
	creator = null
	GLOB.portals -= src
	unlink_atmos()
	if(hardlinked && !QDELETED(linked))
		QDEL_NULL(linked)
	else
		linked = null
	return ..()

/obj/effect/portal/attack_ghost(mob/dead/observer/O)
	if(!teleport(O, TRUE))
		return ..()

/obj/effect/portal/proc/teleport(atom/movable/M, force = FALSE)
	if(!force && (!istype(M) || iseffect(M) || (ismecha(M) && !mech_sized) || (!isobj(M) && !ismob(M)))) //Things that shouldn't teleport.
		return
	var/turf/real_target = get_link_target_turf()
	if(!istype(real_target))
		return FALSE
	if(!force && (!ismecha(M) && !istype(M, /obj/projectile) && M.anchored && !allow_anchored))
		return
	if(ismegafauna(M))
		message_admins("[M] has used a portal at [ADMIN_VERBOSEJMP(src)] made by [usr].")
	var/no_effect = FALSE
	if(last_effect == world.time)
		no_effect = TRUE
	else
		last_effect = world.time
	if(do_teleport(M, real_target, innate_accuracy_penalty, no_effects = no_effect, channel = teleport_channel, no_wake = TRUE))
		if(istype(M, /obj/projectile))
			var/obj/projectile/P = M
			P.ignore_source_check = TRUE
		return TRUE
	return FALSE

/obj/effect/portal/proc/get_link_target_turf()
	var/turf/real_target
	if(!istype(linked) || QDELETED(linked))
		if(hardlinked)
			qdel(src)
		if(!istype(hard_target) || QDELETED(hard_target))
			hard_target = null
			return
		else
			real_target = hard_target
			linked = null
	else
		real_target = get_turf(linked)
	return real_target

/obj/effect/portal/permanent
	name = "permanent portal"
	desc = "An unwavering portal that will never fade."
	var/id // var edit or set id in map editor
	hardlinked = FALSE // dont qdel my portal nerd

/obj/effect/portal/permanent/Initialize(mapload, _creator, _lifespan = 0, obj/effect/portal/_linked, automatic_link = FALSE, turf/hard_target_override, atmos_link_override)
	. = ..()
	set_linked()

/obj/effect/portal/permanent/proc/get_linked()
	if(!id)
		return
	var/list/possible = list()
	for(var/obj/effect/portal/permanent/P in GLOB.portals - src)
		if(P.id && P.id == id) // gets portals with the same id, there should only be two permanent portals with the same id
			possible += P
	return possible

/obj/effect/portal/permanent/proc/set_linked()
	var/list/possible = get_linked()
	if(!possible || !possible.len)
		return
	for(var/obj/effect/portal/permanent/other in possible)
		other.linked = src
	linked = pick(possible)

/obj/effect/portal/permanent/teleport(atom/movable/M, force = FALSE)
	// try to search for a new one if something was var edited etc
	set_linked()
	. = ..()

/obj/effect/portal/permanent/one_way // doesn't have a return portal
	name = "one-way portal"
	desc = "You get the feeling that this might not be the safest thing you've ever done."
	var/list/possible_exits = list()
	var/keep // if this is a portal that should be kept

/obj/effect/portal/permanent/one_way/set_linked()
	if(!keep) // wait for a keep portal to set
		return
	var/list/possible_temp = get_linked()
	if(possible_temp?.len)
		for(var/obj/effect/portal/permanent/other in possible_temp)
			possible_exits += get_turf(other)
			qdel(other)
	if(possible_exits && possible_exits.len)
		hard_target = pick(possible_exits)

/obj/effect/portal/permanent/one_way/keep // because its nice to be able to tell which is which on the map
	keep = TRUE

/obj/effect/portal/permanent/one_way/destroy
	keep = FALSE
