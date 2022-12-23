/datum/wave_function_profile
	var/profile_block_text = ""
	//Not doing this optimisation for now due to memory concerns
	var/list/function_profile_sets
	//Optimisation for quicker possible lookup speeds
	var/list/function_profile_cache = list()

/datum/wave_function_profile/proc/load(profile_block_text)
	src.profile_block_text = profile_block_text
	//Determine the length of the blocks
	var/block_length = SSwave_function_collapse.input_size * SSwave_function_collapse.input_size
	function_profile_sets = new(block_length)
	for (var/i in 1 to block_length)
		function_profile_sets[i] = new /list(WAVE_FUNCTION_END - WAVE_FUNCTION_START + 1)
		for (var/j in 1 to (WAVE_FUNCTION_END - WAVE_FUNCTION_START + 1))
			function_profile_sets[i][j] = list()
	//Create the things (This will probably be quite expensive)
	//100000 blocks at 5x5 is 2.5 million elements we are storing
	//Thats like 2.5 MB which is quite a lot actually
	//Split on the new line
	for (var/block_text in splittext(profile_block_text, "\n"))
		for (var/i in 1 to block_length)
			var/character = text2num(copytext(block_text, i, i + 1)) + 1 - WAVE_FUNCTION_START
			function_profile_sets[i][character] += block_text

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
	var/list/intersection = list()
	//Perform the lookup
	var/block_length = SSwave_function_collapse.input_size * SSwave_function_collapse.input_size
	for (var/i in 1 to block_length)
		var/raw_character = copytext(restriction_string, i, i + 1)
		if (raw_character == "?")
			continue
		var/character = text2num(raw_character) + 1 - WAVE_FUNCTION_START
		intersection += list(function_profile_sets[i][character])
	if (!length(intersection))
		//This means that there are no restrictions, everything is allowed
		function_profile_cache[restriction_string] = splittext(profile_block_text, "\n")
		return function_profile_cache[restriction_string]
	//Do the intersection
	//O(n) algorithm for getting the intersection of 2 sorted lists.
	var/list/output = intersection[1]
	output = output.Copy()
	for (var/i in 2 to length(intersection))
		output = intersect_sorted_lists(output, intersection[i])
	function_profile_cache[restriction_string] = output
	return output

/datum/wave_function_profile/proc/intersect_sorted_lists(list/first, list/second)
	var/pointer_first = 1
	var/pointer_second = 1
	while (pointer_first <= length(first) && pointer_second <= length(second))
		var/element_first = first[pointer_first]
		var/element_second = second[pointer_second]
		//These elements are identical, move on
		if (element_first == element_second)
			pointer_first ++
			pointer_second ++
			continue
		//If the first is larger than the second, then increment the second pointer
		if (is_string_greater_than(element_first, element_second))
			pointer_second ++
			continue
		//If the second is larger than the first, then we are missing an element in the output
		//We don't need to increment the pointer because we made a cut
		first.Cut(pointer_first, pointer_first + 1)
	//Trim off the elements at the end that were not a match
	first.Cut(pointer_first)
	return first

/datum/wave_function_profile/proc/is_string_greater_than(a, b)
	if (length(a) > length(b))
		return TRUE
	if (length(a) < length(b))
		return FALSE
	return a > b
