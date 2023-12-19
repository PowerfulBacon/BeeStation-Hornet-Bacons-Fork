/datum/department
	/// Unique identifier for the department
	var/department_id = 0
	/// Name of the department
	var/department_name = ""
	/// Budget attached to the department
	var/datum/bank_account/department/department_account
	/// Members of the department
	var/list/department_members = list()
	/// List of all transactions that have been applied
	var/list/transactions = list()
	/// List of functions that the department has access to
	var/list/department_functions = list()

/datum/department/New()
	. = ..()
	var/static/id = 0
	department_id = id ++
	department_account = new(1000)
	department_account.account_holder = department_name
	department_account.nonstation_account = FALSE
	department_functions += new /datum/department_function/budget(src)

/datum/department/proc/handle_paychecks()
	for (var/datum/department_member/member in department_members)
		if (!pay(member.account, "Paycheck", member.payment, "Payment of employee's paycheck."))
			member.account.bank_card_talk("ERROR: Payday aborted, [department_account] departmental funds insufficient.")
		else
			member.account.bank_card_talk("Payday processed, account now holds $[member.account.account_balance], paid with $[member.payment] from [department_account] budget.")

/datum/department/proc/pay(datum/bank_account/target, purpose, amount, reason)
	if (target.transfer_money(department_account, amount))
		transactions += new /datum/department_transaction("[target.account_holder] - [purpose]", -amount, reason, department_account.account_balance)
		return TRUE
	return FALSE

/datum/department/proc/add_member(datum/bank_account/account, rank, payment)
	department_members += new /datum/department_member(account, rank, payment)

/datum/department/proc/fire_member(account_id)
	for (var/datum/department_member/member in department_members)
		if (member.account.account_id != account_id)
			continue
		// Perform the firing duty
		department_members -= member
		member.account.bank_card_talk("You have been fired from the '[department_name]' department. Please return all loaned equipment and identification card to the department's head immediately.")

/datum/department/proc/get_member_rank(datum/bank_account/account)
	for (var/datum/department_member/member in department_members)
		if (member.account == account)
			return member.rank
	return null
