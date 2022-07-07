/datum/room_cell
	//The area state
	var/area_state = CELL_EMPTY
	//The cell state
	var/cell_state = CELL_EMPTY
	//The entropy of this cell
	var/entropy = 0
	//List of all possible states
	var/possible_states = list()
