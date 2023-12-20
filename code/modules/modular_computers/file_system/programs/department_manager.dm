/datum/computer_file/program/department_manager
	filename = "depmanager"
	filedesc = "Department Management"
	program_icon = "command"
	extended_desc = "A program for managing necessary departmental processes, including budgeting, paychecks, and bills."
	required_access = list()
	transfer_access = list()
	requires_ntnet = TRUE
	size = 8
	tgui_id = "NtosDepartmentManager"
	var/datum/department/selected_department
	var/selected_function = ""

/datum/computer_file/program/department_manager/ui_static_data(mob/user)
	var/list/data = list()
	data["managed_departments"] = list()
	for (var/datum/department/department in SSeconomy.departments)
		// Check if we have access to this department
		if (!can_access_department(department))
			continue
		// Add a list of allowed department functions
		var/list/allowed_functions = list()
		for (var/datum/department_function/function as() in department.department_functions)
			allowed_functions += initial(function.function_name)
		data["managed_departments"] += list(list(
			"name" = department.department_name,
			"department_funds" = department.department_account.account_balance,
			"id" = department.department_id,
			"functions" = allowed_functions,
		))
	return data

/datum/computer_file/program/department_manager/ui_data(mob/user)
	var/list/data = list()
	data["selected_tab"] = selected_function
	data["selected_department"] = selected_department?.department_name || ""
	data["selected_tab_data"] = list()
	if (selected_department && can_access_department(selected_department))
		for (var/datum/department_function/function as() in selected_department.department_functions)
			if (function.function_name == selected_function)
				data["selected_tab_data"] = function.ui_data()
				break
	return data

/datum/computer_file/program/department_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch (action)
		if ("change_department")
			var/department_id = params["department_id"]
			selected_department = SSeconomy.get_department_by_id(department_id)
		if ("change_tab")
			var/requested = params["tab"]
			var/department_id = params["department_id"]
			var/datum/department/located = SSeconomy.get_department_by_id(department_id)
			if (!located)
				return
			for (var/datum/department_function/function as() in located.department_functions)
				if (initial(function.function_name) == requested)
					selected_function = requested
					return TRUE
	if (selected_department)
		// Check to ensure that the inserted card has access to the department
		if (!can_access_department(selected_department))
			return FALSE
		for (var/datum/department_function/function as() in selected_department.department_functions)
			if (function.function_name == selected_function)
				if (function.ui_act(action, params, ui, state))
					update_static_data(usr, ui)
					return TRUE

/datum/computer_file/program/department_manager/proc/can_access_department(datum/department/department)
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = computer.all_components[MC_CARD2]
	if (card_slot.stored_card?.registered_account)
		var/rank = department.get_member_rank(card_slot.stored_card.registered_account?.account_id)
		if (rank == DEPARTMENT_ROLE_MANAGER || rank == DEPARTMENT_ROLE_ADMINISTRATOR)
			return TRUE
	if (card_slot2.stored_card?.registered_account)
		var/rank = department.get_member_rank(card_slot2.stored_card.registered_account?.account_id)
		if (rank == DEPARTMENT_ROLE_MANAGER || rank == DEPARTMENT_ROLE_ADMINISTRATOR)
			return TRUE
	return FALSE
