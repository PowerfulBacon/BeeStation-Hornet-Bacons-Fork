/**
 * An efficient method for locating the tile that has the minimum
 * entropy value for the wave function collapse algorithm.
 * Searching the entire grid would be O(n), this is O(log(n)), which
 * is very good!
 *
 * Idea:
 *  - Split the grid into 2x2 parent cells. Record the lowest value in the child cells.
 *  - Split those grids into 2x2 parent cells. Record the lowest value in the child cells.
 *  - Repeat until you only have 1 cell remaining.
 *  - When you take the minimum cell, remove it and traverse the tree structure in order
 *  - to recalculate the lowest value (Similarly to how a heap works)
 * @PowerfulBacon
 */

/datum/entropy_map_node
	///The X value of the bottom left cell
	var/x
	///The Y value of the bottom left cell
	var/y
	/// The child nodes if we aren't a base node
	var/list/datum/entropy_map_node/child_nodes = null
	/// The highest value we store
	var/value

/datum/entropy_map_node/New(x, y)
	. = ..()
	src.x = x
	src.y = y

/datum/entropy_map_node/proc/determine_initial_value()
	if (!length(child_nodes))
		return
	value = INFINITY
	for (var/datum/entropy_map_node/emn as() in child_nodes)
		emn.determine_initial_value()
		value = min(value, emn.value)

/datum/entropy_map_node/proc/take()
	//TODO
	CRASH("Not implemented exception")

///Map should be a 2D array
/proc/build_entropy_map(list/map)
	if (!length(map))
		return null
	// Build the base
	var/list/base_map = new(length(map[1]), length(map))
	for (var/y in 1 to length(map))
		for (var/x in 1 to length(map[y]))
			var/datum/entropy_map_node/created_node = new(x, y)
			created_node.value = map[x][y]
			base_map[x][y] = created_node
	//Recursively build the map until its completed
	var/increment = 1
	while (increment < max(length(map[1]), length(map)))
		//Increase the increment before we check, because
		//we want to end with a node that has no siblings
		var/half_increment = increment
		increment <<= 1
		for (var/y in 1 to length(map) step increment)
			for (var/x in 1 to length(map[y]) step increment)
				var/datum/entropy_map_node/created_node_parent = new(x, y)
				created_node_parent.child_nodes = list(base_map[x][y])
				if (x + half_increment <= length(map[y]))
					created_node_parent.child_nodes += base_map[x + half_increment][y]
				if (y + half_increment <= length(map))
					created_node_parent.child_nodes += base_map[x][y + half_increment]
				if (y + half_increment <= length(map) && x + half_increment <= length(map[y]))
					created_node_parent.child_nodes += base_map[x + half_increment][y + half_increment]
				base_map[x][y] = created_node_parent
	var/datum/entropy_map_node/root_node = base_map[1][1]
	root_node.determine_initial_value()
	return root_node
