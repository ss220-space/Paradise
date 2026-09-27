/datum/antagonist/ert
	name = "Emergency Response Officer"
	roundend_category = "Бойцами Отряда Быстрого Реагирования"
	show_in_roundend = FALSE
	job_rank = ROLE_ERT
	special_role = SPECIAL_ROLE_ERT
	antag_menu_name = "Боец ОБР"
	give_objectives = FALSE
	replace_banned = FALSE
	show_in_orbit = FALSE
	var/mission
	var/nuke_code
	var/leader = FALSE
	var/offstation_squad = FALSE
	var/greet_name = "боец Отряда Быстрого Реагирования"
	var/leader_greet_name = "<b>КОМАНДИР</b> Отряда Быстрого Реагирования"

/datum/antagonist/ert/on_gain()
	. = ..()
	if(nuke_code)
		antag_memory += "<b>Коды от боеголовки:</b> [span_warning("[nuke_code].")]<br>"
	if(mission)
		antag_memory += "<b>Миссия:</b> [span_warning("[mission].")]<br>"

/datum/antagonist/ert/apply_innate_effects(mob/living/mob_override)
	. = ..()
	if(offstation_squad)
		owner.offstation_role = TRUE

/datum/antagonist/ert/remove_innate_effects(mob/living/mob_override)
	. = ..()
	if(offstation_squad)
		owner.offstation_role = FALSE

/datum/antagonist/ert/greet()
	var/list/messages = list()
	messages.Add(span_notice("Вы [leader ? leader_greet_name : greet_name]!"))
	messages.Add(additional_messages())
	if(mission)
		messages.Add(span_notice("Ваша миссия: [span_danger(mission)]"))
	return messages

/datum/antagonist/ert/proc/additional_messages()
	return list()

/datum/antagonist/ert/check_anatag_menu_ability()
	return special_role != SPECIAL_ROLE_ERT


/datum/antagonist/ert/deathsquad
	name = "Death Commando"
	roundend_category = "Бойцами Отряда Смерти"
	show_in_roundend = TRUE
	roundend_blackbox_key = "deathsquad"
	roundend_death_is_failure = TRUE
	job_rank = ROLE_DEATHSQUAD
	special_role = SPECIAL_ROLE_DEATHSQUAD
	antag_menu_name = "Боец Отряда Смерти"
	show_in_orbit = TRUE
	offstation_squad = TRUE
	greet_name = "боец отряда Специальных Операций, подчиняющийся Центральному Командованию"
	leader_greet_name = "<b>КОМАНДИР</b> отряда Специальных Операций, подчиняющийся Центральному Командованию"

/datum/antagonist/ert/deathsquad/cyborg
	name = "Death Commando Cyborg"
	greet_name = "борг отдела Специальных Операций, подчиняющийся Центральному Командованию"


/datum/antagonist/ert/honksquad
	name = "Honksquad Member"
	roundend_category = "Членами Хонксквада"
	show_in_roundend = TRUE
	roundend_blackbox_key = "honksquad"
	roundend_death_is_failure = TRUE
	special_role = SPECIAL_ROLE_HONKSQUAD
	antag_menu_name = "Член Хонксквада"
	show_in_orbit = TRUE
	offstation_squad = TRUE
	greet_name = "член ХОНКсквада в подчинении Планеты Клоунов"
	leader_greet_name = "<b>ЛИДЕР</b> ХОНКсквада в подчинении Планеты Клоунов"

/datum/antagonist/ert/honksquad/additional_messages()
	return list(span_notice("Вас вызывают в случае крайне низкого уровня ХОНКа на объекте. Вы НЕ имеете права убивать."))


/datum/antagonist/ert/syndicate_commando
	name = "Syndicate Commando"
	roundend_category = "Бойцами Ударного Отряда \"Синдиката\""
	show_in_roundend = TRUE
	roundend_blackbox_key = "sst"
	roundend_death_is_failure = TRUE
	special_role = SPECIAL_ROLE_SYNDICATE_DEATHSQUAD
	antag_menu_name = "Боец SST"
	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "hudoperative"
	show_in_orbit = TRUE
	offstation_squad = TRUE
	greet_name = "боец Элитного Отряда в подчинении \"Синдиката\""
	leader_greet_name = "<b>Лидер</b> Элитного Отряда в подчинении \"Синдиката\""

/datum/antagonist/ert/syndicate_commando/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction |= "syndicate"

/datum/antagonist/ert/syndicate_commando/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction -= "syndicate"


/datum/antagonist/ert/syndicate_commando/infiltrator
	name = "Syndicate Infiltrator"
	roundend_category = "Агентами Диверсионного Отряда \"Синдиката\""
	roundend_blackbox_key = "sit"
	special_role = SPECIAL_ROLE_SYNDICATE_INFILTRATOR
	antag_menu_name = "Агент SIT"
	greet_name = "Диверсант в подчинении \"Синдиката\""
	leader_greet_name = "<b>Командир Диверсантов</b> в подчинении \"Синдиката\""
	var/team_leader

/datum/antagonist/ert/syndicate_commando/infiltrator/on_gain()
	. = ..()
	antag_memory += "<b>Лидер:</b> [team_leader]<br>"
	antag_memory += "<b>Стартовое снаряжение:</b> <br>- Наушник \"Синдиката\" ((:t для вашего канала))<br>- Хамелион-комбинезон ((правый щелчок мыши для смены цвета))<br> - ID карта агента ((Может изменять должность и другие данные))<br> - Имплант аплинка ((в левом верхнем углу экрана)) <br> - Имплант распыления ((превращает тело при смерти в пыль)) <br> - Боевые перчатки ((изолированы, замаскированны под черные перчатки)) <br> - Все, что куплено с помощью вашего импланта аплинка"

/datum/antagonist/ert/syndicate_commando/infiltrator/additional_messages()
	var/list/messages = list()
	messages.Add(span_notice("Вы оснащены имплантом аплинка, который поможет вам достичь ваших целей. ((активируйте его с помощью кнопки в левом верхнем углу экрана))"))
	if(leader)
		messages.Add(span_danger("Как лидер отряда, вы должны организовать его! Отдайте роль кому-нибудь другому, если вы не можете с ней справиться."))
	else
		messages.Add(span_danger("Лидер отряда: [team_leader]. Он отвечает за миссию!"))
	messages.Add(span_notice("В ваших заметках хранится ещё больше полезной информации."))
	return messages
