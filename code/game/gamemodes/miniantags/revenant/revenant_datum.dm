/datum/antagonist/revenant
	name = "Revenant"
	roundend_category = "revenants"
	show_in_roundend = TRUE
	job_rank = SPECIAL_ROLE_REVENANT
	special_role = SPECIAL_ROLE_REVENANT
	wiki_page_name = "Revenant"
	russian_wiki_name = "Ревенант"
	show_in_orbit = TRUE
	antag_menu_name = "Ревенант"

/datum/antagonist/revenant/give_objectives()
	. = ..()
	add_objective(/datum/objective/revenant)
	add_objective(/datum/objective/revenantFluff)

/datum/antagonist/revenant/greet()
	var/list/messages = list()
	SEND_SOUND(owner.current, sound('sound/effects/ghost.ogg'))
	messages.Add(span_deadsay(span_fontsize3(span_bold("Вы — ревенант."))))
	messages.Add("<b>Ваш некогда обычный дух был наполнен чужеродной энергией и превращён в ревенанта.</b>")
	messages.Add("<b>Вы не мёртвы, не живы, а где-то посередине. Вы способны на ограниченное взаимодействие с обоими мирами.</b>")
	messages.Add("<b>Вы неуязвимы и невидимы для всех, кроме других призраков. Большинство способностей раскроют вас, сделав уязвимым.</b>")
	messages.Add("<b>Чтобы существовать, вы должны высасывать жизненную эссенцию из людей. Эта эссенции — ваш ресурс и здоровье, она питает все ваши способности.</b>")
	messages.Add("<b><i>Вы не помните ничего из своих прошлых жизней, а также не будете помнить ничего из этой после своей смерти.</i></b>")
	return messages
