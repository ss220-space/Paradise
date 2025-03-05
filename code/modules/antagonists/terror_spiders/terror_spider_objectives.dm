/datum/objective/spider_protect
	name = "Защищать гнездо"
	needs_target = FALSE
	explanation_text = "Ошибка. Текст не сгенерирован. Напишите атикет и создайте баг репорт."

/datum/objective/spider_protect/New(text, datum/team/team_to_join)
	. = ..()
	generate_text()

/datum/objective/spider_protect/proc/generate_text(datum/team/terror_spiders/spider_team)
	var/list/possible_spiders = list()
	var/list/spiders = spider_team.main_spiders
	if(!spiders)
		return
	for(var/spiter_type in spiders)
		if(spiter_type != TERROR_OTHER && LAZYLEN(spiders[spiter_type]))
			possible_spiders += spiter_type
	explanation_text = "Помогите вашему гнезду отложить яйцо Императрицы Ужаса. Это могут сделать: [possible_spiders.Join(", ")]. Защищайте их и помогите им набрать силу, чтобы они могли отложить яйцо."

/datum/objective/spider_protect/check_completion(datum/team/terror_spiders/spider_team)
	. = ..()

	if(completed)
		return .

	if(spider_team?.infect_target?.completed || \
	spider_team?.lay_eggs_target?.completed|| \
	spider_team?.prince_target?.completed)
		completed = TRUE
		return TRUE
	return .

/datum/objective/spider_protect_egg
	name = "Защищать яйцо Императрицы"
	needs_target = FALSE
	explanation_text = "Ошибка. Текст не сгенерирован. Напишите атикет и создайте баг репорт."

/datum/objective/spider_protect_egg/New(text, datum/team/team_to_join)
	. = ..()
	generate_text()

/datum/objective/spider_protect_egg/proc/generate_text(datum/team/terror_spiders/spider_team)
	if(spider_team?.empress_egg)
		return
	explanation_text = "Защищайте яйцо Императрицы Ужаса. Оно находится в [get_area(spider_team?.empress_egg)]. Его уничтожение приведёт к гибели всего гнезда."

/datum/objective/spider_get_power
	name = "spider bug"
	needs_target = FALSE
	explanation_text = "Вы не должны этого видеть. Напишите баг репорт."
	var/targets_need = 0

/datum/objective/spider_get_power/proc/generate_text()
	generate_targets_count()
	return

/datum/objective/spider_get_power/proc/generate_targets_count()
	targets_need = EMPRESS_EGG_TARGET_COUNT
	return

/datum/objective/spider_get_power/alife_spiders
	name = "Размножаться"

/datum/objective/spider_get_power/alife_spiders/generate_text()
	. = ..()
	explanation_text = "Расплодитесь. Для того, чтобы вы могли отложить яйцо Императрицы, в вашем гнезде долж[declension_ru(targets_need, "ен", "о", "о")] быть [targets_need] паук[declension_ru(targets_need, "", "а", "ов")]."

/datum/objective/spider_get_power/alife_spiders/check_completion(datum/team/terror_spiders/spider_team)
	. = ..()

	if(completed)
		return .

	var/alife_count = spider_team?.get_terror_spiders_alife_count()

	if(alife_count >= targets_need)
		completed = TRUE
		spider_team.other_target?.check_completion()
		return TRUE
	return .

/datum/objective/spider_get_power/spider_infections
	name = "Заражать гуманоидов"

/datum/objective/spider_get_power/spider_infections/generate_text()
	. = ..()
	explanation_text = "Заражайте. Для того, чтобы вы могли отложить яйцо Императрицы, долж[declension_ru(targets_need, "ен", "о", "о")] быть заражено [targets_need] гуманоид[declension_ru(targets_need, "", "а", "ов")]."

/datum/objective/spider_get_power/spider_infections/check_completion(datum/team/terror_spiders/spider_team)
	. = ..()

	if(completed)
		return .

	if(spider_team?.terror_infections.len >= targets_need)
		completed = TRUE
		spider_team?.other_target?.check_completion()
		return TRUE
	return .


/datum/objective/spider_get_power/eat_humans
	name = "Поедать гуманоидов"

/datum/objective/spider_get_power/eat_humans/generate_text()
	. = ..()
	explanation_text = "Ешьте и набирайтесь сил. Для того, чтобы вы могли отложить яйцо Императрицы, вам нужно заплести в кокон [targets_need] гуманоид[declension_ru(targets_need, "а", "ов", "ов")]. "

/datum/objective/spider_get_power/eat_humans/check_completion(human_count, datum/team/terror_spiders/spider_team)
	. = ..()

	if(completed)
		return .

	if(human_count >= targets_need)
		completed = TRUE
		spider_team?.other_target?.check_completion()
		return TRUE
	return .
