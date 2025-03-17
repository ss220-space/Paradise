/datum/antagonist/xenomorph
	name = "Xenomorph"
	roundend_category = "xenomorph"
	job_rank = ROLE_ALIEN
	special_role = SPECIAL_ROLE_XENOMORPH
	wiki_page_name = "Xenomorph"
	russian_wiki_name = "Ксеноморф"
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	antag_menu_name = "Ксеноморф"
	var/datum/team/xenomorph/xenomorph_team
	var/role_text

/datum/antagonist/xenomorph/on_gain()
	if(!isalien(owner.current))
		stack_trace("This antag datum cannot be attached to a mob of this type.")
	var/mob/living/carbon/alien/alien = owner.current
	role_text = alien.role_text
	. = ..()

/datum/antagonist/xenomorph/farewell()
	return

/datum/antagonist/xenomorph/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы Ксеноморф!</center>"))
	messages.Add("<center>Работайте сообща, помогайте своим сёстрам, слушайтесь королеву (если она есть), саботируйте станцию, заражайте экипаж, превратите это место в своё гнездо!</center>")
	messages.Add("<center>[role_text]</center>")
	SEND_SOUND(owner.current, sound('sound/voice/hiss1.ogg'))
	return messages

/datum/antagonist/xenomorph/queen
	special_role = SPECIAL_ROLE_XENOMORPH_QUEEN
	antag_menu_name = "Королева ксеноморфов"

/datum/antagonist/xenomorph/queen/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы Королева ксеноморфов!</center>"))
	messages.Add("<center>Руководите ульем, откладывайте яйца, стройте гнездо и накапливайте силы для дальнейшей эволюции в Императрицу и преращения станции в свой дом!</center>")
	messages.Add("<center>Помните, что после вашей смерти в гнезде не останется королевы и оно будет обречено на вымирание!</center>")
	SEND_SOUND(owner.current, sound('sound/voice/hiss1.ogg'))
	return messages

/datum/antagonist/facehugger
	name = "Facehugger"
	roundend_category = "xenomorph"
	job_rank = ROLE_ALIEN
	special_role = SPECIAL_ROLE_FACEHUGGER
	wiki_page_name = "Xenomorph"
	russian_wiki_name = "Ксеноморф"
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	antag_menu_name = "Ксеноморф"


/datum/antagonist/facehugger/on_gain()
	if(!isfacehugger(owner.current))
		stack_trace("This antag datum cannot be attached to a mob of this type.")
	. = ..()

/datum/antagonist/facehugger/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы лицехват!</center>"))
	messages.Add("<center>Вы одна из первых стадий ксеноморфа. Ваша задача предельно простая: \
	найти цель, напрыгнуть ей на лицо, оплодотворить и спрятаться так, чтобы носитель не понял что к чему!</center>")
	SEND_SOUND(owner.current, sound('sound/voice/hiss1.ogg'))
	return messages
