/datum/skilltree
	//Skill level
	var/level_eng = 0
	var/level_sci = 0
	var/level_med = 0
	var/level_wep = 0
	var/level_srv = 0
	var/level_ant = 0
	//Points to spend
	var/points_eng = 0
	var/points_sci = 0
	var/points_med = 0
	var/points_wep = 0
	var/points_srv = 0
	var/points_ant = 0
	//exp per sector
	var/exp_eng = 0
	var/exp_sci = 0
	var/exp_med = 0
	var/exp_wep = 0
	var/exp_srv = 0
	var/exp_ant = 0

/datum/skilltree/proc/add_exp(eng = 0, sci = 0, med = 0, wep = 0, srv = 0, ant = 0)
	//Add on skill exp
	exp_eng += eng
	exp_sci += sci
	exp_med += med
	exp_wep += wep
	exp_srv += srv
	exp_ant += ant
	//Check levelling up
	check_level(eng, sci, med, wep, srv, ant)

/datum/skilltree/proc/check_level(eng = FALSE, sci = FALSE, med = FALSE, wep = FALSE, srv = FALSE, ant = FALSE)
	//Check eng
	if(eng && level_eng < SKILLTREE_MAX_LEVEL)
		var/required = get_level_up_requirement(level_eng + 1)
		if(exp_eng > required)
			exp_eng -= required
			level_eng += 1
			points_eng += 1
	//Check sci
	if(sci && level_sci < SKILLTREE_MAX_LEVEL)
		var/required = get_level_up_requirement(level_sci + 1)
		if(exp_sci > required)
			exp_sci -= required
			level_sci += 1
			points_sci += 1
	//Check med
	if(med && level_med < SKILLTREE_MAX_LEVEL)
		var/required = get_level_up_requirement(level_med + 1)
		if(exp_med > required)
			exp_med -= required
			level_med += 1
			points_med += 1
	//Check wep
	if(wep && level_wep < SKILLTREE_MAX_LEVEL)
		var/required = get_level_up_requirement(level_wep + 1)
		if(exp_wep > required)
			exp_wep -= required
			level_wep += 1
			points_wep += 1
	//Check srv
	if(srv && level_srv < SKILLTREE_MAX_LEVEL)
		var/required = get_level_up_requirement(level_srv + 1)
		if(exp_srv > required)
			exp_srv -= required
			level_srv += 1
			points_srv += 1
	//Check ant
	if(ant && level_ant < SKILLTREE_MAX_LEVEL)
		var/required = get_level_up_requirement(level_ant + 1)
		if(exp_ant > required)
			exp_ant -= required
			level_ant += 1
			points_ant += 1

/datum/skilltree/proc/get_level_up_requirement(level)
	return (SKILLTREE_SQUARE_COEFF * level * level) + (SKILLTREE_X_COEFF * x) + SKILLTREE_FIRST_LEVEL
