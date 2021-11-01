
#define GET_CLAMPED_DELTA(start, offset, limit) CLAMP(start - offset, 1, limit) to CLAMP(start + offset, 1, limit)

/datum/controller/subsystem/lighting/proc/create_source(datum/light_source/source)
	//Lighting is not initialized yet
	if(!SSlighting.initialized)
		_defer_source_creation(source)
		return
	//Add the light source to the light sources list
	SSlighting.light_sources += source
	//Add the source to the lighting grid
	if(source.z && source.x && source.y)
		LAZYADD(SSlighting.light_source_grid[source.z][source.x][source.y][LIGHT_SOURCE], source)
		//Set up the exposed point grid
		_intial_source_setup(source)

/datum/controller/subsystem/lighting/proc/_intial_source_setup(datum/light_source/source)
	for(var/x in GET_CLAMPED_DELTA(source.x, source.light_range, world.maxx))
		for(var/y in GET_CLAMPED_DELTA(source.y, source.light_range, world.maxy))
			//Horray, this area is now exposed to light
			LAZYADD(SSlighting.light_source_grid[source.z][x][y][LIGHT_EXPOSED], source)
			//var/turf/T = locate(x, y, source.z);T.color=source.light_color
			//Any viewers on the tile exposed to light now needs to see this light
			for(var/viewer in SSlighting.light_source_grid[source.z][x][y][LIGHT_VIEWER])
				start_viewing_source(viewer, source)

/datum/controller/subsystem/lighting/proc/_defer_source_creation(datum/light_source/source)
	deferred_events[LIGHT_DEFER_CREATION] += source

#undef GET_CLAMPED_DELTA
