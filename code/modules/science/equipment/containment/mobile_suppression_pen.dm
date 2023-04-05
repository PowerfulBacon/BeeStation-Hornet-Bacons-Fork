/obj/structure/mobile_suppression_pen
	name = "mobile suppression pen"
	desc = "A mobile container with built in suppression capabilities. Uses an internal battery cell in order to power its micro-suppression field, \
		upon running out of charge the contained anomaly will break free."
	icon = 'icons/obj/anomaly_science/anomaly_machines.dmi'
	icon_state = "containment_pen"
	anchored = FALSE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	var/is_processing = FALSE
	var/integrity_level = 3
	var/suppression_charge
	var/max_suppression_charge = 5000

/obj/structure/mobile_suppression_pen/Initialize(mapload)
	. = ..()
	suppression_charge = max_suppression_charge

//========================
// Containment
//========================

/obj/structure/mobile_suppression_pen/process(delta_time)
	// Check if we have an anomaly in our contents
	var/has_anomaly = FALSE
	for (var/atom/movable/contained in contents)
		var/datum/component/anomaly_base/anomaly_component = contained.GetComponent(/datum/component/anomaly_base)
		if (!anomaly_component)
			continue
		has_anomaly = TRUE
		adjust_charge(delta_time * -30)
	if (has_anomaly)
		return
	// Recharge (30 per second (~1.5 minutes seconds to full charge))
	adjust_charge(delta_time * 60)
	if (suppression_charge == max_suppression_charge)
		is_processing = FALSE
		return PROCESS_KILL

/obj/structure/mobile_suppression_pen/proc/containment_check(atom/movable/target)
	// Generic Checks
	if (target.anchored)
		return FALSE
	if (!istype(target))
		return FALSE
	if (length(contents))
		return FALSE
	if (get_dist(target, src) > 1)
		return FALSE
	// Actual anomaly checks
	var/datum/component/anomaly_base/anomaly_component = target.GetComponent(/datum/component/anomaly_base)
	if (!anomaly_component)
		// Only non-anomalous mobs and items can be contained, non-anomalous machines can't be
		// otherwise we can contain a suppression pen inside a suppression pen and risk creating
		// a loop.
		if (!ismob(target) && !isitem(target))
			return FALSE
		return TRUE
	// Check if we are immobilised and stabilised
	if (anomaly_component != ANOMALY_STATE_STABLE)
	return TRUE

/obj/structure/mobile_suppression_pen/proc/adjust_charge(charge_amount)
	suppression_charge = CLAMP(suppression_charge + charge_amount, 0, max_suppression_charge)
	var/new_integrity_level = CLAMP(FLOOR(suppression_charge / max_suppression_charge * 4, 1), 0, 3)
	if (integrity_level != new_integrity_level)
		integrity_level = new_integrity_level
		update_appearance(UPDATE_ICON)
	// If no integrity
	if (suppression_charge <= 0)
		// Containment breach
		containment_breach()
	// If needs charge
	if (suppression_charge < max_suppression_charge && !is_processing)
		is_processing = TRUE
		START_PROCESSING(SSmachines, src)

/obj/structure/mobile_suppression_pen/proc/containment_breach()
	visible_message("<span class='danger'>The suppression field shuts down!</span>")
	balloon_alert_to_viewers("The suppression field shuts down!")
	for (var/atom/movable/contained_entity in contents)
		contained_entity.forceMove(loc)
		// Begin the containment breach (again)
		SEND_SIGNAL(contained_entity, COMSIG_ANOMALY_BREACH)

//========================
// User Interface
//========================

//========================
// Contents Management
//========================

/obj/structure/mobile_suppression_pen/Destroy(force = FALSE)
	// If force destroyed, delete indestructible contents along
	// with the current contents.
	if (force)
		return ..()
	// Drop indestructible contents in order to prevent their
	// deletion
	for (var/obj/thing in contents)
		if (thing.resistance_flags & INDESTRUCTIBLE)
			thing.forceMove(loc)
	// Delete
	return ..()

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
	if (!do_after(user, 15 SECONDS, O))
		O.balloon_alert(user, "You fail to contain [O]!", color="#ff9090")
		return
	// Place the object in containment
	if (!containment_check(O))
		O.balloon_alert(user, "You fail to contain [O]!", color="#ff9090")
		return
	O.forceMove(src)

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
	add_overlay(image(icon(icon, "container_integrity_[integrity_level]"), layer=layer+0.03))
	// Do whatever else we need to do
	return ..()

/obj/structure/mobile_suppression_pen/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_appearance(UPDATE_ICON)
	if (!is_processing)
		is_processing = TRUE
		START_PROCESSING(SSmachines, src)
	// Send the containment signal, we will handle breaching ourselves
	SEND_SIGNAL(arrived, COMSIG_ANOMALY_CONTAINED)

/obj/structure/mobile_suppression_pen/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance(UPDATE_ICON)
