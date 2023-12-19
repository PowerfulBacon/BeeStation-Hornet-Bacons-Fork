/datum/department_transaction
	var/purchase
	var/amount
	var/time
	var/reason

/datum/department_transaction/New(purchase, amount, reason)
	. = ..()
	src.purchase = purchase
	src.amount = amount
	src.reason = reason
	time = station_time_timestamp()
