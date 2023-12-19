/datum/department_function
	var/function_name
	var/datum/department/department

/datum/department_function/New(datum/department/department)
	. = ..()
	src.department = department
