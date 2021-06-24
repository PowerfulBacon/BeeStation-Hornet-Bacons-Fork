/datum/skilltree
	var/list/lazy_created_chems

/datum/skilltree/proc/check_chem(created_chem, amount)
	//Get the base amount of EXP
	var/total_exp = FLOOR(SKILLTREE_EXP_OLDCHEM * amount, 1)
	//Check if the chem is brand new
	if(!LAZYFIND(lazy_created_chems, created_chem))
		total_exp += SKILLTREE_EXP_NEWCHEM
		LAZYADD(lazy_created_chems, created_chem)
	//Add EXP gained
	add_exp(med = total_exp)
