
#define GET_CLAMPED_DELTA(start, offset, limit) CLAMP(start - offset, 1, limit) to CLAMP(start + offset, 1, limit)

//Returns all the sources in range of a viewer
/datum/controller/subsystem/lighting/proc/get_sources_in_viewer_range(atom/movable/lighting_mask_holder/viewer)
	. = list()
	if(viewer.grid_z)
		for(var/x in GET_CLAMPED_DELTA(viewer.grid_x, viewer.viewer_width, world.maxx))
			for(var/y in GET_CLAMPED_DELTA(viewer.grid_y, viewer.viewer_height, world.maxy))
				//TODO Somehow optimise this
				. |= SSlighting.light_source_grid[viewer.grid_z][x][y][LIGHT_EXPOSED]

#undef GET_CLAMPED_DELTA
