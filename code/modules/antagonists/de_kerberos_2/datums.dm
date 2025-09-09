/datum/antagonist/battle/team1
	name = "Зеленые"
	special_role = JOB_TITLE_TEAM1
	show_in_roundend = FALSE
	show_in_orbit = TRUE
	antag_menu_name = "Зеленые"
	antag_hud_name = "team1"
	antag_hud_type = ANTAG_HUD_TEAM_1

/datum/antagonist/battle/greet()

	var/list/messages = list()
	messages.Add(span_danger("<center>Вы член команды [name]!</center>"))
	messages.Add("<center>Ваша задача: заполучить доступ к консоли связи, вызвать шаттл и эвакуироваться, не дав эвакуироваться остальным командам.</center>")
	messages.Add("<center>В скором времени на станцию будет отправлены охраняемые капсулы с особо ценным снаряжением, которое может очень сильно вам помочь в вашей миссии.</center>")
	messages.Add("<center>Спустя еще некоторое время станция будет уничтожена ядерной ракетой. Поторопитесь, если не хотите стать горстью пепла.</center>")
	return messages

/datum/antagonist/battle/team2
	name = "Синие"
	special_role = JOB_TITLE_TEAM2
	show_in_roundend = FALSE
	show_in_orbit = TRUE
	antag_menu_name = "Синие"
	antag_hud_name = "team2"
	antag_hud_type = ANTAG_HUD_TEAM_2

/datum/antagonist/battle/team3
	name = "Красные"
	special_role = JOB_TITLE_TEAM3
	show_in_roundend = FALSE
	show_in_orbit = TRUE
	antag_menu_name = "Красные"
	antag_hud_name = "team3"
	antag_hud_type = ANTAG_HUD_TEAM_3
