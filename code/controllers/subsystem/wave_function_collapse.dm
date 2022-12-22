//#define WAVE_FUNCTION_DEBUG

#define WAVE_FUNCTION_COLLAPSE_DATA_PATH "data/wave_function_profile/"

#define WAVE_FUNCTION_INPUT_SIZE_DEFAULT 5

#define WAVE_FUNCTION_COLLAPSE_SPACE 0
#define WAVE_FUNCTION_COLLAPSE_WALL 1
#define WAVE_FUNCTION_COLLAPSE_FLOOR 2
#define WAVE_FUNCTION_COLLAPSE_WINDOW 3
#define WAVE_FUNCTION_COLLAPSE_DOOR 4

#define WAVE_FUNCTION_START 0
#define WAVE_FUNCTION_END 4

/**
 * Wave function collapse profile generator for ruin generation.
 * This allows for efficient storage and querying of WFC blocks.
 *
 * For example:
 * If we have
 * 0 X
 * 0 X
 * Then we need all blocks that follow the profile 0?0?
 * To obtain this we find 0??? and ??0? and then calculate the intersection
 * of these lists. (We can do this efficiently since they are sorted)
 * @PowerfulBacon
 */

SUBSYSTEM_DEF(wave_function_collapse)
	name = "Wave function collapse parser"
	flags = SS_NO_FIRE
	//The n value of the wave function collapser.
	//Change this and re-call initialize with force=1 to experiment
	var/input_size = WAVE_FUNCTION_INPUT_SIZE_DEFAULT
	// The profile
	var/datum/wave_function_profile/wf_profile = new()
	// The generator
	var/datum/wave_function_collapse/wf_generator = new()

///This function only runs when a map updates, do can kind of afford to be slow
/datum/controller/subsystem/wave_function_collapse/Initialize(start_timeofday, force = FALSE)
	. = ..()
	//Locate file hashes
	//Calculate hash
	var/calculated_hash = ""
	//Check files
	for (var/folder_path in flist("_maps/map_files/"))
		//Skip these non-maps
		if (folder_path == "debug/" || folder_path == "generic/" || folder_path == "Mining/")
			continue
		for (var/file_path in flist("_maps/map_files/[folder_path]"))
			//Not a DMM file
			if (!findtext(file_path, ".dmm"))
				continue
			calculated_hash += md5(file("_maps/map_files/[folder_path][file_path]"))
	//Check hash (If we are debugging the wave function generator, then just regenerate ALWAYS!)
#ifndef WAVE_FUNCTION_DEBUG
	if (!force && fexists("[WAVE_FUNCTION_COLLAPSE_DATA_PATH]wfp_hashes.txt"))
		var/hash_text = replacetext(file2text("[WAVE_FUNCTION_COLLAPSE_DATA_PATH]wfp_hashes.txt"), "\n", "")
		if (hash_text == calculated_hash)
			wf_profile.load(file2text("[WAVE_FUNCTION_COLLAPSE_DATA_PATH]wfp_blocks.txt"))
			return
		//If the file exists, just use the outdated maps when the debugger is enabled
		if (Debugger?.enabled)
			wf_profile.load(file2text("[WAVE_FUNCTION_COLLAPSE_DATA_PATH]wfp_blocks.txt"))
			to_chat(world, "<span class='boldannounce'>Ruin generator profile is outdated but has not been updated due to the debugger being enabled. Enable WAVE_FUNCTION_DEBUG or delete [WAVE_FUNCTION_COLLAPSE_DATA_PATH]wfp_hashes.txt in order to force regeneration.</span>")
			return
