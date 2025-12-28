/datum/antagonist/krampus
	name = "Krampus"
	roundend_category = "devils"
	antag_menu_name = "Крампус"
	job_rank = ROLE_KRAMPUS
	special_role = ROLE_KRAMPUS
	antag_hud_type = ANTAG_HUD_DEVIL
	antag_hud_name = "huddevil"

/datum/antagonist/krampus/greet()
	var/list/messages = list()
	LAZYADD(messages, span_warning("<b>Вы — крампус, рождественский чёрт, злой спутник санты.\n\
		Вы прибыли сюда, чтобы наказать людишек, которые плохо себя вели.\n\
		Избейти их до невозможности сопротивляться и положите в мешок.</b>"))
	LAZYADD(messages, "Не забудьте оставить после себя уголь, достав его из мешка.")
	LAZYADD(messages, span_warning("Вы можете свободно наказывать тех, кто мешает вам в вашей миссии, однако не стоит пихать их в мешок. Он для особо провинившихся."))
	return messages

/datum/antagonist/krampus/give_objectives()
	for(var/i in 1 to 5)
		add_objective(/datum/objective/punish)
