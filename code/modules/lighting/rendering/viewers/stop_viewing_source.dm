
/datum/controller/subsystem/lighting/proc/stop_viewing_source(atom/movable/lighting_mask_holder/viewer, datum/light_source)
	viewer.stop_rendering_source(light_source)
