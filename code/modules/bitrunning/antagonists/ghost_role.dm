/datum/antagonist/domain_actor
	name = "Virtual Domain Actor"
	roundend_category = "Сбоями домена"
	special_role = SPECIAL_ROLE_GLITCH
	job_rank = ROLE_GLITCH
	antag_menu_name = "Защитник домена"
	show_in_roundend = FALSE
	replace_banned = FALSE

/datum/antagonist/domain_actor/on_gain()
	. = ..()
	owner.current.AddComponent(/datum/component/npc_friendly)

/datum/antagonist/domain_actor/give_objectives()
	add_objective(/datum/objective/domain_actor)

/datum/antagonist/domain_actor/greet()
	var/list/messages = list()
	messages.Add(span_fontsize3(span_red("<b>Вы — часть виртуального домена.<br></b>")))
	messages.Add(span_sinister("Домен вписал вас в свой сценарий. Битраннеры, что вломились сюда, в него не вписаны."))
	messages.Add(span_specialnotice("Вы не сможете покинуть домен: за его границами вас просто не существует."))
	messages.Add(span_specialnotice("Когда сервер выгрузит домен, вы вернётесь в тело, из которого пришли."))
	return messages

/datum/objective/domain_actor
	needs_target = FALSE
	completed = TRUE

/datum/objective/domain_actor/New(text)
	. = ..()
	if(text)
		return

	explanation_text = "Защитить домен от вторгшихся битраннеров."
