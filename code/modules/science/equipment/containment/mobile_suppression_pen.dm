/obj/structure/mobile_suppression_pen
	name = "mobile suppression pen"
	desc = "A mobile container with built in suppression capabilities. Uses an internal battery cell in order to power its micro-suppression field, \
		upon running out of charge the contained anomaly will break free."
	icon = 'icons/obj/anomaly_science/anomaly_machines.dmi'
	icon_state = "containment_pen"
	anchored = FALSE
	can_buckle = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER

//========================
// Containment
//========================

/obj/structure/mobile_suppression_pen/proc/containment_check(atom/movable/target)
	if (!istype(target))
		return FALSE
	if (length(contents))
		return FALSE
	if (get_dist(target, src) > 1)
		return FALSE
	return TRUE

//========================
// Contents Management
//========================

/obj/structure/mobile_suppression_pen/deconstruct(disassembled)
	// Drop contents
	for (var/atom/movable/thing in contents)
		thing.forceMove(loc)
	// Continue with destruction
	return ..()

/obj/structure/mobile_suppression_pen/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	// Start moving the object into containment
	user.visible_message(\
		"<span class='notice'>[user] starts placing [O] into [src]...<span>",\
		"<span class='notice'>You start to place [O] into [src]...<span>")
	if (!containment_check(O))
		return
	if (ismob(O))
		if (user == O)
			O.balloon_alert(O, "You start climbing into [src]!", color="#ff9090")
		else
			O.balloon_alert(O, "[user] is placing you into [src]!", color="#ff9090")
	if (user != O)
		O.balloon_alert(user, "You try to place [O] into [src]...", color="#a5f3a9")
	// Add the progress bar
	if (!do_after(user, 15 SECONDS, TRUE, O))
		O.balloon_alert(user, "You fail to contain [O]!", color="#ff9090")
		return
	// Place the object in containment
	if (!containment_check(O))
		O.balloon_alert(user, "You fail to contain [O]!", color="#ff9090")
		return
	O.forceMove(src)
	update_appearance(UPDATE_ICON)

//========================
// Icon Handling
//========================

/obj/structure/mobile_suppression_pen/update_icon(updates)
	// Add the underlay
	icon_state = "container_back"
	cut_overlays()

	// Display the thing we are containing
	for (var/atom/movable/contained in contents)
		var/image/contained_entity = image(icon())
		contained_entity.add_overlay(contained)
		contained_entity.pixel_y = 2
		contained_entity.layer = layer+0.01
		contained_entity.appearance_flags = KEEP_TOGETHER
		// Determine how much we need to resize
		var/icon/determinator = icon(contained.icon, contained.icon_state)
		var/size = max(determinator.Width(), determinator.Height())
		contained_entity.transform = matrix() * (world.icon_size / size) * 0.95
		add_overlay(contained_entity)

	// Add the overlays
	add_overlay(image(icon(icon, "container_front"), layer=layer+0.02))
	add_overlay(image(icon(icon, "container_integrity_3"), layer=layer+0.03))
	// Do whatever else we need to do
	return ..()

/obj/structure/mobile_suppression_pen/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/structure/mobile_suppression_pen/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance(UPDATE_ICON)

//========================
// Buckling Behaviour
//========================

/obj/structure/mobile_suppression_pen/buckle_mob(mob/living/M, force, check_loc)
	if(!is_buckle_possible(M, force, check_loc))
		return FALSE
	M.buckling = src

	if(!M.can_buckle() && !force)
		if(M == usr)
			to_chat(M, "<span class='warning'>You are unable to buckle yourself to [src]!</span>")
		else
			to_chat(usr, "<span class='warning'>You are unable to buckle [M] to [src]!</span>")
		M.buckling = null
		return FALSE

	if(M.pulledby)
		if(buckle_prevents_pull)
			M.pulledby.stop_pulling()
		else if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.reset_pull_offsets(M, TRUE)

	M.forceMove(src)
	update_appearance(UPDATE_ICON)

/obj/structure/mobile_suppression_pen/is_buckle_possible(mob/living/target, force, check_loc)
	if (!containment_check(target))
		return FALSE
	return ..()
