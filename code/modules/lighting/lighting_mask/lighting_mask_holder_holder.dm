/*
 * A holder for the lighting mask holder
 * Lfmao wtf am I doing.
 * Basically these are for a single client only.
 * I am confused out of my fucking mind and slowly losing sanity.
 */

/client/verb/lighting_test()
	set name = "lighting test"
	set category = "lighting test"
	var/obj/effect/lighting_mask_holder_holder_holder/lmhhh = new(get_turf(mob), src)
	for(var/obj/effect/lighting_mask_holder/lmh in world)
		lmhhh.display_light_mask(lmh)

//THIS IS CLIENT BASED
//THE HELD IMAGES ARE CLIENT BASED
//THE HELD HOLDERS INSIDE THE HELD IMAGES ARE INSTANCED
/obj/effect/lighting_mask_holder_holder_holder
	var/client/owner
	var/list/contained_images = list()

/obj/effect/lighting_mask_holder_holder_holder/Initialize(loc, client/owner)
	. = ..()
	src.owner = owner

//Holds the holder for the holder of the lighting mask.
/obj/effect/lighting_mask_holder_holder_holder/Moved(atom/OldLoc, Dir)
	. = ..()
	//Step 1:
	//Translate all contained images.

/obj/effect/lighting_mask_holder_holder_holder/proc/display_light_mask(obj/effect/lighting_mask_holder/held_mask)
	//So we make the holder and put it on the turf of the holder's holder's holder
	//Then we shift it by pixel x and pixel y
	var/image/light_mask_holder_holder = image(loc = loc, layer = LIGHTING_SHADOW_LAYER)
	//IMAGES CAN HAVE VIS_CONTENTS WHAT! <-- my reaction when I found this out
	light_mask_holder_holder.vis_contents += held_mask
	//Shift it accordingly
	var/turf/whereweat = get_turf(src)
	var/turf/wheretheyat = get_turf(held_mask)
	var/delta_x = whereweat.x - wheretheyat.x
	var/delta_y = whereweat.y - wheretheyat.y
	light_mask_holder_holder.pixel_x = delta_x * world.icon_size
	light_mask_holder_holder.pixel_y = delta_y * world.icon_size
	contained_images += light_mask_holder_holder
	owner.images += light_mask_holder_holder
