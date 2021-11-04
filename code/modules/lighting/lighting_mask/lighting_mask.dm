#define LIGHTING_MASK_RADIUS 4
#define LIGHTING_MASK_SPRITE_SIZE LIGHTING_MASK_RADIUS * 64
#define ROTATION_PARTS_PER_DECISECOND 1

/atom/movable/lighting_mask
	name = ""

	icon             = LIGHTING_ICON_BIG
	icon_state       = "light_big"

	anchored = TRUE
	plane            = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer            = LIGHTING_SECONDARY_LAYER
	invisibility     = INVISIBILITY_LIGHTING
	blend_mode		 = BLEND_ADD

	appearance_flags = KEEP_TOGETHER | TILE_BOUND

	move_resist = INFINITY

	infra_luminosity = 14

	//The radius of the mask
	var/radius = 0

	//The atom that we are attached to
	var/atom/attached_atom = null

	//Tracker var for tracking init dupe requests
	var/awaiting_update = FALSE

	var/currentAngle = 0
	var/desiredAngle = 0

/atom/movable/lighting_mask/Initialize(mapload)
	. = ..()
	//Blur what is left
	filters += GAUSSIAN_BLUR(2)

/atom/movable/lighting_mask/Destroy()
	//Remove reference to the atom we are attached to
	attached_atom = null
	//Remove from subsystem
	LAZYREMOVE(SSlighting.queued_shadow_updates, src)
	//Continue with deletiib
	. = ..()

/atom/movable/lighting_mask/proc/set_colour(colour = "#ffffff")
	color = colour

/atom/movable/lighting_mask/proc/set_intensity(intensity = 1)
	if(intensity >= 0)
		alpha = ALPHA_TO_INTENSITY(intensity)
		blend_mode = BLEND_ADD
	else
		alpha = ALPHA_TO_INTENSITY(-intensity)
		blend_mode = BLEND_SUBTRACT

/atom/movable/lighting_mask/proc/should_render_to(client/target)
	return TRUE

/atom/movable/lighting_mask/proc/set_radius(radius, transform_time = 0)
	//Update our matrix
	var/matrix/M = get_matrix(radius)
	apply_matrix(M, transform_time)
	//Set the radius variable
	src.radius = radius
	//Calculate shadows
	calculate_lighting_shadows()

//Rotates the light source to angle degrees.
//TODO:
//This probably causes a shit ton of lag.
/atom/movable/lighting_mask/proc/rotate(angle = 0)
	desiredAngle = angle
	//Converting our transform is pretty simple.
	var/matrix/M = matrix()
	M.Turn(desiredAngle - currentAngle)
	M *= transform
	//Overlays are in nullspace while applied, meaning their transform cannot be changed.
	//Disconnect the shadows from the overlay, apply the transform and then reapply them as an overlay.
	//Oh also since the matrix is really weird standard rotation matrices wont work here.
	overlays.Cut()
	//Disconnect from parent matrix, become a global position
	for(var/mutable_appearance/shadow as() in shadows)	//Mutable appearances are children of icon
		shadow.transform *= transform
		shadow.transform /= M
	//Apply our matrix
	transform = M
	//Readd the shadow overlays.
	overlays += shadows
	//Now we are facing this direction
	currentAngle = angle

/atom/movable/lighting_mask/proc/apply_matrix(matrix/M, transform_time = 0)
	if(transform_time)
		animate(src, transform = M, time = transform_time)
	else
		transform = M

/atom/movable/lighting_mask/proc/get_matrix(radius = 1)
	var/proportion = radius / LIGHTING_MASK_RADIUS
	var/matrix/M = new()
	//Scale
	// - Scale to the appropriate radius
	M.Scale(proportion)
	//Translate
	// - Center the overlay image
	// - Ok so apparently translate is affected by the scale we already did huh.
	// ^ Future me here, its because it works as translate then scale since its backwards.
	// ^ ^ Future future me here, it totally shouldnt since the translation component of a matrix is independant to the scale component.
	M.Translate(-128 + 16)
	//Adjust for pixel offsets
	var/invert_offsets = attached_atom.dir & (NORTH | EAST)
	var/left_or_right = attached_atom.dir & (EAST | WEST)
	var/offset_x = (left_or_right ? attached_atom.light_pixel_y : attached_atom.light_pixel_x) * (invert_offsets ? -1 : 1)
	var/offset_y = (left_or_right ? attached_atom.light_pixel_x : attached_atom.light_pixel_y) * (invert_offsets ? -1 : 1)
	M.Translate(offset_x, offset_y)
	//Rotate
	// - Rotate (Directional lights)
	M.Turn(currentAngle)
	return M

/atom/movable/lighting_mask/ex_act(severity, target)
	return

/atom/movable/lighting_mask/singularity_pull(obj/singularity/S, current_size)
	return

/atom/movable/lighting_mask/singularity_act()
	return

/atom/movable/lighting_mask/fire_act(exposed_temperature, exposed_volume)
	return

/atom/movable/lighting_mask/acid_act(acidpwr, acid_volume)
	return

/atom/movable/lighting_mask/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta, throw_target)
	return

#undef LIGHTING_MASK_SPRITE_SIZE
#undef ROTATION_PARTS_PER_DECISECOND
