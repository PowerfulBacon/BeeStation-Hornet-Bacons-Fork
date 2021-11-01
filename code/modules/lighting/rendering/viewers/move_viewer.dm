/*
 * Wrapper for moving a light viewer
 */

/*
 * Handles the moving of a light viewer

 * Viewer - The lighting mask holder that moved
 * OldLoc - The old location of the lighting mask
 */
/datum/controller/subsystem/lighting/proc/move_viewer(atom/movable/lighting_mask_holder/viewer, atom/oldLoc)
	//Remove from previous position
	if(viewer.grid_z)
		LAZYREMOVE(SSlighting.light_source_grid[viewer.grid_z][viewer.grid_x][viewer.grid_y][LIGHT_VIEWER], viewer)
	//Add to new position
	if(viewer.z)
		LAZYADD(SSlighting.light_source_grid[viewer.z][viewer.x][viewer.y][LIGHT_VIEWER], viewer)
		//Determine new sources that are now in view
		//TODO: Optimise by only searching new tiles and not all tiles
		for(var/datum/light_source/source as() in get_sources_in_viewer_range(viewer))
			if(!viewer.sources_visible[source])
				viewer.start_rendering_source(source)
		//Set our positions after rendering sources
		//so things are in the right place
		viewer.grid_x = viewer.x
		viewer.grid_y = viewer.y
		viewer.grid_z = viewer.z
