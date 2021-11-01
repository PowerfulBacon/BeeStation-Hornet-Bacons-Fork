
/*
 * Code by @powerfulbacon#3338
 * This holds images that contain light masks in their vis contents.
 * This allows light masks to be rendered even when out of view, without using the laggy render calculation that comes with disabling TILE_BOUND
 * This simple trick makes the entire lighting feasable, without it, it would be a laggy mess.
 *
 * REFERENCE DIRECTORY:
 * Client > Lighting Mask Holder > Source > Mask
 *          Lighting Mask Holder > Mask
 *          Lighting Mask Holder > Client
 * Masks can never be deleted unless the source is deleted.
 * Upon source deletion, we need to clear the mask from our referenced things to avoid hard dels.
 */

/atom/movable/lighting_mask_holder
	name = "light mask holder lol"
	anchored = TRUE
	appearance_flags = TILE_BOUND
	glide_size = INFINITY

	//Recorded position in the light source grid
	var/grid_x = 0
	var/grid_y = 0
	var/grid_z = 0

	//Viewer width and height
	var/viewer_width = 7
	var/viewer_height = 9

	//The client that owns this
	var/client/owner
	//The top level atom we are contained within
	var/atom/containing_atom
	//The images we are holding
	//Assoc list
	//Key = source
	//Value = Image
	var/list/sources_visible = list()

/atom/movable/lighting_mask_holder/proc/assign(client/C)
	if(!SSlighting.initialized)
		//Defer initialization
		SSlighting.deferred_viewer_inits[src] = C
		log_lighting("Deferred initialization of [C]'s holder until SSlighting initialization.")
		return
	if(!C)
		log_lighting("lighting mask holder initialized without a client!")
		message_admins("lighting mask holder initialized without a client!")
		CRASH("lighting mask holder initialized without a client!")
	//Set position
	var/turf/T = get_turf(src)
	//Owner
	owner = C
	//Get contained atom
	containing_atom = get_containing_atom()
	change_contained_atom(null, containing_atom)
	//Initialize a post-login callback for tracking the new mobs
	owner.player_details.post_login_callbacks += CALLBACK(src, .proc/client_mob_changed)
	//Add ourselves to the light viewer list
	if(x && y && z)
		LAZYADD(SSlighting.light_source_grid[z][x][y][LIGHT_VIEWER], src)
		grid_x = x
		grid_y = y
		grid_z = z
		log_lighting("New lighting viewer ([owner]) created at [x], [y], [z]")
	else
		log_lighting("New lighting viewer ([owner]) created in nullspace.")

/atom/movable/lighting_mask_holder/Destroy(force)
	log_lighting("Lighting viewer beloning to [owner] destroyed.")
	owner = null
	containing_atom = null
	for(var/source in sources_visible)
		var/image/I = sources_visible[source]
		//Cut the vis contents of images
		I.vis_contents.Cut()
	//Cut the list of visible sources
	sources_visible.Cut()
	//Remove ourself from the light viewer list
	if(grid_x && grid_y && grid_z)
		LAZYREMOVE(SSlighting.light_source_grid[grid_z][grid_x][grid_y][LIGHT_VIEWER], src)
	. = ..()

//=========================
// Login Callbacks
//=========================

/atom/movable/lighting_mask_holder/proc/client_mob_changed()
	var/new_container = get_containing_atom()
	change_contained_atom(containing_atom, new_container)
	containing_atom = new_container
	log_lighting("Client [owner] changed mob. Updating light viewer.")

//=========================
// SIGNAL HANDLERS
//=========================

/atom/movable/lighting_mask_holder/proc/light_source_moved(datum/light_source/source, old_x, old_y, old_z)
	SIGNAL_HANDLER
	if(old_z != source.z)
		stop_rendering_source(source)
		return
	var/delta_x = (source.x - old_x) * world.icon_size
	var/delta_y = (source.y - old_y) * world.icon_size
	var/image/I = sources_visible[source]
	I.pixel_x += delta_x
	I.pixel_y += delta_y
	//If the image moved out of view, stop viewing it.
	if(!is_source_in_view(source))
		stop_rendering_source(source)

//=========================
// START/STOP RENDERING
//=========================

//Starts rendering a light source
/atom/movable/lighting_mask_holder/proc/start_rendering_source(datum/light_source/rendering_source)
	if(sources_visible[rendering_source])
		CRASH("Attempted to start rendering a light source already being rendered.")
	if(!rendering_source.our_mask)
		CRASH("Attempted to start rendering a light source with a null mask.")
	//Create the image that will hold the light source's mask
	var/image/render_image = image(loc = loc, layer = LIGHTING_IMAGE_LAYER)
	//We can't put atoms in the clients.images unfortunately.
	//However we can put the atom in the vis_contents of an image and then stick that image in client.images!
	render_image.vis_contents += rendering_source.our_mask
	//Apply a pixel offset so the light renders in the correct position
	var/delta_x = rendering_source.x - grid_x
	var/delta_y = rendering_source.y - grid_y
	//Apply the shift
	render_image.pixel_x = delta_x * world.icon_size
	render_image.pixel_y = delta_y * world.icon_size
	//Apply the image to the client's images
	owner.images += render_image
	sources_visible[rendering_source] = render_image
	//Track for light source movements
	RegisterSignal(rendering_source, COMSIG_LIGHT_SOURCE_MOVED, .proc/light_source_moved)
	log_lighting("[owner]'s light viewer began rendering light source at [rendering_source.x],[rendering_source.y],[rendering_source.z]")

