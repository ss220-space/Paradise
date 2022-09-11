/datum/mind/var/list/ambition_objectives = list()

/datum/ambition_objective
	var/datum/mind/owner = null			//владелец амбиции
	var/completed = 0					//завершение амбиции для конца раунда
	var/description = "Пустая амбиция ((перешлите это разработчику))"
	var/chance_generic_ambition = 40	//шанс выпадения ОБЩЕЙ амбиции
	var/chance_other_departament_ambition = 30	//шанс выпадения амбиции чужого департамента
	var/list/choose_list = list()		//список повторов рандома у амбиции

/datum/ambition_objective/New(var/datum/mind/new_owner)
	owner = new_owner
	owner.ambition_objectives += src

/datum/ambition_objective/proc/get_random_ambition()
	var/result

	//Шанс выпадения общей амбиции или амбиции отдела
	if(prob(chance_generic_ambition))
		result = pick_list("ambition_objectives_generic.json", "Common")
	else
		result = get_job_departament_ambition()
		if (!result)
			result = pick_list("ambition_objectives_generic.json", "Common")

	return ambition_code(result)

/datum/ambition_objective/proc/get_job_departament_ambition()
	var/result

	//Шанс выпадения общей роли из отдела
	var/job = owner.assigned_role
	if(prob(chance_generic_ambition))
		job = "Common"

	//Проверяем работы не в позициях и вынесенные в отдельный файл
	switch(owner.assigned_role)
		if("Magistrate", "Internal Affairs Agent")
			if("Magistrate" && (prob(chance_other_departament_ambition))) //шанс что магистрат возьмёт общую амбицию глав.
				result = pick_list("ambition_objectives_command.json", "Common")
				if (!result)
					return result
			result = pick_list("ambition_objectives_law.json", job)
			if (!result)
				return result

		if("Nanotrasen Representative", "Blueshield")
			if("Nanotrasen Representative" && (prob(chance_other_departament_ambition))) //шанс что НТР возьмёт общую амбицию закона.
				result = pick_list("ambition_objectives_law.json", "Common")
				if (!result)
					return result
			result = pick_list("ambition_objectives_representative.json", job)
			if (!result)
				return result

	//Сначала выдаем амбиции силиконам, чтобы они не получили общих амбиций
	if(owner.assigned_role in GLOB.nonhuman_positions)
		result = pick_list("ambition_objectives_nonhuman.json", owner.assigned_role)
		return result

	//Проверяем работы вынесенные в позиции
	if(owner.assigned_role in GLOB.civilian_positions)
		result = pick_list("ambition_objectives_generic.json", job)
		return result

	if(owner.assigned_role in GLOB.command_positions)
		//шанс получить за главу работу одного из своих отделов
		if (prob(chance_other_departament_ambition))
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

	var/list/non_support_roles = list("Magistrate", "Internal Affairs Agent", "Blueshield", "Nanotrasen Representative")
	if(owner.assigned_role in (GLOB.support_positions - GLOB.supply_positions - non_support_roles))
		result = pick_list("ambition_objectives_support.json", job)
		return result

	if(owner.assigned_role in GLOB.engineering_positions)
		result = pick_list("ambition_objectives_engineering.json", job)
		return result

	if(owner.assigned_role in GLOB.medical_positions)
		result = pick_list("ambition_objectives_medical.json", job)
		return result

	if(owner.assigned_role in GLOB.science_positions)
		result = pick_list("ambition_objectives_science.json", job)
		return result

	if(owner.assigned_role in GLOB.supply_positions)
		result = pick_list("ambition_objectives_supply.json", job)
		return result

	if(owner.assigned_role in (GLOB.security_positions - GLOB.support_positions))
		if("Brig Physician" && (prob(chance_other_departament_ambition)))	//шанс что бригмедик возьмёт амбицию мед. отдела.
			job = pick(GLOB.medical_positions)
			result = pick_list("ambition_objectives_medical.json", job)
			return result
		result = pick_list("ambition_objectives_security.json", job)
		return result

	return result

/datum/ambition_objective/proc/ambition_code(var/text)
	choose_list = list()

	var/list/random_codes = list(
		"random_crew",
		"random_departament",
		"random_departament_crew",
		"random_pet",
		"random_food",
		"random_drink",
		"random_holiday"
	)

	var/list/items = splittext(text, "\[")
	text = ""
	for(var/item in items)
		for (var/code in random_codes)
			item = replacetextEx_char(item, "[code]\]", random_choose(code))
		text += item

	return uppertext(copytext_char(text, 1, 2)) + copytext_char(text, 2)	//переводим первым символ в верхний регистр

//выдача рандома, проверка на повторы
/datum/ambition_objective/proc/random_choose(var/list_for_pick)
	if (list_for_pick == "random_crew")
		return random_player()

	var/picked = pick_list("ambition_randoms.json", list_for_pick)

	//избавляемся от повтора
	while(picked in choose_list)
		picked = pick_list("ambition_randoms.json", list_for_pick)

	choose_list.Add(picked)
	return picked

/datum/ambition_objective/proc/random_player()
	var/list/players = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(	!player.mind || player.mind.assigned_role == player.mind.special_role || player.client.inactivity > 10 MINUTES)
			continue
		players += player.real_name
	var/random_player = "Капитан"
	if(players.len)
		random_player = pick(players)
	return random_player

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
			SSblackbox.record_feedback("tally", "employee_success", 1, "SUCCESS")
		else
			SSblackbox.record_feedback("tally", "employee_success", 1, "FAIL")

	return text
