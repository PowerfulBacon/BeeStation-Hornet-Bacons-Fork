/datum/wave_function_profile
	var/profile_block_text = ""
	//Not doing this optimisation for now due to memory concerns
	//var/list/function_profile_sets
	//Optimisation for quicker possible lookup speeds
	var/list/function_profile_cache = list()

/datum/wave_function_profile/proc/load(profile_block_text)
	src.profile_block_text = profile_block_text
	/*
	//Determine the length of the blocks
	var/block_length = length(profile_blocks[1])
	function_profile_sets = new(block_length)
	for (var/i in 1 to block_length)
		function_profile_sets[i] = new(WAVE_FUNCTION_END - WAVE_FUNCTION_START + 1)
		for (var/j in 1 to (WAVE_FUNCTION_END - WAVE_FUNCTION_START + 1))
			function_profile_sets[i][j] = list()
	//Create the things (This will probably be quite expensive)
	//100000 blocks at 5x5 is 2.5 million elements we are storing
	//Thats like 2.5 MB which is quite a lot actually
	for (var/block_text in profile_blocks)
	*/

///Restriction in the format
///3x3 grid:
///010
///???
///000
///Represented as
///010???000
/datum/wave_function_profile/proc/get_all_possible(restriction_string)
	//This lookup is stored in the cache
	if (function_profile_cache[restriction_string])
		return function_profile_cache[restriction_string]
	. = list()
	//Perform the lookup
	var/regex/stupid_regex = new("^[replacetext(restriction_string, "?", @"\w")]$", "gm")
	while (stupid_regex.Find(profile_block_text, stupid_regex.next))
		. += stupid_regex.match
	//
	function_profile_cache[restriction_string] = .
