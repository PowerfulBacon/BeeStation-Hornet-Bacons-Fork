
/datum/component/modsuit/proc/get_charge_source()
	return core?.charge_source()

/datum/component/modsuit/proc/get_charge()
	return core?.charge_amount() || 0

/datum/component/modsuit/proc/get_max_charge()
	return core?.max_charge_amount() || 1 //avoid dividing by 0

/datum/component/modsuit/proc/get_charge_percent()
	return ROUND_UP((get_charge() / get_max_charge()) * 100)

/datum/component/modsuit/proc/add_charge(amount)
	return core?.add_charge(amount) || FALSE

/datum/component/modsuit/proc/subtract_charge(amount)
	return core?.subtract_charge(amount) || FALSE

/datum/component/modsuit/proc/check_charge(amount)
	return core?.check_charge(amount) || FALSE
