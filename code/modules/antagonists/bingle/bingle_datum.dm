/datum/antagonist/bingle
	name = "Bingle"
	roundend_category = "bingles"
	job_rank = ROLE_BINGLE
	special_role = SPECIAL_ROLE_BINGLE
	antag_hud_name = "hudbingle"
	wiki_page_name = "Bingle"
	russian_wiki_name = "Бингл"
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	antag_menu_name = "Бингл"

/datum/antagonist/bingle/on_gain()
	if(!isbingle(owner.current))
		stack_trace("This antag datum cannot be attached to a mob of this type.")
	return ..()

/datum/antagonist/bingle/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы — Бингл!</center>"))
	messages.Add("<center>Работайте сообща, помогайте своим братьям, разбирайте станцию, тащите экипаж в яму, сделайте из этой станции одну большую дыру!</center>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/bingle.ogg'))
	return messages

/datum/antagonist/bingle/lord
	name = "Bingle Lord"
	special_role = SPECIAL_ROLE_BINGLE_LORD
	antag_menu_name = "Лорд Бинглов"
	show_in_roundend = TRUE
	/// Lord objective
	var/datum/objective/bingle_lord/lord_objective

/datum/antagonist/bingle/lord/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы — Лорд Бинглов!</center>"))
	messages.Add("<center>Вашей обязательной целью является создание ямы в месте, где вы сможете быстро собрать много вещей.</center>")
	messages.Add("<center>После создания ямы постарайтесь накормить яму до создания хотя-бы пары бинглов.</center>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/bingle.ogg'))
	return messages

/datum/antagonist/bingle/lord/give_objectives()
	lord_objective = new(team_to_join = team)
	add_objective(lord_objective)
