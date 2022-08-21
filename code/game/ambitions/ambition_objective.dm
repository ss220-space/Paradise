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
	var/description = "Пустая амбиция ((перешлите это разработчику))"
	var/chance_generic_ambition = 30	//шанс выпадения ОБЩЕЙ амбиции

/datum/ambition_objective/New(var/datum/mind/new_owner)
	owner = new_owner
	owner.ambition_objectives += src

/datum/ambition_objective/proc/get_random_ambition()
	var/result

	//Шанс выпадения общей амбиции или амбиции отдела
	if(prob(chance_generic_ambition))
		result = pick_list("ambition_objectives_generic.json", "Общий")
	else
		result = get_job_departament_ambition()
		if (!result)
			result = pick_list("ambition_objectives_generic.json", "Общий")

	return result

/datum/ambition_objective/proc/get_job_departament_ambition()
	var/result

	//Шанс выпадения общей роли из отдела
	var/job = owner.assigned_role
	if(prob(chance_generic_ambition))
		job = "Общий"

	//Проверяем работы не в позициях и вынесенные в отдельный документ
	switch(owner.assigned_role)
		if("Magistrate" || "Internal Affairs Agent")
			result = pick_list("ambition_objectives_law.json", job)
			if (!result)
				return result

		if("Nanotrasen Representative" || "Blueshield")
			result = pick_list("ambition_objectives_representative.json", job)
			if (!result)
				return result

	//Проверяем работы вынесенные в позиции
	if(owner.assigned_role in GLOB.civilian_positions)
		result = pick_list("ambition_objectives_generic.json", job)
		if (!result)
			return result

	if(owner.assigned_role in GLOB.command_positions)
		//шанс получить за главу работу одного из своих отделов
		if (prob(chance_generic_ambition))
			switch(owner.assigned_role)
				if("Head of Personnel")
					if (prob(50))
						job = pick(GLOB.support_positions)
						result = pick_list("ambition_objectives_support.json", job)
					else
						job = pick(GLOB.supply_positions)
						result = pick_list("ambition_objectives_supply.json", job)
				if("Head of Security")
					job = pick(GLOB.security_positions)
					result = pick_list("ambition_objectives_security.json", job)
				if("Chief Engineer")
					job = pick(GLOB.engineering_positions)
					result = pick_list("ambition_objectives_engineering.json", job)
				if("Research Director")
					job = pick(GLOB.science_positions)
					result = pick_list("ambition_objectives_science.json", job)
				if("Chief Medical Officer")
					job = pick(GLOB.medical_positions)
					result = pick_list("ambition_objectives_medical.json", job)
		if (!result)
			result = pick_list("ambition_objectives_command.json", job)
		return result

	if(owner.assigned_role in GLOB.support_positions)
		result = pick_list("ambition_objectives_support.json", job)
		if (!result)
			return result

	if(owner.assigned_role in GLOB.engineering_positions)
		result = pick_list("ambition_objectives_engineering.json", job)
		if (!result)
			return result

	if(owner.assigned_role in GLOB.medical_positions)
		result = pick_list("ambition_objectives_medical.json", job)
		if (!result)
			return result

	if(owner.assigned_role in GLOB.science_positions)
		result = pick_list("ambition_objectives_science.json", job)
		if (!result)
			return result

	if(owner.assigned_role in GLOB.supply_positions)
		result = pick_list("ambition_objectives_supply.json", job)
		if (!result)
			return result

	if(owner.assigned_role in GLOB.security_positions)
		result = pick_list("ambition_objectives_security.json", job)
		if (!result)
			return result

	if(owner.assigned_role in GLOB.nonhuman_positions)
		result = pick_list("ambition_objectives_nonhuman.json", job)
		if (!result)
			return result
	return result

/datum/game_mode/proc/declare_ambition_completion()
	var/text = "<hr><b><u>Осуществление амбиции</u></b>"

	for(var/datum/mind/employee in SSticker.minds)

		if(!employee.ambition_objectives.len)//If the employee had no objectives, don't need to process this.
			continue

		if(employee.assigned_role == employee.special_role || employee.offstation_role) //If the character is an offstation character, skip them.
			continue

		text += "<br>[employee.name] на должности [employee.assigned_role]:"

		var/ambitions_completed = FALSE

		var/count = 1
		for(var/datum/ambition_objective/objective in employee.ambition_objectives)
			if(objective.completed)
				text += "<br>&nbsp;-&nbsp;<B>Амбиция №[count]</B>: [objective.description] <font color='green'><B> реализована!</B></font>"
				SSblackbox.record_feedback("nested tally", "employee_objective", 1, list("[objective.type]", "SUCCESS"))
				ambitions_completed = TRUE
			else
			//	//отключено текстовое отображение не выполненных амбиций
			//	text += "<br>&nbsp;-&nbsp;<B>Амбиция №[count]</B>: [objective.get_description()] <font color='red'><b> не осуществлена.</b></font>"
				SSblackbox.record_feedback("nested tally", "employee_objective", 1, list("[objective.type]", "FAIL"))
			count++

		if(ambitions_completed)
			text += "<br>&nbsp;<font color='green'><B>[employee.name] считает, что реализовал свои амбиции!</B></font>"
			//text += "<br>&nbsp;<font color='green'><B>[employee.name] счита[pluralize_ru(usr.gender,"ет","ют")], что реализовал[genderize_ru(usr.gender,"","а","о","и")] свои амбиции!</B></font>"
			SSblackbox.record_feedback("tally", "employee_success", 1, "SUCCESS")
		else
			SSblackbox.record_feedback("tally", "employee_success", 1, "FAIL")

	return text
