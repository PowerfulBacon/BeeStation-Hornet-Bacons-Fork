// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	var/atom/source_atom     // The atom that we belong to.
	var/atom/movable/contained_atom		//The atom that the source atom is contained inside
	var/atom/cached_loc	//The loc where we were

	var/x
	var/y
	var/z

	var/turf/source_turf     // The turf under the above.
	var/turf/pixel_turf      // The turf the top_atom appears to over.

	var/light_power = 0    					// Intensity of the emitter light.
	var/light_range = 0      				// The range of the emitted light.
	var/light_color = NONSENSICAL_VALUE    // The colour of the light, string, decomposed by parse_light_color()

	var/applied = FALSE // Whether we have applied our light yet or not.

	var/mask_type
	//OUR LIGHTING MASK
	//EXISTS IN NULLSPACE, USED AS AN IMAGE FOR CLIENTS
	var/atom/movable/lighting_mask/our_mask
	//Light mask holders we inside
	var/list/lighting_mask_holders = list()

// Thanks to Lohikar for flinging this tiny bit of code at me, increasing my brain cell count from 1 to 2 in the process.
// This macro will only offset up to 1 tile, but anything with a greater offset is an outlier and probably should handle its own lighting offsets.
// Anything pixelshifted 16px or more will be considered on the next tile.
#define GET_APPROXIMATE_PIXEL_DIR(PX, PY) ((!(PX) ? 0 : ((PX >= 16 ? EAST : (PX <= -16 ? WEST : 0)))) | (!PY ? 0 : (PY >= 16 ? NORTH : (PY <= -16 ? SOUTH : 0))))
#define UPDATE_APPROXIMATE_PIXEL_TURF var/_mask = GET_APPROXIMATE_PIXEL_DIR(top_atom.pixel_x, top_atom.pixel_y); pixel_turf = _mask ? (get_step(source_turf, _mask) || source_turf) : source_turf

/datum/light_source/New(var/atom/movable/owner, mask_type)
	source_atom = owner // Set our new owner.
	LAZYADD(source_atom.light_sources, src)
	//Find the atom that contains us
	find_containing_atom()

	source_turf = get_turf(source_atom)

	if(!mask_type)
		if(owner.light_source_type == QUICK_LIGHTING)
			mask_type = /atom/movable/lighting_mask/quick_light
		else
			mask_type = /atom/movable/lighting_mask
	src.mask_type = mask_type
	our_mask = new mask_type
	our_mask.attached_atom = owner

	//Set light vars
	set_light(owner.light_range, owner.light_power, owner.light_color)

	//Calculate shadows
	our_mask.calculate_lighting_shadows()

	//Set direction
	our_mask.holder_turned(contained_atom.dir)

	//Get the position of the light source
	x = source_turf.x
	y = source_turf.y
	z = source_turf.z

	SSlighting.light_sources += src
	SSlighting.light_source_grid[z][x][y][LIGHT_SOURCE] += src

	//Create initial light
	for(var/obj/effect/lighting_mask_holder/holder in SSlighting.light_mask_holders)
		holder.check_new_sources()

/datum/light_source/Destroy(...)
	SSlighting.light_sources -= src
	SSlighting.light_source_grid[z][x][y][LIGHT_SOURCE] -= src
	//Remove references to ourself.
	LAZYREMOVE(source_atom?.light_sources, src)
	LAZYREMOVE(contained_atom?.light_sources, src)
	for(var/obj/effect/lighting_mask_holder/mask_holder in lighting_mask_holders)
		mask_holder.vis_contents -= our_mask
	lighting_mask_holders.Cut()
	qdel(our_mask)
	return ..()

/datum/light_source/proc/find_containing_atom()
	//Remove ourselves from the old containing atoms light sources
	if(contained_atom && contained_atom != source_atom)
		LAZYREMOVE(contained_atom.light_sources, src)
	//Find our new container
	if(isturf(source_atom) || isarea(source_atom))
		contained_atom = source_atom
		return

	contained_atom = source_atom.loc
	for(var/sanity in 1 to 20)
		if(!contained_atom)
			//Welcome to nullspace my friend.
			contained_atom = source_atom
			return
		if(istype(contained_atom.loc, /turf))
			break
		contained_atom = contained_atom.loc
	//Add ourselves to their light sources
	if(contained_atom != source_atom)
		LAZYADD(contained_atom.light_sources, src)

//Update light if changed.
/datum/light_source/proc/set_light(var/l_range, var/l_power, var/l_color = NONSENSICAL_VALUE)
	if(!our_mask)
		return
	if(l_range && l_range != light_range)
		light_range = l_range
		our_mask.set_radius(l_range)
	if(l_power && l_power != light_power)
		light_power = l_power
		our_mask.set_intensity(l_power)
	if(l_color != NONSENSICAL_VALUE && l_color != light_color)
		light_color = l_color
		our_mask.set_colour(l_color)

/datum/light_source/proc/update_position()
	var/turf/new_turf = get_turf(source_atom)

	//Remove old source
	SSlighting.light_source_grid[z][x][y][LIGHT_SOURCE] -= src

	//Add new
	x = new_turf.x
	y = new_turf.y
	z = new_turf.z
	SSlighting.light_source_grid[z][x][y][LIGHT_SOURCE] += src

	//Find our containing atom.
	find_containing_atom()
