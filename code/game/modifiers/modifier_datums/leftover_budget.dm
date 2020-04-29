#define MONEY_GAIN_MIN 1000
#define MONEY_GAIN_MAX 10000

/datum/round_modifier/leftover_budget
	name = "Leftover Budget"
	desc = "Nanotrasen has recently found some leftover cash reserves gained \
		from legitimate means that they need to quickly dispose of. As a \
		result some departments may notice and increase in funds.."
	points = 1
	weight = 10

/datum/round_modifier/leftover_budget/post_setup()
	//Find budget cards
	for(var/obj/item/card/id/departmental_budget/D)
		var/datum/bank_account/B = SSeconomy.get_dep_account(D.department_ID)
		if(!B)
			continue
		//Mmmmm money
		B.adjust_money(rand(MONEY_GAIN_MIN, MONEY_GAIN_MAX))

#undef MONEY_GAIN_MIN
#undef MONEY_GAIN_MAX
