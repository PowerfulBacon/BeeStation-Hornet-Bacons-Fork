
/datum/controller/subsystem/lighting/proc/create_viewer(atom/movable/lighting_mask_holder/viewer)
	//Add ourselves to the light viewer list
	if(viewer.x && viewer.y && viewer.z)
		LAZYADD(SSlighting.light_source_grid[viewer.z][viewer.x][viewer.y][LIGHT_VIEWER], src)
		//Position set
		viewer.grid_x = viewer.x
		viewer.grid_y = viewer.y
		viewer.grid_z = viewer.z
		//Begin rendering lights in view
		update_viewer(viewer)
		//Log
		log_lighting("New lighting viewer ([viewer.owner]) created at [viewer.x], [viewer.y], [viewer.z]")
	else
		log_lighting("New lighting viewer ([viewer.owner]) created in nullspace.")
