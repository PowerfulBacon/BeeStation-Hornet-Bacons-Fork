/datum/computer_file/program/department_manager
	filename = "depmanager"
	filedesc = "Department Management"
	program_icon = "command"
	extended_desc = "A program for managing necessary departmental processes, including budgeting, paychecks, and bills."
	required_access = list(ACCESS_HEADS)
	transfer_access = list(ACCESS_HEADS)
	requires_ntnet = TRUE
	size = 8
	tgui_id = "NtosDepartmentManager"

/datum/computer_file/program/department_manager/ui_static_data(mob/user)
	var/list/data = list()
	data["managed_departments"] = list()
	for (var/datum/department/department in SSeconomy.departments)
		var/list/department_members = list()
		for (var/datum/department_member/member in department.department_members)
			department_members += list(list(
				"name" = member.account.account_holder,
				"rank" = member.rank,
				"payment" = member.payment,
				"id" = member.account.account_id
			))
		data["managed_departments"] += list(list(
			"name" = department.department_name,
			"department_funds" = department.department_account.account_balance,
			"members" = department_members,
			"id" = department.department_id
		))
	return data

/datum/computer_file/program/department_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch (action)
		if ("fire_employee")
			var/department_id = params["department_id"]
			// No need for sanitisation as it is only used for comparison
			var/employee_id = params["id"]
			var/datum/department/located = SSeconomy.get_department_by_id(department_id)
			// Invalid ID passed from the client
			if (!located)
				return
			// Check to ensure that the inserted card has access to the department
			if (!can_access_department(located))
				return
			located.fire_member(employee_id)

/datum/computer_file/program/department_manager/proc/can_access_department(datum/department/department)
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = computer.all_components[MC_CARD2]
	if (card_slot.stored_card?.registered_account)
		var/rank = department.get_member_rank(card_slot.stored_card.registered_account)
		if (rank == DEPARTMENT_ROLE_MANAGER || rank == DEPARTMENT_ROLE_ADMINISTRATOR)
			return TRUE
	if (card_slot2.stored_card?.registered_account)
		var/rank = department.get_member_rank(card_slot2.stored_card.registered_account)
		if (rank == DEPARTMENT_ROLE_MANAGER || rank == DEPARTMENT_ROLE_ADMINISTRATOR)
			return TRUE
	return FALSE
