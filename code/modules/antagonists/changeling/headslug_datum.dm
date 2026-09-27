/datum/antagonist/headslug
	name = "Headslug"
	roundend_category = "Личинками генокрада"
	show_in_roundend = FALSE
	job_rank = ROLE_CHANGELING
	special_role = SPECIAL_ROLE_HEADSLUG
	antag_menu_name = "Личинка генокрада"
	stinger_sound = 'sound/vox_fem/changeling.ogg'

/datum/antagonist/headslug/give_objectives()
	add_objective(/datum/objective/find_host)

/datum/antagonist/headslug/greet()
	var/list/messages = list()
	messages.Add("<b><font size=3 color='red'>Мы личинка генокрада.</font><br></b>")
	messages.Add(span_changeling("Наши яйца можно отложить в любого крупного мёртвого гуманоида. Используйте <b>Alt + ЛКМ</b> на подходящем существе и стойте неподвижно в течение 5 секунд."))
	messages.Add(span_notice("Хоть эта форма и погибнет после откладки яиц, наше истинное «я» со временем возродится."))
	return messages


/datum/objective/find_host
	explanation_text = "Найдите труп, чтобы отложить в него яйца и начать процесс роста"
	completed = TRUE
	needs_target = FALSE
	antag_menu_name = "Найти носителя"
