#define GAS_ID_TEMP 10000

#define STATE_CLEAR 0
#define STATE_GAS_O 1
#define STATE_GAS_N 2
#define STATE_GAS_PLASMA 3
#define STATE_GAS_N2O 4
#define STATE_GAS_C 5
#define STATE_GAS_N2 6
#define STATE_NUMBERS 7
#define STATE_GAS_O2 8
#define STATE_TEMP 9

//Copies variables from a particularly formatted string.
//Returns: 1 if we are mutable, 0 otherwise
/datum/gas_mixture/proc/populate_from_gas_string(gas_string)
	CHECK_IMMUTABILITY
	//mmm finite state machine
	var/state = 0
	var/gas_id = 0
	var/moles = 0
	var/lower_case = lowertext(gas_string)
	var/decimals = FALSE
	var/decimal_count = 1
	for (var/i in 1 to length(lower_case))
		switch (lower_case[i])
			if ("0")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
				else
					moles = 10 * moles
			if ("1")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
					moles += 1 / decimal_count
				else
					moles = 10 * moles + 1
			if ("2")
				if (state == STATE_NUMBERS)
					if (decimals)
						decimal_count *= 10
						moles += 2 / decimal_count
					else
						moles = 10 * moles + 2
				else if (state == STATE_GAS_O)
					state = STATE_GAS_O2
				else if (state == STATE_GAS_N)
					state = STATE_GAS_N2
				else
					CRASH("Failed to parse gas string '[gas_string]'")
			if ("3")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
					moles += 3 / decimal_count
				else
					moles = 10 * moles + 3
			if ("4")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
					moles += 4 / decimal_count
				else
					moles = 10 * moles + 4
			if ("5")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
					moles += 5 / decimal_count
				else
					moles = 10 * moles + 5
			if ("6")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
					moles += 6 / decimal_count
				else
					moles = 10 * moles + 6
			if ("7")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
					moles += 7 / decimal_count
				else
					moles = 10 * moles + 7
			if ("8")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
					moles += 8 / decimal_count
				else
					moles = 10 * moles + 8
			if ("9")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (decimals)
					decimal_count *= 10
					moles += 9 / decimal_count
				else
					moles = 10 * moles + 9
			if (".")
				if (state != STATE_NUMBERS)
					CRASH("Failed to parse gas string '[gas_string]'")
				decimals = TRUE
			if ("=")
				switch (state)
					if (STATE_GAS_O2)
						moles = 0
						gas_id = GAS_O2
					if (STATE_GAS_N2)
						moles = 0
						gas_id = GAS_N2
					if (STATE_GAS_N2O)
						moles = 0
						gas_id = GAS_NITROUS
					if (STATE_GAS_PLASMA)
						moles = 0
						gas_id = GAS_PLASMA
					if (STATE_TEMP)
						moles = 0
						gas_id = GAS_ID_TEMP
					else
						CRASH("Failed to parse gas string '[gas_string]'")
				state = STATE_NUMBERS
			if ("a")
				if (state != STATE_GAS_PLASMA)
					CRASH("Failed to parse gas string '[gas_string]'")
			if ("e")
				if (state != STATE_TEMP)
					CRASH("Failed to parse gas string '[gas_string]'")
			if ("l")
				if (state != STATE_GAS_PLASMA)
					CRASH("Failed to parse gas string '[gas_string]'")
			if ("m")
				if (state != STATE_GAS_PLASMA && state != STATE_TEMP)
					CRASH("Failed to parse gas string '[gas_string]'")
			if ("n")
				if (state != STATE_CLEAR)
					CRASH("Failed to parse gas string '[gas_string]'")
				state = STATE_GAS_N
			if ("o")
				switch (state)
					if (STATE_CLEAR)
						state = STATE_GAS_O
					if (STATE_GAS_N2)
						state = STATE_GAS_N2O
					else
						CRASH("Failed to parse gas string '[gas_string]'")
			if ("p")
				if (state == STATE_CLEAR)
					state = STATE_GAS_PLASMA
				else if (state != STATE_TEMP)
					CRASH("Failed to parse gas string '[gas_string]'")
			if ("s")
				if (state != STATE_GAS_PLASMA)
					CRASH("Failed to parse gas string '[gas_string]'")
			if ("t")
				if (state != STATE_CLEAR)
					CRASH("Failed to parse gas string '[gas_string]'")
				state = STATE_TEMP
				gas_id = GAS_ID_TEMP
			if (";")
				if (!gas_id)
					CRASH("Failed to parse gas string '[gas_string]'")
				if (gas_id == GAS_ID_TEMP)
					set_temperature(moles)
				else
					gas_contents[gas_id] += moles
					total_moles += moles
				state = STATE_CLEAR
				gas_id = 0
				moles = 0
				decimals = FALSE
				decimal_count = 1
			else
				CRASH("Failed to parse gas string '[gas_string]'")
	if (gas_id)
		if (gas_id == GAS_ID_TEMP)
			set_temperature(moles)
		else
			gas_contents[gas_id] += moles
			total_moles += moles
		state = STATE_CLEAR
		gas_id = 0
		moles = 0
	gas_content_change()
