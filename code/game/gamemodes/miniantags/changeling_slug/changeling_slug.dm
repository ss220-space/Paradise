#define EVENT_CLING_GPOINTS 13

/mob/living/simple_animal/hostile/headslug/evented
	icon_state = "headslugevent"
	icon_living = "headslugevent"
	icon_dead = "headslug_deadevent"
	evented = TRUE


/mob/living/simple_animal/hostile/headslug/evented/proc/make_slug_antag(give_default_objectives = TRUE)
	mind.assigned_role = SPECIAL_ROLE_HEADSLUG
	mind.special_role = SPECIAL_ROLE_HEADSLUG
	SSticker.mode.headslugs |= mind
	var/list/messages = list()
	messages.Add("<b><font size=3 color='red'>Мы личинка генокрада.</font><br></b>")
	messages.Add(span_changeling("Наши яйца можно отложить в любого крупного мёртвого гуманоида. Используйте <b>Alt + ЛКМ</b> на подходящем существе и стойте неподвижно в течение 5 секунд."))
	messages.Add(span_notice("Хоть эта форма и погибнет после откладки яиц, наше истинное «я» со временем возродится."))

	SEND_SOUND(src, sound('sound/vox_fem/changeling.ogg'))
	if(give_default_objectives)
		var/datum/objective/findhost = new /datum/objective // objective just for rofl
		findhost.owner = mind
		findhost.explanation_text = "Найдите труп, чтобы отложить в него яйца и начать процесс роста"
		findhost.completed = TRUE
		findhost.needs_target = FALSE
		findhost.antag_menu_name = "Найти носителя"
		mind.objectives += findhost
		messages.Add(mind.prepare_announce_objectives())
	to_chat(src, chat_box_red(messages.Join("<br>")))

/datum/antagonist/changeling/evented // make buffed changeling
	evented = TRUE
	genetic_points = EVENT_CLING_GPOINTS
	absorbed_dna = list()

/datum/antagonist/changeling/evented/on_gain()
	..()
	var/datum/action/changeling/lesserform/sluglesser = new /datum/action/changeling/lesserform // give new innate power
	sluglesser.power_type = "changeling_innate_power"
	sluglesser.dna_cost = 0
	give_power(sluglesser)
	absorbed_dna = list()

#undef EVENT_CLING_GPOINTS


