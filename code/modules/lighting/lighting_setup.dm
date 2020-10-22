/proc/create_all_lighting_objects()
	for(var/area/A in world)
		if(!IS_DYNAMIC_LIGHTING(A))
			continue

		for(var/turf/T in A)
			if(T.x % 8 == 0 && T.y % 8 == 0)
				new/atom/movable/lighting_object(T)
			CHECK_TICK
		CHECK_TICK
