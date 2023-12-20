/datum/department_function/employee
	function_name = "employee"

/datum/department_function/employee/ui_data(mob/user)
	var/list/data = list()
	var/list/members = list()
	for (var/datum/department_member/member in department.department_members)
		members += list(list(
			"id" = member.account.account_id,
			"name" = member.account.account_holder,
			"rank" = member.rank,
			"paycheck" = member.payment
		))
	data["members"] = members
	return data

/datum/department_function/employee/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch (action)
		if ("fire_employee")
			// No need for sanitisation as it is only used for comparison
			var/employee_id = params["id"]
			department.fire_member(employee_id)
			return TRUE
		if ("set_paycheck")
			department.update_member_paycheck(params["id"], text2num(params["amount"]))
			return TRUE
		if ("set_rank")
			department.update_member_rank(params["id"], params["rank"])
			return TRUE
