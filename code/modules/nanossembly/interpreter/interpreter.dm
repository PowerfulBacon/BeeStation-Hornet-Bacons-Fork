/datum/nanossembly_interpreter
	//The currently running program
	var/datum/nanossembly_code/program
	//The interpreter stack
	//Can use push and pop to add and remove
	var/list/stack = new(MAXIMUM_STACK_SIZE)
	//The register set
	var/list/registers
	//The memory of the program
	var/list/memory
	//Compilation error detection
	var/compilation_error = FALSE
	//The console output
	var/list/console_output = list()

/datum/nanossembly_interpreter/New(
		memory_amount = DEFAULT_MEMORY_SIZE,
		register_amount = MAXIMUM_STACK_SIZE
		)
	. = ..()
	//Initialize the memory
	memory = new(DEFAULT_MEMORY_SIZE)
	//Create the register set
	registers = list()
	//Create special registers
	registers[LINK_REGISTER] = 0
	registers[FLAG_REGISTER] = 0
	registers[PROGRAM_REGISTER] = 1
	//Create standard registers
	for(var/i in 1 to register_amount)
		registers["R[i]"] = 0

/datum/nanossembly_interpreter/proc/reset_comparision_flags()
	registers[FLAG_REGISTER] &= ~(EQUAL_FLAG & GREATER_FLAG)

/datum/nanossembly_interpreter/proc/set_equal()
	registers[FLAG_REGISTER] |= EQUAL_FLAG

/datum/nanossembly_interpreter/proc/set_greater()
	registers[FLAG_REGISTER] |= GREATER_FLAG

/datum/nanossembly_interpreter/proc/set_error()
	registers[FLAG_REGISTER] |= ERROR_FLAG

/datum/nanossembly_interpreter/proc/put_in_register(register, value)
	if(!(register in registers))
		compiler_error("Invalid register ([register])")
		return FALSE
	registers[register] = value
	return TRUE

///Get the value of value
///#... is interpreted as a raw number
///R... is interpreted as fetching from a register
/datum/nanossembly_interpreter/proc/get_value(value)
	switch(value[1])
		if("#")
			//Return the raw value
			return text2num(copytext(value, 2))
		if("R")
			//Fetch the value of the register
			if(!(value in registers))
				compiler_error("Invalid register ([value])")
				return FALSE
			return registers[value]
		else
			compiler_error("Unrecognised value ([value]), value must be either a direct number (#) or a register (R) reference.")
			return null

///Runs a testrun of the program and check that everything works
///Returns 0 if successful
///Returns -1 if no program is loaded
///Otherwise returns the line number that the compiler failed on
/datum/nanossembly_interpreter/proc/test_compilation()
	if(!program)
		return -1
	//Turn off the compilation error
	compilation_error = FALSE
	//Run through the program
	for(var/i in 1 to length(program.lines))
		//Set the program counter to the link (ignore branches and the code jumping around)
		registers[PROGRAM_REGISTER] = i
		//Execute the current line
		single_step()
		//Check for compiler errors
		if(compilation_error)
			return i
	//Success
	return 0

///Should be called for errors that can be detected in compilation
///such as invalid code formatting.
///Before running the compiler will run every command once with fake inputs
///to make sure no compiler errors are thrown
/datum/nanossembly_interpreter/proc/compiler_error(message = "Unknown error")
	compilation_error = message

///Perform a single step of the program
/datum/nanossembly_interpreter/proc/single_step()
	//Check if program has ended
	var/current_line = registers[PROGRAM_REGISTER]
	if(current_line <= 0 || current_line > length(program.lines))
		complete_execution()
		return
	//Fetch the currently executing instruction
	var/datum/nanossembly_line/line = program.lines[current_line]
	line.execute(src)
	//Increment line number until a valid line or the end is reached
	registers[PROGRAM_REGISTER] ++
	//Check the next 10 lines for a valid line
	for(var/i in 1 to 10)
		if(registers[PROGRAM_REGISTER] > length(program.lines))
			return
		//Stop when we find an executeable line
		if(!istype(program.lines[registers[PROGRAM_REGISTER]], /datum/nanossembly_line/nop))
			return
		registers[PROGRAM_REGISTER] ++

/datum/nanossembly_interpreter/proc/complete_execution()

/datum/nanossembly_interpreter/proc/write_console(message)
	if(length(console_output) >= 50)
		console_output.Remove(console_output[1])
	var/output = copytext(message, 1, min(length(message), MAX_CONSOLE_MESSAGE_LENGTH))
	console_output.Add(output)
