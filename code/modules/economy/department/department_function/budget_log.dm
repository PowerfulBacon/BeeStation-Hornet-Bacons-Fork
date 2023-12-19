/datum/department_function/budget
	function_name = "funding"

/datum/department_function/budget/ui_data(mob/user)
	var/list/data = list()
	var/list/transactions = list()
	for (var/datum/department_transaction/transaction in department.transactions)
		transactions += list(list(
			"purchase" = transaction.purchase,
			"amount" = transaction.amount,
			"time" = transaction.time,
			"reason" = transaction.reason,
			"tick" = transaction.tick,
			"total_money" = transaction.total_money,
		))
	data["transactions"] = transactions
	return data
