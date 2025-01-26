/datum/game_mode/proc/auto_declare_completion_morph()
	if(!length(morphs))
		return

	var/text = "<FONT size = 2><B>Морфами были:</B></FONT>"
	for(var/datum/mind/morph in morphs)
		var/traitorwin = TRUE
		text += "<br>[morph.get_display_key()] был [morph.name] ("
		if(morph.current)
			if(morph.current.stat == DEAD)
				text += "умер"
			else
				text += "жив"
		else
			text += "тело уничтожено"
		text += ")"

		var/list/all_objectives = morph.get_all_objectives()

		if(length(all_objectives))//If the traitor had no objectives, don't need to process this.
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Успех!</B></font>"
					SSblackbox.record_feedback("nested tally", "morph_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провал.</font>"
					SSblackbox.record_feedback("nested tally", "morph_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		if(traitorwin)
			text += "<br><font color='green'><B>Морф был успешен!</B></font>"
			SSblackbox.record_feedback("tally", "morph_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>Морф провалился!</B></font>"
			SSblackbox.record_feedback("tally", "morph_success", 1, "FAIL")
	to_chat(world, text)
	return TRUE

/datum/game_mode/proc/auto_declare_completion_revenant()
	if(!length(revenants))
		return

	var/text = "<FONT size = 2><B>Ревенантами были:</B></FONT>"
	for(var/datum/mind/revenant in revenants)
		var/traitorwin = TRUE
		text += "<br>[revenant.get_display_key()] был [revenant.name] ("
		if(revenant.current)
			if(revenant.current.stat == DEAD)
				text += "умер"
			else
				text += "жив"
		else
			text += "тело уничтожено"
		text += ")"

		var/list/all_objectives = revenant.get_all_objectives()

		if(length(all_objectives))
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Успех!</B></font>"
					SSblackbox.record_feedback("nested tally", "revenant_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провал.</font>"
					SSblackbox.record_feedback("nested tally", "revenant_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		if(traitorwin)
			text += "<br><font color='green'><B>Ревенант был успешен!</B></font>"
			SSblackbox.record_feedback("tally", "revenant_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>Ревенант провалился!</B></font>"
			SSblackbox.record_feedback("tally", "revenant_success", 1, "FAIL")
	to_chat(world, text)
	return TRUE

/datum/game_mode/proc/auto_declare_completion_honksquad()
	if(!length(honksquad))
		return

	var/text = "<FONT size = 2><B>Членами Хонксквада были:</B></FONT>"
	for(var/datum/mind/honker in honksquad)
		var/traitorwin = TRUE
		text += "<br>[honker.get_display_key()] был [honker.name] ("
		if(honker.current)
			if(honker.current.stat == DEAD)
				text += "умер"
				traitorwin = FALSE
			else
				text += "жив"
		else
			text += "тело уничтожено"
			traitorwin = FALSE
		text += ")"

		var/list/all_objectives = honker.get_all_objectives()

		if(length(all_objectives))
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Успех!</B></font>"
					SSblackbox.record_feedback("nested tally", "honksquad_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провал.</font>"
					SSblackbox.record_feedback("nested tally", "honksquad_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		if(traitorwin)
			text += "<br><font color='green'><B>Член Хонксквада был успешен!</B></font>"
			SSblackbox.record_feedback("tally", "honksquad_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>Член Хонксквада провалился!</B></font>"
			SSblackbox.record_feedback("tally", "honksquad_success", 1, "FAIL")
	to_chat(world, text)
	return TRUE

/datum/game_mode/proc/auto_declare_completion_deathsquad()
	if(!length(deathsquad))
		return

	var/text = "<FONT size = 2><B>Бойцами Отряда Смерти были:</B></FONT>"
	for(var/datum/mind/commando in deathsquad)
		var/traitorwin = TRUE
		text += "<br>[commando.get_display_key()] был [commando.name] ("
		if(commando.current)
			if(commando.current.stat == DEAD)
				text += "умер"
				traitorwin = FALSE
			else
				text += "жив"
		else
			text += "тело уничтожено"
			traitorwin = FALSE
		text += ")"

		var/list/all_objectives = commando.get_all_objectives()

		if(length(all_objectives))
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Успех!</B></font>"
					SSblackbox.record_feedback("nested tally", "deathsquad_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провал.</font>"
					SSblackbox.record_feedback("nested tally", "deathsquad_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		if(traitorwin)
			text += "<br><font color='green'><B>Боец Отряда Смерти был успешен!</B></font>"
			SSblackbox.record_feedback("tally", "deathsquad_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>Боец Отряда Смерти провалился!</B></font>"
			SSblackbox.record_feedback("tally", "deathsquad_success", 1, "FAIL")
	to_chat(world, text)
	return TRUE

/datum/game_mode/proc/auto_declare_completion_sst()
	if(!length(sst))
		return

	var/text = "<FONT size = 2><B>Бойцами Ударного Отряда Синдиката были:</B></FONT>"
	for(var/datum/mind/commando in sst)
		var/traitorwin = TRUE
		text += "<br>[commando.get_display_key()] был [commando.name] ("
		if(commando.current)
			if(commando.current.stat == DEAD)
				text += "умер"
				traitorwin = FALSE
			else
				text += "жив"
		else
			text += "тело уничтожено"
			traitorwin = FALSE
		text += ")"

		var/list/all_objectives = commando.get_all_objectives()

		if(length(all_objectives))
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Успех!</B></font>"
					SSblackbox.record_feedback("nested tally", "sst_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провал.</font>"
					SSblackbox.record_feedback("nested tally", "sst_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		if(traitorwin)
			text += "<br><font color='green'><B>Боец Ударного Отряда Синдиката успешен!</B></font>"
			SSblackbox.record_feedback("tally", "sst_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>Боец Ударного Отряда Синдиката провалился!</B></font>"
			SSblackbox.record_feedback("tally", "sst_success", 1, "FAIL")
	to_chat(world, text)
	return TRUE

/datum/game_mode/proc/auto_declare_completion_sit()
	if(!length(sit))
		return

	var/text = "<FONT size = 2><B>Агентами Диверсионного Отряда Синдиката были:</B></FONT>"
	for(var/datum/mind/commando in sit)
		var/traitorwin = TRUE
		text += "<br>[commando.get_display_key()] был [commando.name] ("
		if(commando.current)
			if(commando.current.stat == DEAD)
				text += "умер"
				traitorwin = FALSE
			else
				text += "жив"
		else
			text += "тело уничтожено"
			traitorwin = FALSE
		text += ")"

		var/list/all_objectives = commando.get_all_objectives()

		if(length(all_objectives))
			var/count = 1
			for(var/datum/objective/objective in all_objectives)
				if(objective.check_completion())
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='green'><B>Успех!</B></font>"
					SSblackbox.record_feedback("nested tally", "sit_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Цель #[count]</B>: [objective.explanation_text] <font color='red'>Провал.</font>"
					SSblackbox.record_feedback("nested tally", "sit_objective", 1, list("[objective.type]", "FAIL"))
					traitorwin = FALSE
				count++

		if(traitorwin)
			text += "<br><font color='green'><B>Агент Диверсионного Отряда Синдиката был успешен!</B></font>"
			SSblackbox.record_feedback("tally", "sit_success", 1, "SUCCESS")
		else
			text += "<br><font color='red'><B>Агент Диверсионного Отряда Синдиката провалился!</B></font>"
			SSblackbox.record_feedback("tally", "sit_success", 1, "FAIL")
	to_chat(world, text)
	return TRUE
