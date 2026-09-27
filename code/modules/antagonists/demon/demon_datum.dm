/datum/antagonist/demon
	name = "Demon"
	roundend_category = "Демонами"
	roundend_blackbox_key = "demon"
	job_rank = ROLE_DEMON
	special_role = SPECIAL_ROLE_DEMON
	antag_menu_name = "Демон"
	stinger_sound = 'sound/misc/demon_dies.ogg'
	var/datum/mind/summoner
	var/objective_verb = "Kill"

/datum/antagonist/demon/Destroy(force)
	summoner = null
	return ..()

/datum/antagonist/demon/give_objectives()
	if(!summoner)
		return
	add_objective(/datum/objective/assassinate, "[objective_verb] [summoner.current.real_name], the one who was foolish enough to summon you.", summoner)
	add_objective(/datum/objective/demon_rampage, "[objective_verb] everyone else while you're at it.")

/datum/antagonist/demon/greet()
	var/mob/living/simple_animal/demon/demon = owner.current
	if(!istype(demon))
		return list()
	return list(demon.playstyle_string)


/datum/antagonist/demon/slaughter
	name = "Slaughter Demon"
	antag_menu_name = "Демон резни"
	wiki_page_name = "Slaughter_Demon"
	russian_wiki_name = "Демон резни"

/datum/antagonist/demon/slaughter/give_objectives()
	if(summoner)
		return ..()
	add_objective(/datum/objective/slaughter)
	add_objective(/datum/objective/demonFluff)

/datum/antagonist/demon/slaughter/greet()
	var/list/messages = ..()
	messages.Add(span_notice("<b>Сейчас вы находитесь в ином измерении, отличном от станции. Используйте способность \"Кровавый путь\" на луже крови, чтобы проявиться.</b>"))
	return messages


/datum/antagonist/demon/slaughter/cult
	name = "Harbinger of the Slaughter"
	special_role = SPECIAL_ROLE_SLAUGHTER_HARBINGER
	antag_menu_name = "Вестник Резни"

/datum/antagonist/demon/slaughter/cult/give_objectives()
	add_objective(/datum/objective/demon_rampage, "Устройте Резню неверующим!")

/datum/antagonist/demon/slaughter/cult/finalize_antag()
	var/mob/living/simple_animal/demon/slaughter/cult/demon = owner.current
	demon.AddSpell(new /datum/action/cooldown/spell/sense_victims)


/datum/antagonist/demon/shadow
	name = "Shadow Demon"
	antag_menu_name = "Теневой демон"
	wiki_page_name = "Shadow_Demon"
	russian_wiki_name = "Теневой демон"

/datum/antagonist/demon/shadow/give_objectives()
	if(summoner)
		return ..()
	add_objective(/datum/objective/wrap)
	add_objective(/datum/objective/survive)

/datum/antagonist/demon/shadow/greet()
	var/list/messages = list()
	messages.Add(span_fontsize3(span_red("Вы — Теневой Демон.<br></b>")))
	messages.Add("<b>Вы — ужасное существо из иного измерения. У вас две цели: выжить и поджидать неосторожную добычу.</b>")
	messages.Add("<b>Вы можете использовать способность \"Теневой Путь\" рядом с тёмными участками, появляясь и исчезая на станции по своему желанию.</b>")
	messages.Add("<b>Ваша способность \"Теневой Захват\" позволяет вам притягивать живую добычу или притягиваться к объектам. Также она гасит все источники света в зоне удара.</b>")
	messages.Add("<b>Вы можете оборачивать мёртвые гуманоидные тела, атакуя их. Используйте Alt+ЛКМ на теневом коконе, чтобы заманить больше жертв.</b>")
	messages.Add("<b>Вы быстро двигаетесь и восстанавливаетесь в тенях, но любой источник света причиняет вам боль и может убить. ДЕРЖИТЕСЬ ПОДАЛЬШЕ ОТ СВЕТА!</b>")
	messages.Add(span_notice("<b>Сейчас вы находитесь в ином измерении, отличном от станции. Используйте способность \"Теневой Путь\" рядом с тёмным участком.</b>"))
	return messages


/datum/antagonist/demon/pulse
	name = "Pulse Demon"
	antag_menu_name = "Электродемон"
	wiki_page_name = "Pulse_Demon"
	russian_wiki_name = "Электродемон"
	greet_box_class = "yellow_box"
	stinger_sound = null

/datum/antagonist/demon/pulse/give_objectives()
	if(summoner)
		return ..()
	add_objective(/datum/objective/pulse_demon/infest)
	add_objective(/datum/objective/pulse_demon/drain)
	add_objective(/datum/objective/pulse_demon/tamper)

/datum/antagonist/demon/pulse/greet()
	var/list/messages = list()
	messages.Add(span_warningbig("<b>You are a pulse demon.</b></font>"))
	messages.Add(span_clock("<b>A being made of pure electrical energy, you travel through the station's wires and infest machinery.</b>"))
	messages.Add(span_clock("<b>Navigate the station's power cables to find power sources to steal from, and hijack APCs to interact with their connected machines.</b>"))
	messages.Add(span_clock("<b>If the wire or power source you're connected to runs out of power you'll start losing health and eventually die, but you are otherwise immune to damage.</b>"))
	return messages


/datum/objective/demon_rampage
	needs_target = FALSE
	completed = TRUE
	antag_menu_name = "Устроить резню"
