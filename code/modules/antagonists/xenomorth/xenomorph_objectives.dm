/datum/objective/xeno_get_power
	name = "Размножаться"
	needs_target = FALSE
	explanation_text = "Вы не должны этого видеть. Напишите баг репорт."
	var/targets_need = 0

/datum/objective/xeno_get_power/proc/generate_text()
	targets_need = EMPRESS_EVOLVE_TARGET_COUNT
	explanation_text = "Расплодитесь. Для того, чтобы вы могли эволюционировать, в вашем улье долж[declension_ru(targets_need, "ен", "но", "но")] быть [targets_need] ксеноморф[declension_ru(targets_need, "", "а", "ов")]."
	return

/datum/objective/xeno_get_power/check_completion(datum/team/xenomorph/xeno_team)
	. = ..()

	if(completed)
		return .

	var/alife_count = xeno_team?.members.len - xeno_team?.facehuggers.len

	if(alife_count >= targets_need)
		completed = TRUE
		return TRUE
	return .

/datum/objective/create_queen
	name = "Создать Королеву"
	needs_target = FALSE
	explanation_text = "У улья должна появиться Королева. Для этого один из грудоломов должен эволюционировать сначала в Рабочего, а затем в Королеву."

/datum/objective/protect_queen
	name = "Защитить"
	needs_target = FALSE
	explanation_text = "У улья появилась Королева. Необходимо защищать её любой ценой. Помимо этого, необходимо увеличить численность улья. Чем больше улей, тем быстрее Королева сможет эволюционировать в Императрицу."

/datum/objective/protect_cocon
	name = "Защитить кокон"
	needs_target = FALSE
	explanation_text = "ОШИБКА "

/datum/objective/protect_cocon/proc/generate_text(area/location)
	explanation_text = "Королева начала эволюционировать в [location.name]. Она находится в стазисе внутри кокона и полностью беззащитна. Защитите её любой ценой."
	return
