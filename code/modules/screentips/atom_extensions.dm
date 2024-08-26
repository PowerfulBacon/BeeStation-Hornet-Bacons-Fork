/**
 * This proc sucks, simply defining it means that a lot of information is going
 * to be communicated between the client and the server.
 * I have experimented with doing this clientside by using skin, but transparent elements
 * only render for a single frame before being removed.
 *
 * This will be very hot regardless of what is in this loop, and will appear on the profiler.
 * There is unfortunately nothing we can do about this until skin.dmf supports transparent background
 * labels.
 *
 * This may seem like a lot compared to a dictionary set, but this avoids the expensive operation
 * of dictionary indexing as it doesn't require hashing and just needs some super cheap
 * variable accesses
 */
/atom/MouseEntered(location, control, params)
	// If someone is connected to us in the queue, then we don't need to requeue
	if (usr.client.hovered_atom)
		usr.client.hovered_atom = src
		return
	// Holds a hard-reference for a single frame
	usr.client.hovered_atom = src
	usr.client.screentip_next = SSscreentips.head
	SSscreentips.head = usr.client

/// Called when a client mouses over this atom
/atom/proc/on_mouse_enter(client/client)
	var/screentip_message = "<span class='big'>[MAPTEXT(CENTER(capitalize(name)))]</span>"
	client.screentip_context.context_message = screentip_message
	add_context_self(client.screentip_context, client.mob, client.mob.get_active_held_item())
	client.mob.hud_used.screentip.maptext = client.screentip_context.context_message

/// Indicates that this atom uses contexts, in any form
/atom/proc/register_context()

/// Add context tips
/atom/proc/add_context_self(datum/screentip_context/context, mob/user, obj/item/item)
	return

/// Generate context tips for when we are using this item
/obj/item/proc/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	return

/// Add context tips for when we are doing something
/mob/proc/add_context_interaction(datum/screentip_context/context, atom/target)
	return
