/**
 * Wave function collapse algorithm implemented in byond.
 * The input profile is based on the maps in _maps/map_files
 * @PowerfulBacon
 */

/datum/wave_function_collapse
	var/list/possible_starts = list(
		"?222??222??222??222??222?",
		"?????222222222222222?????",
	)

///Triggers the algorithm to run generating based on the width and height
///null_tile: The tile that should be used for the region outside the width and height. For the ruin generator
///this will be set to 0 (space tiles), which will force areas on the border to be space only.
///Width and height are self-explanatory
/datum/wave_function_collapse/proc/generate(width, height, null_tile = WAVE_FUNCTION_COLLAPSE_SPACE)
	//Setup the grid and the entropy
	var/list/generation_grid = new(width, height)
	var/list/entropy_grid = new(width, height)
	var/center_offset = CEILING(SSwave_function_collapse.input_size / 2, 1)
	var/left_extension = 1 - center_offset
	var/right_extension = SSwave_function_collapse.input_size - center_offset
	//Create the starting point for our ruin
	var/list/starting_thing = new(width, height)
	for (var/x in 1 to width)
		for (var/y in 1 to height)
			starting_thing[x][y] = "?"
	//Pick a ruin generation starting point
	var/picked_start = pick(possible_starts)
	for (var/i in 1 to SSwave_function_collapse.input_size)
		for (var/j in 1 to SSwave_function_collapse.input_size)
			var/x = (FLOOR(width / 2, 1) + i - left_extension)
			var/y = (FLOOR(height / 2, 1) + j - left_extension)
			var/index = (5 * (j - 1)) + i
			starting_thing[x][y] = copytext(picked_start, index, index + 1)
	//Setup the initial entropy grid
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
						possibility_string += starting_thing[_x][_y]
			//Get our input string
			entropy_grid[x][y] = SSwave_function_collapse.wf_profile.get_all_possible(possibility_string)
			generation_grid[x][y] = length(entropy_grid[x][y])
	//Build the spatial heap
	var/datum/entropy_map_node/entropy_map_root = build_entropy_map(generation_grid)
	//To indicate that we won't be using this anymore
	generation_grid = null

