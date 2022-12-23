/**
 * Wave function collapse algorithm implemented in byond.
 * The input profile is based on the maps in _maps/map_files
 * @PowerfulBacon
 */

/datum/wave_function_collapse
	var/list/possible_starts = list(
		"2222222222222222222222222",
	)

///Triggers the algorithm to run generating based on the width and height
///null_tile: The tile that should be used for the region outside the width and height. For the ruin generator
///this will be set to 0 (space tiles), which will force areas on the border to be space only.
///Width and height are self-explanatory
///This beautiful algorithm is O(n^2 * m^4 * k)
///Increasing the width and height will increase the time proportionally
///Increasing the input size will increase it proportional to the 4 power (5 to 6 has a time complexity difference of 671x)
///Increasing the number of blocks in the generator profile will increase it proportionally
/datum/wave_function_collapse/proc/generate(width, height, null_tile = WAVE_FUNCTION_COLLAPSE_SPACE)
	//Setup the grid and the entropy
	var/list/generation_grid = new(width, height)
	var/list/entropy_grid = new(width, height)
	var/center_offset = CEILING(SSwave_function_collapse.input_size / 2, 1)
	var/left_extension = 1 - center_offset
	var/right_extension = SSwave_function_collapse.input_size - center_offset
	var/text_index_center = (SSwave_function_collapse.input_size * (center_offset - 1)) + center_offset
	//Create the starting point for our ruin
	var/list/output = new(width, height)
	for (var/x in 1 to width)
		for (var/y in 1 to height)
			output[x][y] = "?"
	//Pick a ruin generation starting point
	var/picked_start = pick(possible_starts)
	//O(m^2) where m is the input size
	for (var/i in 1 to SSwave_function_collapse.input_size)
		for (var/j in 1 to SSwave_function_collapse.input_size)
			var/x = (FLOOR(width / 2, 1) + i - left_extension)
			var/y = (FLOOR(height / 2, 1) + j - left_extension)
			var/index = (SSwave_function_collapse.input_size * (j - 1)) + i
			output[x][y] = copytext(picked_start, index, index + 1)
	//Setup the initial entropy grid
	//O(n^2 * m^2) where n is the size of the generation and m is the input size
	for (var/x in 1 to width)
		for (var/y in 1 to height)
			var/possibility_string = ""
			for (var/j in left_extension to right_extension)
				for (var/i in left_extension to right_extension)
					var/_x = x + i
					var/_y = y + j
					if (_x <= 0 || _y <= 0 || _x > width || _y > height)
						//Outside of bounds = space
						possibility_string += "[null_tile]"
					else
						possibility_string += output[_x][_y]
			//Get our input string
			//TODO: Implement optimisation, we dont need the whole string so if we input something where our tile is already resolved, then
			//we don't need to search
			entropy_grid[x][y] = SSwave_function_collapse.wf_profile.get_all_possible(possibility_string)
			generation_grid[x][y] = length(entropy_grid[x][y])
	//Build the spatial heap
	var/datum/entropy_map_node/entropy_map_root = build_entropy_map(generation_grid)
	//To indicate that we won't be using this anymore
	generation_grid = null
	var/datum/entropy_map_node/bottom
	//O(n^2)
	while ((bottom = entropy_map_root.take()) != null)
		to_chat(world, "[bottom.x],[bottom.y] => [bottom.value]")

		//Since we want to generate random levels, resolve this tile into a random one
		//TODO: Implement backtracking here
		var/list/resolve_options = entropy_grid[bottom.x][bottom.y]
		if (!length(resolve_options))
			//TODO: Backtrack
			var/turf/located = locate(40 + bottom.x, 40 + bottom.y, 3)
			located.ChangeTurf(/turf/open/floor/plasteel/vaporwave)
			usr.forceMove(located)
			continue
		//Pick the thing
		var/picked_string = pick(resolve_options)
		if (output[bottom.x][bottom.y] != "?")
			continue
		output[bottom.x][bottom.y] = copytext(picked_string, text_index_center, text_index_center + 1)

		var/turf/located = locate(40 + bottom.x, 40 + bottom.y, 3)
		if (output[bottom.x][bottom.y] != "?")
			switch (text2num(output[bottom.x][bottom.y]))
				if (WAVE_FUNCTION_COLLAPSE_SPACE)
					located.ChangeTurf(/turf/open/space)
				if (WAVE_FUNCTION_COLLAPSE_WALL)
					located.ChangeTurf(/turf/closed/wall)
				if (WAVE_FUNCTION_COLLAPSE_PLATING)
					located.ChangeTurf(/turf/open/floor/plating)
				if (WAVE_FUNCTION_COLLAPSE_FLOOR)
					located.ChangeTurf(/turf/open/floor/plasteel)
				if (WAVE_FUNCTION_COLLAPSE_WINDOW)
					located.ChangeTurf(/turf/open/floor/plating)
					new /obj/effect/spawner/structure/window(located)
				if (WAVE_FUNCTION_COLLAPSE_DOOR)
					located.ChangeTurf(/turf/open/floor/plasteel)
					new /obj/machinery/door/airlock(located)
				if (WAVE_FUNCTION_COLLAPSE_EXTERNAL_AIRLOCK)
					located.ChangeTurf(/turf/open/floor/plasteel)
					new /obj/machinery/door/airlock/external(located)
				if (WAVE_FUNCTION_COLLAPSE_WINDOW_HALLWAY)
					located.ChangeTurf(/turf/open/floor/engine)
		else
			located.ChangeTurf(/turf/open/floor/plasteel/vaporwave)
		usr.forceMove(located)


		//Now we have resolved this tile, update tiles around it
		//TODO: Optimise this
		//TODO: Please, please OPTIMISE THIS AND DONT IGNORE THIS COMMENT!!!
		//O(m^4 * k) where m is the input size and k is the number of blocks in the profile

		//This can be optimised to a filter rather than a rebuild
		for (var/x in left_extension to right_extension)
			for (var/y in left_extension to right_extension)
				var/_x2 = bottom.x + x
				var/_y2 = bottom.y + y
				if (_x2 <= 0 || _y2 <= 0 || _x2 > width || _y2 > height)
					continue
				if (output[_x2][_y2] != "?")
					continue
				var/possibility_string = ""
				for (var/j in left_extension to right_extension)
					for (var/i in left_extension to right_extension)
						var/_x = _x2 + i
						var/_y = _y2 + j
						if (_x <= 0 || _y <= 0 || _x > width || _y > height)
							//Outside of bounds = space
							possibility_string += "[null_tile]"
						else
							possibility_string += output[_x][_y]
				//Get our input string
				//Update the entropy
				//O(k) where K is the number of blocks in the profile
				entropy_grid[_x2][_y2] = SSwave_function_collapse.wf_profile.get_all_possible(possibility_string)
				entropy_map_root.update(_x2, _y2, length(entropy_grid[_x2][_y2]))

		CHECK_TICK
