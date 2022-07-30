/datum/mind/var/list/ambition_objectives = list()

#define FINDAMBITIONTASK_DEFAULT_NEW 1 // Make a new task of this type if one can't be found.
/datum/mind/proc/findambitionTask(var/typepath, var/options = 0)
	var/datum/ambition_objective/task = locate(typepath) in ambition_objectives
	if(!istype(task,typepath))
		if(options & FINDAMBITIONTASK_DEFAULT_NEW)
			task = new typepath()
			ambition_objectives += task
	return task

/datum/ambition_objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/completed = 0					//currently only used for custom objectives.
	var/per_unit = 0
	var/units_completed = 0
	var/units_compensated = 0 // Shit paid for
	var/units_requested = INFINITY
	var/completion_payment = 0			// Credits paid to owner when completed
/datum/ambition_objective/New(var/datum/mind/new_owner)
	owner = new_owner
	owner.ambition_objectives += src


/datum/ambition_objective/proc/get_description()
	var/desc = "Placeholder Objective"
	return desc

/datum/ambition_objective/proc/unit_completed(var/count=1)
	units_completed += count

/datum/ambition_objective/proc/is_completed()
	if(!completed)
		completed = check_for_completion()
	return completed

/datum/ambition_objective/proc/check_for_completion()
	if(per_unit)
		if(units_completed > 0)
			return 1
	return 0

/datum/game_mode/proc/declare_ambition_completion()
	var/text = "<hr><b><u>Осуществление амбиции</u></b>"

	for(var/datum/mind/employee in SSticker.minds)

		if(!employee.ambition_objectives.len)//If the employee had no objectives, don't need to process this.
			continue

		if(employee.assigned_role == employee.special_role || employee.offstation_role) //If the character is an offstation character, skip them.
			continue

		var/tasks_completed=0

		text += "<br>[employee.name] на должности [employee.assigned_role]:"

		var/count = 1
		for(var/datum/ambition_objective/objective in employee.ambition_objectives)
			if(objective.is_completed(1))
				text += "<br>&nbsp;-&nbsp;<B>Амбиция №[count]</B>: [objective.get_description()] <font color='green'><B> реализована!</B></font>"
				SSblackbox.record_feedback("nested tally", "employee_objective", 1, list("[objective.type]", "SUCCESS"))
				tasks_completed++
			else
			//	//отключено текстовое отображение не выполненных амбиций
			//	text += "<br>&nbsp;-&nbsp;<B>Амбиция №[count]</B>: [objective.get_description()] <font color='red'><b> не осуществлена.</b></font>"
				SSblackbox.record_feedback("nested tally", "employee_objective", 1, list("[objective.type]", "FAIL"))
			count++

		if(tasks_completed >= 1)
			text += "<br>&nbsp;<font color='green'><B>[employee.name] считает, что реализовал свои амбиции!</B></font>"
			SSblackbox.record_feedback("tally", "employee_success", 1, "SUCCESS")
		else
			SSblackbox.record_feedback("tally", "employee_success", 1, "FAIL")

	return text