//Stops rendering a light source
/atom/movable/lighting_mask_holder/proc/stop_rendering_source(datum/light_source/source)
	//Stop tracking for deleted light sources.
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	UnregisterSignal(source, COMSIG_LIGHT_SOURCE_MOVED)
	if(sources_visible[source])
		//Remove the image from the client
		var/image/I = sources_visible[source]
		I.vis_contents.Cut()
		owner.images -= I
		//Remove the source from our list
		sources_visible.Remove(source)
	log_lighting("[owner]'s light viewer stopped rendering light source at [source.x],[source.y],[source.z]")

//=========================
// Movement handling
//=========================

/atom/movable/lighting_mask_holder/Moved(atom/OldLoc, direct)
	. = ..()
	//Move light mask
	SSlighting.move_viewer(src, OldLoc)
	//Translate all lights
	update_contained_images(OldLoc.x, OldLoc.y, OldLoc.z)

//=========================
// MOVEMENT RENDERING UPDATES
//=========================

/atom/movable/lighting_mask_holder/proc/is_source_in_view(datum/light_source/source_in_view)
	//Check for nullspace and to make sure both sources are on the same z-level.
	if(!z || z != source_in_view.z)
		return FALSE
	//TODO: Replace world.view with client.view.
	var/list/view_size = getviewsize(world.view)
	//Get the view width and height and floor it to get a view radius.
	//    v Client
	//####o####   <- World
	//432101234   <- Distance from client
	var/view_width = round(view_size[1] / 2)
	var/view_height=  round(view_size[2] / 2)
	//Determine if the source is in view
	var/delta_x = abs(grid_x - source_in_view.x)
	var/delta_y = abs(grid_y - source_in_view.y)
	//Determine range limit
	var/range_limit_x = view_width + source_in_view.light_range
	var/range_limit_y = view_height + source_in_view.light_range
	//Return TRUE if delta x and delta y are smaller than the range limit
	return delta_x <= range_limit_x && delta_y <= range_limit_y

/atom/movable/lighting_mask_holder/proc/update_contained_images(old_x, old_y, old_z)
	//Completely recalculate on changed Z
	if(old_z != z)
		//Stop rendering all light sources
		for(var/datum/light_source/source as() in sources_visible)
			stop_rendering_source(source)
		//TODO: Render new light sources
		return
	var/delta_x = (old_x - grid_x) * world.icon_size
	var/delta_y = (old_y - grid_y) * world.icon_size
	for(var/datum/light_source/source as() in sources_visible)
		var/image/I = sources_visible[source]
		I.loc = loc
		I.pixel_x += delta_x
		I.pixel_y += delta_y
		//If the image moved out of view, stop viewing it.
		if(!is_source_in_view(source))
			stop_rendering_source(source)

//=========================
// MOVEMENT TRACK HANDLING
//=========================

//Locate the top level atom that we are contained within.
/atom/movable/lighting_mask_holder/proc/get_containing_atom()
	var/sanity = 20
	var/atom/parent = owner.mob
	while(sanity && parent?.loc && !isturf(parent.loc))
		parent = parent.loc
		sanity --
	return parent

/atom/movable/lighting_mask_holder/proc/loc_changed()
	if(containing_atom)
		forceMove(get_turf(containing_atom))
	else if(owner)
		forceMove(get_turf(owner.mob))
	else
		CRASH("Lighting mask holder has no client in loc_changed.")
	//No contained atom, or the contained atom was put inside something
	var/turf/our_turf = get_turf(src)
	var/turf/their_turf = containing_atom ? get_turf(containing_atom) : null
	if(their_turf != our_turf || !isturf(containing_atom.loc))
		var/atom/containing_thing = get_containing_atom()
		if(containing_thing != containing_atom)
			change_contained_atom(containing_atom, containing_thing)
			containing_atom = containing_thing

//The mob, or the thing containing our mob changed location.
//Register signal with the new top level atom.
/atom/movable/lighting_mask_holder/proc/change_contained_atom(atom/oldA, atom/newA)
	if(oldA)
		UnregisterSignal(oldA, COMSIG_MOVABLE_MOVED)
	if(newA)
		RegisterSignal(newA, COMSIG_MOVABLE_MOVED, .proc/loc_changed)
