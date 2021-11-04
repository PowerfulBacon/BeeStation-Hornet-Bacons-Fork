
//Full update for a viewer
//Resets all visible lights, makes all visible lights.
/datum/controller/subsystem/lighting/proc/update_viewer(atom/movable/lighting_mask_holder/viewer)
	//Stop rendering everything
	for(var/source in viewer.sources_visible)
		viewer.stop_rendering_source(source)
	//Add ourselves to the light viewer list
	if(viewer.grid_x && viewer.grid_y && viewer.grid_z)
		//Begin rendering lights in view
		for(var/datum/light_source/source as() in get_sources_in_viewer_range(viewer))
			viewer.start_rendering_source(source)