#endif
	//Trigger update
	to_chat(world, "<span class='boldannounce'>Generating ruin generation profile (This may take a little while)...</span>")
	var/start_time = TICK_USAGE_REAL
	//Wipe the entire directory
	fdel(WAVE_FUNCTION_COLLAPSE_DATA_PATH)
	//Create the generations
	var/map_count = 0
	var/list/all_blocks = list()
	for (var/folder_path in flist("_maps/map_files/"))
		//Skip these non-maps
		if (folder_path == "debug/" || folder_path == "generic/" || folder_path == "Mining/")
			continue
		for (var/file_path in flist("_maps/map_files/[folder_path]"))
			//Not a DMM file
			if (!findtext(file_path, ".dmm"))
				continue
			map_count ++
			var/datum/parsed_map/pm = new(file("_maps/map_files/[folder_path][file_path]"))
			pm.build_cache(TRUE)
			//List of y lines
			var/list/wfc_lines = list()
			//Get the grid set
			for(var/I in pm.gridSets)
				var/datum/grid_set/gset = I
				var/list/current_line = list()
				//Get each point in it
				for(var/line in gset.gridLines)
					for(var/tpos = 1 to length(line) - pm.key_len + 1 step pm.key_len)
						var/model_key = copytext(line, tpos, tpos + pm.key_len)
						var/list/cache = pm.modelCache[model_key]
						//Locate what type it is
						if (!cache)
							current_line += WAVE_FUNCTION_COLLAPSE_SPACE
							continue
						//Check the turf
						var/turf_path = cache[1][length(cache[1]) - 1]
						//Wall turf
						if (ispath(turf_path, /turf/closed))
							current_line += WAVE_FUNCTION_COLLAPSE_WALL
							continue
						//Space turf
						if (ispath(turf_path, /turf/template_noop) || ispath(turf_path, /turf/open/space))
							current_line += WAVE_FUNCTION_COLLAPSE_SPACE
							continue
						//Check things on it
						var/found = FALSE
						for (var/obj_path in cache[1])
							if (ispath(obj_path, /obj/machinery/door))
								current_line += WAVE_FUNCTION_COLLAPSE_DOOR
								found = TRUE
								break
							if (ispath(obj_path, /obj/structure/window))
								current_line += WAVE_FUNCTION_COLLAPSE_WINDOW
								found = TRUE
								break
						if (found)
							continue
						//Floor turf
						current_line += WAVE_FUNCTION_COLLAPSE_FLOOR
				wfc_lines += list(current_line)
			//Add the WFC profile
			all_blocks |= generate_file_profiles(wfc_lines)
			//Clean up the map
			qdel(pm)
			to_chat(world, "<span class='boldannounce'>Generated ruin profile for [file_path].</span>")
	//Sort the blocks (they need to be sorted)
	block_sort(all_blocks)
	//Record the new hash
	var/joined_blocks = all_blocks.Join("\n")
	text2file(joined_blocks, "[WAVE_FUNCTION_COLLAPSE_DATA_PATH]wfp_blocks.txt")
	wf_profile.load(joined_blocks)
	text2file(calculated_hash, "[WAVE_FUNCTION_COLLAPSE_DATA_PATH]wfp_hashes.txt")
	var/elapsed = TICK_DELTA_TO_MS(TICK_USAGE_REAL - start_time)
	to_chat(world, "<span class='boldannounce'>Ruin generation profile successfully updated in [elapsed]ms... ([map_count] maps added to generation profile)</span>")

/// Perform counting sort on the blocks
/datum/controller/subsystem/wave_function_collapse/proc/block_sort(list/blocks)
	for (var/i in length(blocks[1]) to 1 step -1)
		block_sort_index(blocks, i)

/datum/controller/subsystem/wave_function_collapse/proc/block_sort_index(list/blocks, index)
	var/list/count = new(WAVE_FUNCTION_END - WAVE_FUNCTION_START + 1)
	for (var/i in 1 to length(count))
		count[i] = list()
	//Count
	for (var/element in blocks)
		var/character = text2num(copytext(element, index, index + 1))
		count[character + 1 - WAVE_FUNCTION_START] += element
	//Blocks
	var/i = 1
	for (var/list/list_thing in count)
		for (var/thing in list_thing)
			blocks[i] = thing
			//Next pls
			i ++

/datum/controller/subsystem/wave_function_collapse/proc/generate_file_profiles(list/wfc_lines)
	var/list/profile_blocks = list()
	for (var/y in 1 to length(wfc_lines) - input_size)
		for (var/x in 1 to length(wfc_lines[y]) - input_size)
			var/block = ""
			for (var/i in 1 to input_size)
				for (var/j in 1 to input_size)
					block += "[wfc_lines[y + j - 1][x + i - 1]]"
			profile_blocks |= block
	return profile_blocks
