#define LIGHTING_MASK_RADIUS 4
#define LIGHTING_MASK_SPRITE_SIZE LIGHTING_MASK_RADIUS * 64

/atom/movable/lighting_mask_alpha
	name = "lighting mask alpha"

	anchored = TRUE

	icon             = LIGHTING_ICON_BIG
	icon_state       = "light_big"
	plane            = LIGHTING_PLANE
	//DEBUG: mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer            = LIGHTING_LAYER
	invisibility     = INVISIBILITY_LIGHTING
	blend_mode		 = BLEND_ADD

	bound_x = -128
	bound_y = -128
	bound_height = 256
	bound_width = 256

/atom/movable/lighting_mask_alpha/proc/set_radius(radius, transform_time = 0)
	apply_matrix(get_matrix(radius), transform_time)

/atom/movable/lighting_mask_alpha/proc/apply_matrix(matrix/M, transform_time = 0)
	if(transform_time)
		animate(src, transform = M, time = transform_time)
	else
		transform = M

/atom/movable/lighting_mask_alpha/proc/get_matrix(radius = 1)
	var/proportion = radius / LIGHTING_MASK_RADIUS
	var/matrix/M = new()
	//Scale
	// - Scale to the appropriate radius
	M.Scale(proportion)
	//Rotate
	// - Rotate (Directional lights TODO)
	//Translate
	// - Ok so apparently translate is affected by the scale we already did huh.
	M.Translate(-128)
	return M

#undef LIGHTING_MASK_SPRITE_SIZE
