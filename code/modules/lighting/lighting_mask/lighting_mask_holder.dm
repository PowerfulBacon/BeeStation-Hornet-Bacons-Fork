/obj/effect/lighting_mask_holder
	name = "light mask holder lol"
	anchored = TRUE
	appearance_flags = TILE_BOUND
	glide_size = INFINITY
	var/client/owner
	var/list/contained_images = list()
	var/list/referenced_masks = list()
	var/atom/movable/contained_atom
	var/atom/containing_atom

/obj/effect/lighting_mask_holder/Initialize(loc, client/owner)
	. = ..()
	if(owner == null)
		CRASH("Lighting mask holder initialized with no client.")
	SSlighting.light_mask_holders += src
	src.owner = owner
	containing_atom = get_containing_atom()
	change_contained_atom(null, containing_atom)
	//Add any light masks that are initialy in range
	//TODO: Add when a light source is created
	var/list/L = get_sources_in_range()
	for(var/a in L)
		if(!(a in referenced_masks))
			display_light_mask(a)

/obj/effect/lighting_mask_holder/Destroy(force)
	for(var/image/I as() in contained_images)
		I.vis_contents.Cut()
	//TODO: harddels lol
	SSlighting.light_mask_holders -= src
	. = ..()

/obj/effect/lighting_mask_holder/proc/get_containing_atom()
	var/sanity = 20
	var/atom/parent = owner.mob
	while(sanity && parent?.loc && !isturf(parent.loc))
		parent = parent.loc
		sanity --
	return parent

/obj/effect/lighting_mask_holder/proc/loc_changed()
	if(contained_atom)
		forceMove(get_turf(contained_atom))
	else if(owner)
		forceMove(get_turf(owner.mob))
	else
		CRASH("Lighting mask holder has no client in loc_changed.")
	//No contained atom, or the contained atom was put inside something
	var/turf/our_turf = get_turf(src)
	var/turf/their_turf = contained_atom ? get_turf(contained_atom) : null
	if(their_turf != our_turf || !isturf(contained_atom.loc))
		var/atom/containing_thing = get_containing_atom()
		if(containing_thing != containing_atom)
			change_contained_atom(containing_atom, containing_thing)
			containing_atom = containing_thing

/obj/effect/lighting_mask_holder/proc/change_contained_atom(atom/oldA, atom/newA)
	if(oldA)
		UnregisterSignal(oldA, COMSIG_MOVABLE_MOVED)
	RegisterSignal(newA, COMSIG_MOVABLE_MOVED, .proc/loc_changed)

//Holds the holder for the holder of the lighting mask.
/obj/effect/lighting_mask_holder/Moved(atom/OldLoc, Dir)
	. = ..()
	//Step 0:
	check_new_sources()
	//Step 1:
	//Translate all contained images.
	//Remove any light masks that have moved out of range
	update_contained_images(OldLoc)

/obj/effect/lighting_mask_holder/proc/check_new_sources()
	//Add any light masks that have moved into range.
	var/list/L = get_sources_in_range()
	for(var/a in L)
		if(!(a in referenced_masks))
			display_light_mask(a)

/obj/effect/lighting_mask_holder/proc/get_sources_in_range()
	var/list/check_range = getviewsize(world.view, 0, 0)
	var/list/all_lighting_sources = list()
	var/turf/T = get_turf(src)
	for(var/x in max(T.x - check_range[1], 1) to min(T.x + check_range[1], world.maxx))
		for(var/y in max(T.y - check_range[2], 1) to min(T.y + check_range[2], world.maxy))
			//Add all sources
			all_lighting_sources += SSlighting.light_source_grid[T.z][x][y][LIGHT_SOURCE]
	return all_lighting_sources
	//message_admins("Lighting mask holder moved: There are now [all_lighting_sources.len] sources in view.")

/obj/effect/lighting_mask_holder/proc/update_contained_images(atom/OldLoc)
	var/list/check_range = getviewsize(world.view, 1, 1)
	var/turf/old_turf = get_turf(OldLoc)
	var/turf/T = get_turf(src)
	var/delta_x = (old_turf.x - T.x) * world.icon_size
	var/delta_y = (old_turf.y - T.y) * world.icon_size
	for(var/image/I as() in contained_images)
		I.loc = loc
		I.pixel_x += delta_x
		I.pixel_y += delta_y
		//If the image moved out of view, stop viewing it.
		if(abs(I.pixel_x) > (check_range[1] * world.icon_size) || abs(I.pixel_y) > (check_range[2] * world.icon_size))
			contained_images -= I
			owner.images -= I
			qdel(I)

/obj/effect/lighting_mask_holder/proc/display_light_mask(datum/light_source/held_mask)
	//So we make the holder and put it on the turf of the holder's holder's holder
	//Then we shift it by pixel x and pixel y
	var/image/light_mask_holder_holder = image(loc = loc, layer = LIGHTING_SHADOW_LAYER)
	//IMAGES CAN HAVE VIS_CONTENTS WHAT! <-- my reaction when I found this out
	light_mask_holder_holder.vis_contents += held_mask.our_mask
	//Shift it accordingly
	var/turf/whereweat = get_turf(src)
	var/delta_x = held_mask.x - whereweat.x
	var/delta_y = held_mask.y - whereweat.y
	light_mask_holder_holder.pixel_x = delta_x * world.icon_size
	light_mask_holder_holder.pixel_y = delta_y * world.icon_size
	contained_images += light_mask_holder_holder
	owner.images += light_mask_holder_holder
	referenced_masks += held_mask
