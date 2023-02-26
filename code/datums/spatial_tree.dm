// Provides O(logn) lookup and O(logn) memory usage for objects stored in a 2D map.
// Use this for things where processing isn't that much more important than not using tons of memory.
// Use a straight 2D array if you are going to be performing 100000s of lookups. Use this if you
// are going to be storing lots of different maps and groups and aren't doing huge amounts of lookups.
/datum/spatial_tree
	var/datum/spatial_tree/parent
	var/min_x
	var/min_y
	var/max_x
	var/max_y
	// The value, if we have one
	var/value
	// The adjacent tiles, if they exist
	var/list/adjacent
	// 1 = top left
	// 2 = top right
	// 3 = bottom left
	// 4 = bottom right
	var/list/children = new(4)

/datum/spatial_tree/New(datum/spatial_tree/parent, min_x, min_y, max_x, max_y)
	. = ..()
	src.parent = parent
	src.min_x = min_x
	src.min_y = min_y
	src.max_x = max_x
	src.max_y = max_y
	// We are a value node
	if (min_x == max_x && min_y == max_y)
		var/datum/spatial_tree/current = src
		while (current.parent != null)
			current = current.parent
		adjacent = list()
		// Locate adjacent tiles
		var/datum/spatial_tree/located
		if ((located = current.get(min_x + 1, min_y + 1)) != null)
			located.adjacent += src
			adjacent += located
		if ((located = current.get(min_x - 1, min_y + 1)) != null)
			located.adjacent += src
			adjacent += located
		if ((located = current.get(min_x + 1, min_y - 1)) != null)
			located.adjacent += src
			adjacent += located
		if ((located = current.get(min_x - 1, min_y - 1)) != null)
			located.adjacent += src
			adjacent += located

/datum/spatial_tree/proc/get(x, y)
	if (min_x == max_x && min_y == max_y)
		return value
	var/datum/spatial_tree/child
	if (x > (max_x - min_x) * 0.5 + min_x)
		if (y > (max_y - min_y) * 0.5 + min_y)
			child = children[2]
		else
			child = children[4]
	else
		if (y > (max_y - min_y) * 0.5 + min_y)
			child = children[1]
		else
			child = children[3]
	if (!child)
		return null
	return child.get(x, y)

/datum/spatial_tree/proc/put(x, y, value)
	if (min_x == max_x && min_y == max_y)
		src.value = value
		return
	var/datum/spatial_tree/child
	if (x > (max_x - min_x) * 0.5 + min_x)
		if (y > (max_y - min_y) * 0.5 + min_y)
			child = children[2]
			if (!child)
				children[2] = (child = new /datum/spatial_tree(src))
		else
			child = children[4]
			if (!child)
				children[4] = (child = new /datum/spatial_tree(src))
	else
		if (y > (max_y - min_y) * 0.5 + min_y)
			child = children[1]
			if (!child)
				children[1] = (child = new /datum/spatial_tree(src))
		else
			child = children[3]
			if (!child)
				children[3] = (child = new /datum/spatial_tree(src))
	return child.put(x, y, value)

/datum/spatial_tree/proc/take(x, y, value)
	if (min_x == max_x && min_y == max_y)
		// Remove from adjacent nodes
		var/datum/spatial_tree/current = src
		while (current.parent != null)
			current = current.parent
		adjacent = list()
		// Locate adjacent tiles
		var/datum/spatial_tree/located
		if ((located = current.get(min_x + 1, min_y + 1)) != null)
			located.adjacent -= src
		if ((located = current.get(min_x - 1, min_y + 1)) != null)
			located.adjacent -= src
		if ((located = current.get(min_x + 1, min_y - 1)) != null)
			located.adjacent -= src
		if ((located = current.get(min_x - 1, min_y - 1)) != null)
			located.adjacent -= src
		return TRUE
	var/datum/spatial_tree/child
	if (x > (max_x - min_x) * 0.5 + min_x)
		if (y > (max_y - min_y) * 0.5 + min_y)
			child = children[2]
			if (child?.take(x, y, value))
				children[2] = null
		else
			child = children[4]
			if (child?.take(x, y, value))
				children[4] = null
	else
		if (y > (max_y - min_y) * 0.5 + min_y)
			child = children[1]
			if (child?.take(x, y, value))
				children[1] = null
		else
			child = children[3]
			if (child?.take(x, y, value))
				children[3] = null
	// If children is now empty, we are no longer needed
	if (!children[1] && !children[2] && !children[3] && !children[4])
		return TRUE
	return FALSE
