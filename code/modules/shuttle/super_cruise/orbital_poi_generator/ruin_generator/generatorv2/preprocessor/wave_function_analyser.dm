/datum/wave_function_analyser
	//Height of a tile
	var/tile_height
	//Width of a tile
	var/tile_width

/datum/wave_function_analyser/proc/load_tilemap(sample_file)
	var/full_file = file2text(sample_file)
	var/list/split_lines = splittext(full_file, "\n")
	var/width = length(split_lines[1]) / 2
	var/height = length(split_lines)
	//Create a new tilemap
	for (var/x in 1 to (width - tile_width + 1))
		for (var/y in 1 to (height - tile_height + 1))

