/obj/item/stack/medical
	name = "injury tender"
	desc = "A genertic tending item."
	icon = 'icons/obj/stack_objects.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	//Injuries this item can heal
	var/list/valid_injuries = list()
	//Damage multiplier when tended
	var/tended_damage_multiplier = 0.4
	//Pain multiplier once tended
	var/tended_pain_multiplier = 0.7
	//Time per damage until injury expires when tended
	var/tended_expiry_rate = 15 SECONDS
	//Delay to apply to others
	var/other_delay = 10
	//Delay to apply to self
	var/self_delay = 50
