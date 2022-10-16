/// Parse anomdat file
/proc/parse_anomdat(filepath)
	var/full_text = file2text(filepath)
	var/list/text_lines = splittext(full_text, "\n")
	parse_text(list(), 0, text_lines)

/proc/parse_text(current_indentation, list/text_lines)
	var/static/regex/data_point_regex = new("(\\w*)\\s*:\\s*(.*)$", "m")
	//Parse self
	var/datum/parsed_list_datum/self = new()
	for (var/line in text_lines)
		//This does not belong to us
		if (indentation_level(line) != current_indentation)
			continue
		//Split the line by the comma
		data_point_regex.Find(line)
		var/var_name = data_point_regex.group[1]
		var/var_value = data_point_regex.group[2]
		if (var_name == "type")
			self.typepath = var_value
		else
			self.data[var_name] = var_value
	//Parse children
	var/list/child_lines = list()
	for(var/line in text_lines)
		//If we are the same indentation, or less, its not a child node
		if (indentation_level(line) <= current_indentation)
			continue
		//If we read a type, then create a new child
		if (data_point_regex.Find(line))
			var/var_name = data_point_regex.group[1]
			if (indentation_level(line) == current_indentation + 1 && var_name == "type" && length(child_lines))
				self.children += parse_text(current_indentation + 1, child_lines)
				child_lines = list()
		child_lines += line
	//Final parse
	if (length(child_lines))
		self.children += parse_text(current_indentation + 1, child_lines)
	//Return our parsed self
	return self

///Returns the indentation level of a line
/proc/indentation_level(line)
	. = 0
	for(var/i in 1 to length(line))
		if (line[i] != "\t")
			return
		. ++

/datum/parsed_list_datum
	var/typepath
	/// List of any variables applied. Note that everything is stored as text
	var/list/data = list()
	/// List of all of our children
	var/list/children = list()
