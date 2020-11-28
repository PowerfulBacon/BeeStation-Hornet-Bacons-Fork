/*
 *
 */

 /*
 * Improved lighting system by powerfulbacon
 * Each light source contains an object as a mask, which will remove darkness from the lighting plane.
 * These will now update in real time when moved, can have effects like animate applied to them etc.
 *
 * Things needed:
 *  - Shadows
 *  - Color (Done)
 *  - Power / Strength
 *  - Range
 *
 */
/atom/movable/lighting_mask
	name = ""

	icon = LIGHTING_BIG
	icon_state = "light_no_trans"
	plane = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_LIGHTING_LAYER
	blend_mode = BLEND_ADD

	//Bounds > Needs to be updated with size
	appearance_flags = 0
	bound_width = 256
	bound_height = 256
	bound_x = -128
	bound_y = -128

	//The pixel offset when we are facing north
	var/north_pixel_x
	var/north_pixel_y

	var/angle = 0

	var/range = 4
	var/power = 1

// =======================================
// INITIALIZATION
// =======================================

/atom/movable/lighting_mask/Initialize(mapload, light_size = 8)
	. = ..()
	update_matrix()
	update_bounds()
	calculate_shadows()

// =======================================
// LIGHT VALUE SETTERS
// =======================================

/*
 * Sets the colour of the light
 */
/atom/movable/lighting_mask/proc/set_color(new_color)
	color = new_color

/*
 * Sets the range of the light.
 * Transforms the object to resize it to the range it should be.
 * NOTE: RANGE IS IN RADIUS
 */
/atom/movable/lighting_mask/proc/set_range(new_range)
	range = new_range
	update_matrix()
	update_bounds()
	calculate_shadows()

/*
 * Sets the power of the light.
 */
/atom/movable/lighting_mask/proc/set_power(new_power)
	power = new_power

// =======================================
// BOUNDARIES CALCULATIONS
// =======================================

/atom/movable/lighting_mask/proc/update_bounds()
	var/bound_radius = (FLOOR(range, 1) + 1) * world.icon_size
	bound_width = bound_radius * 2
	bound_height = bound_radius * 2
	bound_x = -bound_radius
	bound_y = -bound_radius

// =======================================
// MATRIX CALCULATIONS
// =======================================

/*
 * Updates the transformation matrix of this light object.
 *
 * Todo:
 *  - Use animate to allow for smooth updating.
 */
/atom/movable/lighting_mask/proc/update_matrix()
	//Where the fun starts
	var/matrix/object_matrix = matrix()
	// SCALE
	//  - Scale so we are the right size
	//Icon radius is 4 tiles (8x8), so we must scale our range accordingly to that
	// E.G: Range of 4, size scale should be 1
	var/size_proportion = range / 4
	object_matrix *= size_proportion
	// TRANSLATION
	//  - Translate so that the light is where it should be relative to the source.
	//  - Original sprite is 256 x 256, so sprites needs to be moved by -128 * size_proportion on x and y directions
	object_matrix.Translate(-128 * size_proportion, -128 * size_proportion)
	// ROTATION
	//  - Rotate so we are in the right direction.
	//  - Wait shouldn't this be before translation?
	object_matrix.Turn(angle)
	//Set the transform
	transform = object_matrix

/*
 * Override so that when the direction of the light is set we set our angle
 */
/atom/movable/lighting_mask/setDir(newdir)
	var/angle = dir2angle(newdir)
	setAngle(angle)

/atom/movable/lighting_mask/proc/setAngle(newAngle)
	angle = newAngle

// =======================================
// SHADOW CALCULATIONS
// =======================================

/atom/movable/lighting_mask/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	calculate_shadows()

/*
 * Calculates the shadows for the object, and masks the image where it should have shadows
 */
/atom/movable/lighting_mask/proc/calculate_shadows()
	return
	/*var/icon/I = new(LIGHTING_BIG, "light_no_trans")
	var/range_floor = FLOOR(range, 1)
	var/range_integer = range_floor + (range_floor < range)
	var/minx = x - range_integer
	var/maxx = x + range_integer
	var/miny = y - range_integer
	var/maxy = y + range_integer
	var/list/affected_turfs = block(locate(minx, miny, z), locate(maxx, maxy, z))
	var/list/cannot_see = affected_turfs - view(get_turf(src), range)
	//The size of 1 turf on the image in pixels
	var/one_turf_pixel_size = 256/(range_integer * 2 + 1)
	if(world.time > 1000)
		message_admins("Data: [range_integer] ([range]), x:[minx], [maxx], y:[miny], [maxy]")
	for(var/turf/T as anything in cannot_see)
		var/relative_x = (T.x - minx) * one_turf_pixel_size
		var/relative_y = (T.y - miny) * one_turf_pixel_size
		I.DrawBox(rgb(0, 0, 0), relative_x, relative_y, relative_x + one_turf_pixel_size, relative_y + one_turf_pixel_size)
	icon = I*/

/*
 * Adds a lighting mask with this atom as its source
 * TODO:
 *  - add_overlay
 */
/atom/proc/add_lighting_mask()
	var/atom/movable/lighting_mask/mask = new(get_turf(src))
	var/atom/movable/this = src
	if(!istype(this))
		return
	this.vis_contents += mask
	return mask
