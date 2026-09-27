/datum/antagonist/guardian
	name = "Guardian"
	roundend_category = "Голопаразитами"
	show_in_roundend = FALSE
	job_rank = ROLE_GUARDIAN
	special_role = SPECIAL_ROLE_GUARDIAN
	antag_menu_name = "Голопаразит"
	give_objectives = FALSE
	replace_banned = FALSE
	var/mob_name = "Страж"

/datum/antagonist/guardian/greet()
	var/mob/living/simple_animal/hostile/guardian/guardian = owner.current
	var/mob/living/summoner = guardian.summoner
	var/list/messages = list()
	messages.Add("Вы [mob_name], обязанный служить [summoner.real_name].")
	messages.Add("Вы можете появляться или возвращаться к вашему хозяину с помощью кнопок на панели Стража. Там же вы найдете кнопку связи с хозяином.")
	messages.Add("Хотя вы лично неуязвимы, ваша жизнь зависит от [summoner.real_name]. Если [GEND_HE_SHE(summoner)] погибн[PLUR_ET_UT(summoner)] — умрёте и вы. Кроме того, любой полученный вами урон будет передан [GEND_HIM_HER(summoner)], так как вы существуете за счёт [GEND_HIS_HER(summoner)] жизненной силы.")
	messages.Add(guardian.playstyle_string)
	return messages
