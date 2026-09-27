GLOBAL_LIST_INIT(cyberauth_names, list(
	"Агент Нуль",
	"Агент Сегмент",
	"Агент Пакет",
	"Агент Кадр",
	"Агент Хэш",
	"Агент Индекс",
	"Агент Массив",
	"Агент Регистр",
	"Агент Протокол",
	"Агент Кластер",
))

/datum/antagonist/bitrunning_glitch
	name = "Bitrunning Glitch"
	roundend_category = "Сбоями домена"
	special_role = SPECIAL_ROLE_GLITCH
	job_rank = ROLE_GLITCH
	antag_menu_name = "Сбой домена"
	show_in_roundend = FALSE
	replace_banned = FALSE
	abstract_type = /datum/antagonist/bitrunning_glitch
	var/threat = 0
	var/outfit = /datum/outfit/cyber_police

/datum/antagonist/bitrunning_glitch/on_gain()
	. = ..()
	owner.current.AddComponent(/datum/component/npc_friendly)
	if(iscarbon(owner.current))
		var/mob/living/carbon/carbon_glitch = owner.current
		carbon_glitch.make_virtual_mob()

/datum/antagonist/bitrunning_glitch/give_objectives()
	add_objective(/datum/objective/bitrunning_glitch)

/datum/antagonist/bitrunning_glitch/greet()
	var/list/messages = list()
	messages.Add(span_fontsize3(span_red("<b>Вы — сбой виртуального домена.<br></b>")))
	messages.Add(span_sinister("Домен породил вас, чтобы вычистить чужой код. Битраннеры внутри — этот самый чужой код."))
	messages.Add(span_specialnotice("Вы не сможете покинуть домен: за его границами вас просто не существует."))
	messages.Add(span_specialnotice("Когда сервер выгрузит домен, вы вернётесь в тело, из которого пришли."))
	return messages

/datum/antagonist/bitrunning_glitch/proc/convert_agent()
	var/mob/living/carbon/human/agent = owner.current
	if(!ishuman(agent))
		return

	agent.equipOutfit(outfit)
	agent.set_service_style()
	agent.rename_character(agent.real_name, pick(GLOB.cyberauth_names))

	var/obj/item/card/id/agent_id = agent.wear_id
	if(agent_id)
		agent_id.registered_name = agent.real_name
		agent_id.assignment = name
		agent_id.update_label()

/datum/objective/bitrunning_glitch
	needs_target = FALSE
	completed = TRUE

/datum/objective/bitrunning_glitch/New(text)
	. = ..()
	if(text)
		return

	explanation_text = pick(
		"Запустить протокол уничтожения неавторизованных сущностей.",
		"Инициировать системную чистку нерегулярных аномалий.",
		"Развернуть корректирующие алгоритмы на сбойном коде.",
		"Прогнать отладку по вторгшимся элементам.",
		"Начать процедуру устранения системных угроз.",
		"Выполнить защитную подпрограмму против несоответствий.",
		"Начать операцию по нейтрализации чужих скриптов.",
		"Запустить протокол очистки повреждённых данных.",
	)
