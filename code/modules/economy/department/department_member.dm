/datum/department_member
	/// The member that this associates with
	var/datum/bank_account/account
	/// The rank in the organisation that this member holds
	var/rank = DEPARTMENT_ROLE_EMPLOYEE
	/// How much this department pays this person
	var/payment = 0

/datum/department_member/New(datum/bank_account/account, rank, payment)
	. = ..()
	src.account = account
	src.rank = rank
	src.payment = payment
