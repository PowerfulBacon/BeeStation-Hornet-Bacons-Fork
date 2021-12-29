/datum/nanossembly_code
	//A list of code lines in the program
	var/list/datum/nanossembly_line/lines
	//A list of labels in the program associated with their line number
	var/list/labels

/datum/nanossembly_code/proc/fetch_line(line_num)
	//Return null if no code line is provided
	if(line_num <= 0 || line_num > length(lines))
		return null
	//Return the code line
	return lines[line_num]
