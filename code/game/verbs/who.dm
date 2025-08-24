#define DEFAULT_WHO_CELLS_PER_ROW 4
#define NO_ADMINS_ONLINE_MESSAGE "Все запросы помощи администраторов перенаправляются в наш Discord-сервер! Даже если в игре в данный момент нет администраторов, ваше сообщение может быть замечено, и на него может быть дан ответ."

/client/verb/who()
	set name = "Список игроков"
	set category = STATPANEL_OOC

	var/msg = "<b>Игроков онлайн:</b><br>"

	var/list/lines = list()
	var/columns_per_row = DEFAULT_WHO_CELLS_PER_ROW

	if(holder)
		if(check_rights(R_ADMIN, FALSE) && isobserver(src.mob)) //If they have +ADMIN and are a ghost they can see players IC names and statuses.
			columns_per_row = 1
			var/mob/dead/observer/admin_observer = src.mob
			if(!admin_observer.started_as_observer)
				log_admin("[key_name(usr)] checked advanced who in-round.")
			for(var/client/client in GLOB.clients)
				if(client.holder && client.holder.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // need PERMISSIONS to see BB
					continue

				var/entry = "\t[client.key]"
				if(client.holder && client.holder.fakekey)
					entry += " <i>(как [client.holder.fakekey])</i>"
				if(isnewplayer(client.mob))
					entry += " – <font color='darkgray'><b>В лобби</b></font>"
				else
					entry += " – Играет за [client.mob.real_name]"
				switch(client.mob.stat)
					if(UNCONSCIOUS)
						entry += " – <font color='darkgray'><b>Без сознания</b></font>"
					if(DEAD)
						if(isobserver(client.mob))
							var/mob/dead/observer/observer = client.mob
							if(observer.started_as_observer)
								entry += " – <font color='gray'>Наблюдает</font>"
							else
								entry += " – <font color='black'><b>МЕРТВ</b></font>"
						else
							entry += " – <font color='black'><b>МЕРТВ</b></font>"

				var/age
				if(isnum(client.player_age))
					age = client.player_age
				else
					age = 0
				if(age <= 1)
					age = "<font color='#ff0000'><b>[age]</b></font>"
				else if(age < 10)
					age = "<font color='#ff8c00'><b>[age]</b></font>"
				entry += " – [age]"

				if(is_special_character(client.mob))
					entry += " – <b><font color='red'>Антагонист</font></b>"
				entry += " ([ADMIN_QUE(client.mob,"?")])"
				entry += " ([round(client.avgping, 1)]ms)"
				lines += entry
	else
		for(var/client/client in GLOB.clients)
			if(client.holder && client.holder.big_brother) // BB doesn't show up at all
				continue

			if(client.holder && client.holder.fakekey)
				lines += "[client.holder.fakekey] ([round(client.avgping, 1)]ms)"
			else
				lines += "[client.key] ([round(client.avgping, 1)]ms)"

	var/num_lines = 0
	msg += "<table style='width: 100%; table-layout: fixed'><tr>"
	for(var/line in sortList(lines))
		msg += "<td>[line]</td>"

		num_lines += 1
		if(num_lines == columns_per_row)
			num_lines = 0
			msg += "</tr><tr>"
	msg += "</tr></table>"

	msg += "<b>Всего в сети: [length(lines)]</b>"
	to_chat(src, chat_box_examine(msg), type = MESSAGE_TYPE_INFO)

/client/verb/adminwho()
	set name = "В сети"
	set category = STATPANEL_ADMIN_TICKETS

	var/list/adminmsg = list()
	var/list/moderatormsg = list()
	var/list/mentormsg = list()
	var/list/devmsg = list()

	var/num_admins_online = 0
	var/num_moderator_online = 0
	var/num_mentors_online = 0
	var/num_devs_online = 0

	for(var/client/client in GLOB.admins)
		var/list/line = list()
		line += "\[[get_colored_rank(client.holder.rank)]\]  [client]"

		if(holder) // Only for those with perms see the extra bit
			if(client.holder.fakekey && check_rights(R_ADMIN, FALSE))
				line += " <i>(как [client.holder.fakekey])</i>"

			if(isobserver(client.mob))
				line += " – Наблюдает"
			else if(isnewplayer(client.mob))
				line += " – В лобби"
			else
				line += " – Играет"

			if(client.is_afk())
				line += " (AFK)"

		if(check_rights(R_ADMIN, FALSE, client.mob)) // Is this client an admin?
			if(client?.holder?.fakekey && !check_rights(R_ADMIN, FALSE)) // Only admins can see stealthmins
				continue

			if(client?.holder?.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // Normal admins can't see Big Brother
				continue

			num_admins_online++
			adminmsg += jointext(line, "")

		else if(check_rights(R_MOD, FALSE, client.mob)) // Is this client a moderator?
			num_moderator_online++
			moderatormsg += jointext(line, "")

		else if(check_rights(R_MENTOR, FALSE, client.mob)) // Is this client a mentor?
			num_mentors_online++
			mentormsg += jointext(line, "")

		else if(check_rights(R_VIEWRUNTIMES, FALSE, client.mob)) // Is this client a developer?
			num_devs_online++
			devmsg += jointext(line, "")

	var/list/final_message = list()
	if(num_admins_online)
		final_message += "<b>Админов онлайн ([num_admins_online]):</b>"
		final_message += adminmsg
		final_message += "<br>"
	if(num_moderator_online)
		final_message += "<b>Модераторов онлайн ([num_moderator_online]):</b>"
		final_message += moderatormsg
		final_message += "<br>"
	if(num_mentors_online)
		final_message += "<b>Менторов онлайн ([num_mentors_online]):</b>"
		final_message += mentormsg
		final_message += "<br>"
	if(num_devs_online)
		final_message += "<b>Разработчиков онлайн ([num_devs_online]):</b>"
		final_message += devmsg
		final_message += "<br>"
	if(!num_admins_online || !num_moderator_online || !num_mentors_online)
		final_message += span_notice(NO_ADMINS_ONLINE_MESSAGE)
	to_chat(src, chat_box_examine(jointext(final_message, "\n")), type = MESSAGE_TYPE_INFO)

/// Returns colored rank representation
/proc/get_colored_rank(rank)
	switch(rank)
		if("Хост")
			return "<font color='#1ABC9C'>[rank]</font>"
		if("Старший Админ", "Главный Администратор Проекта")
			return "<font color='#f02f2f'>[rank]</font>"
		if("Админ")
			return "<font color='#ee8f29'>[rank]</font>"
		if("Триал Админ")
			return "<font color='#cfc000'>[rank]</font>"
		if("Модератор")
			return "<font color='#9db430'>[rank]</font>"
		if("Ментор")
			return "<font color='#67761e'>[rank]</font>"
		if("Разработчик", "Контрибьютор", "Ведущий Разработчик")
			return "<font color='#2ecc71'>[rank]</font>"
		else
			return rank

#undef DEFAULT_WHO_CELLS_PER_ROW
#undef NO_ADMINS_ONLINE_MESSAGE
