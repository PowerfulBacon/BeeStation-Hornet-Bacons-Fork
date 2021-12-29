/mob/var/datum/nanossembly_ui/nanossembly_ui = new()

/mob/verb/open_assembler_ui()
	set name = "open nanossembly"
	set category = "nanossembly"

	message_admins("boop")
	nanossembly_ui.ui_interact(usr)

/datum/nanossembly_ui
	//Console output
	var/list/console_output = list()
	//The documentation data
	var/static/list/documentation_file = null
	//In built interpreter
	var/datum/nanossembly_interpreter/interpreter = new
	//The selected screen
	var/selectedScreen = INSTRUCTION_HELP

/datum/nanossembly_ui/New()
	. = ..()
	//Load the documentation file
	if(isnull(documentation_file))
		documentation_file = splittext(file2text('code/modules/nanossembly/documentation.md'), "\n")

/datum/nanossembly_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/nanossembly_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NanossemblyIde")
		ui.open()

/datum/nanossembly_ui/ui_data(mob/user)
	var/list/data = list()

	data["lines"] = list()

	data["output"] = interpreter.console_output

	switch(selectedScreen)
		if(INSTRUCTION_HELP)
			data["screenData"] = splittext(documentation_file, "\n")
		if(MEMORY_STATE)
			data["screenData"] = list()
			for(var/register_name in interpreter.registers)
				var/register_value = interpreter.registers[register_name]
				data["screenData"] = "[register_name]: [register_value]"
		else
			data["screenData"] = "error"

	return data

/datum/nanossembly_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	message_admins("act")
	switch(action)
		if("compile")
			//Run the compiler
			var/error_line = interpreter.test_compilation()
			if(error_line == -1)
				interpreter.write_console("Compilation error: No loaded program!")
			else if(error_line)
				interpreter.write_console("Compilation error on line [error_line]! [interpreter.compilation_error]")
			else
				interpreter.write_console("Compilation successful!")
			. = TRUE
		if("setScreen")
			selectedScreen = params["screen"]
			. = TRUE
		if("step")
			interpreter.single_step()
		if("setProgramText")
			//Create a new program
			interpreter.program = new
			//Get the program text
			var/text = params["text"]
			//Max program length
			if(text >= 20000)
				interpreter.write_console("Program file is too long, max length allowed: 20000!")
				return
			//Split into lines
			var/list/splittext = splittext(text, "\n")
			//Create the program
			for(var/line in splittext)
				//Clean tabs
				var/cleaned_line = replacetext(line, "\t", "")
				//Process the line
				//Check for comments
				if(length(cleaned_line) == 0 || (length(cleaned_line) >= 2 && copytext(cleaned_line, 1, 3) == "//"))
					//Add in a nop instruction (These are skipped over by the interpreter and result in 0 tick cost)
					interpreter.program.lines += new /datum/nanossembly_line/nop()
					continue
				var/text_pos = findtext(cleaned_line, ":")
				//Check for labels
				if(text_pos != 0)
					//Get the name of the label
					var/label_name = copytext(cleaned_line, 1, text_pos)
					//Add a nop instruction (so line numbers line up)
					interpreter.program.lines += new /datum/nanossembly_line/nop()
					//Add the label that points to the nop line
					interpreter.program.labels[label_name] = length(interpreter.program.lines)
					continue
				//Add in a command
				//Split the text by spaces
				var/list/command_split = splittext(cleaned_line, " ")
				//If no space was found, set it to the end of the line
				if(!command_split)
					command_split = cleaned_line
				//Get the command name
				var/command_path = command_split[1]
				//Remove the command name from params
				command_split.Remove(command_path)
				//Search for the command
				var/path = text2path("/datum/nanossembly_line/[command_path]")
				if(!path)
					interpreter.write_console("ERROR: Unknown command at line [length(interpreter.program.lines) + 1]: [command_path]")
					return
				//Check if path exists
				var/datum/nanossembly_line/created_line = new path()
				//Create it and set the parameters
				created_line.operands = command_split
			interpreter.write_console("Successfully created program with [length(interpreter.program.lines)] lines.")
