/atom/movable/lighting_object
	name          = ""

	anchored      = TRUE

	icon             = LIGHTING_ICON
	icon_state       = "dark"
	plane            = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer            = LIGHTING_LAYER

	var/needs_update = FALSE
	var/turf/myturf

/atom/movable/lighting_object/Initialize(mapload)
	. = ..()
	GLOB.lighting_overlays += src

// Variety of overrides so the overlays don't get affected by weird things.

/atom/movable/lighting_object/ex_act(severity)
	return 0

/atom/movable/lighting_object/singularity_act()
	return

/atom/movable/lighting_object/singularity_pull()
	return

/atom/movable/lighting_object/blob_act()
	return

/atom/movable/lighting_object/onTransitZ()
	return

// Override here to prevent things accidentally moving around overlays.
/atom/movable/lighting_object/forceMove(atom/destination, var/no_tp=FALSE, var/harderforce = FALSE)
	if(harderforce)
		. = ..()
