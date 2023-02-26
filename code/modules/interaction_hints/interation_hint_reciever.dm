/// Interaction hint reciever.
/// This component indicates that this atom contains a client that wants
/// to recieve interaction hints.
///
/// Essentially, this will just be applied to all mobs that have a client.
///
/// It's purpose is to track
///
/// Author: @PowerfulBacon 2023

/datum/component/interaction_hint_reciever
	var/client/target
	// List of hint layers that we can recieve
	// When we move, these are the ones that we re-consider
	var/list/recievable_hint_layers = list()
	// Lookup table of interaction hints we are recieving
	// to the overlay we are displaying
	var/list/displaying_hints = list()

/datum/component/interaction_hint_reciever/Initialize(client/owner)
	. = ..()
	if (!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/move)
	RegisterSignal(parent, COMSIG_MOB_LOGIN, .proc/login)
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, .proc/logout)

/datum/component/interaction_hint_reciever/proc/login()
	// Determine all hints that we need to display and display them
	var/mob/mob = parent
	if (!mob.loc)
		return
	for (var/layer in recievable_hint_layers)
		var/datum/spatial_tree/map = SSinteraction_hints.get_map()
		var/list/hints_at_location

/datum/component/interaction_hint_reciever/proc/logout()
	var/mob/mob = parent
	// The mob didn't logout, they changed mob
	for (var/target_hint in displaying_hints)
		remove_hint(target_hint)
	target = null

/datum/component/interaction_hint_reciever/proc/move()

/datum/component/interaction_hint_reciever/proc/provide_hint(datum/interaction_hint/target_hint)
	displaying_hints[target_hint] = target_hint.create_and_display_to(target)

/datum/component/interaction_hint_reciever/proc/remove_hint(datum/interaction_hint/target_hint)
	var/hint_image = displaying_hints[target_hint]
	// Stop drawing the image if the client is still logged in
	if (target)
		target.images -= hint_image
	// Remove from the array
	displaying_hints -= target_hint
	// Delete the image
	qdel(hint_image)
