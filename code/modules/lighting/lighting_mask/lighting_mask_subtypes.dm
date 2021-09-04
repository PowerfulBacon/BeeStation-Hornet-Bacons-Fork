//Simple lighting
/atom/movable/lighting_mask/quick_light
	glide_size = 2
	appearance_flags = KEEP_TOGETHER | TILE_BOUND

//The holder atom turned
/atom/movable/lighting_mask/proc/holder_turned(new_direction)
	return

///TGMC Optimisation
///This is the template mask used for overlay merging, DO NOT TOUCH THIS FOR NO REASON
/atom/movable/lighting_mask/template
	icon_state = null
	blend_mode = BLEND_DEFAULT
//TGMC Optimisation End

//Flicker

/atom/movable/lighting_mask/flicker
	icon_state = "light_flicker"

//Conical Light

/atom/movable/lighting_mask/conical
	icon_state = "light_conical"

/atom/movable/lighting_mask/conical/holder_turned(new_direction)
	var/wanted_angle = dir2angle(new_direction) - 180
	rotate(wanted_angle)

//Rotating Light

/atom/movable/lighting_mask/rotating
	icon_state = "light_rotating-1"

/atom/movable/lighting_mask/rotating/Initialize(mapload, ...)
	. = ..()
	icon_state = "light_rotating-[rand(1, 3)]"

//Client light
//It just works
/atom/movable/lighting_mask/personal_light
	var/mob/owner

//TODO:
//Makes this only show to the owner when assigned in the lighting mask holder.
/atom/movable/lighting_mask/personal_light/proc/give_owner(mob/_owner)

