/datum/department_transaction
	var/purchase
	var/amount
	var/time
	var/reason
	var/total_money
	var/tick

/datum/department_transaction/New(purchase, amount, reason, total_money)
	. = ..()
	src.purchase = purchase
	src.amount = amount
	src.reason = reason
	src.total_money = total_money
	tick = world.time
	time = station_time_timestamp()
