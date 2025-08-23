#define DEFAULT_WHO_CELLS_PER_ROW 4

/client/verb/who()
	set name = "Список игроков"
	set category = STATPANEL_OOC

	var/msg = "<b>Онлайн Игроков:</b><br>"


	var/list/Lines = list()
	var/columns_per_row = DEFAULT_WHO_CELLS_PER_ROW

	if(check_rights(R_ADMIN,0))
		columns_per_row = 1
		for(var/client/client in GLOB.clients)
			if(client.holder && client.holder.big_brother && !check_rights(R_PERMISSIONS, 0)) // need PERMISSIONS to see BB
				continue

			var/entry = "\t[client.key]"
			if(client.holder && client.holder.fakekey)
				entry += " <i>(как [client.holder.fakekey])</i>"
			entry += " – Играет за [client.mob.real_name]"
			switch(client.mob.stat)
				if(UNCONSCIOUS)
					entry += " – <font color='darkgray'><b>Без сознания</b></font>"
				if(DEAD)
					if(isobserver(client.mob))
						var/mob/dead/observer/O = client.mob
						if(O.started_as_observer)
							entry += " – <font color='gray'>Наблюдает</font>"
						else
							entry += " – <font color='black'><b>МЕРТВ</b></font>"
					else if(isnewplayer(client.mob))
						entry += " – <font color='green'>Новый Игрок</font>"
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
			Lines += entry
	else
		for(var/client/client in GLOB.clients)
			if(client.holder && client.holder.big_brother) // BB doesn't show up at all
				continue

			if(client.holder && client.holder.fakekey)
				Lines += "[client.holder.fakekey] ([round(client.avgping, 1)]ms)"
			else
				Lines += "[client.key] ([round(client.avgping, 1)]ms)"

	var/num_lines = 0
	msg += "<table style='width: 100%; table-layout: fixed'><tr>"
	for(var/line in sortList(Lines))
		msg += "<td>[line]</td>"

		num_lines += 1
		if (num_lines == columns_per_row)
			num_lines = 0
			msg += "</tr><tr>"
	msg += "</tr></table>"

	msg += "<b>Всего Игроков: [length(Lines)]</b>"
	to_chat(src, msg)

/client/verb/adminwho()
	set category = STATPANEL_ADMIN_TICKETS
	set name = "В сети"

	var/msg = ""
	var/modmsg = ""
	var/num_mods_online = 0
	var/num_admins_online = 0
	if(holder)
		for(var/client/client in GLOB.admins)
			if(check_rights(R_ADMIN, FALSE, client.mob))

				if(client?.holder?.fakekey && !check_rights(R_ADMIN, 0)) // Only admins can see stealthmins
					continue

				if(client?.holder?.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // Normal admins can't see Big Brother
					continue

				msg += "\[[client.holder.rank]\]  [client]"

				if(client.holder.fakekey)
					msg += " <i>(как [client.holder.fakekey])</i>"

				if(isobserver(client.mob))
					msg += " – Наблюдает"
				else if(isnewplayer(client.mob))
					msg += " – В Лобби"
				else
					msg += " – Играет"

				if(client.is_afk())
					msg += " (Отошёл)"
				msg += "<br>"

				num_admins_online++

			else if(check_rights(R_MENTOR|R_MOD, 0, client.mob))
				modmsg += "\[[client.holder.rank]\]  [client]"

				if(isobserver(client.mob))
					modmsg += " – Наблюдает"
				else if(isnewplayer(client.mob))
					modmsg += " – В Лобби"
				else
					modmsg += " – Играет"

				if(client.is_afk())
					modmsg += " (Отошёл)"
				modmsg += "<br>"
				num_mods_online++
	else
		for(var/client/client in GLOB.admins)

			if(check_rights(R_ADMIN, 0, client.mob))
				if(!client.holder.fakekey)
					msg += "\[[client.holder.rank]\]  [client]<br>"
					num_admins_online++
			else if(check_rights(R_MOD|R_MENTOR, 0, client.mob) && !check_rights(R_ADMIN, 0, client.mob))
				modmsg += "\[[client.holder.rank]\]  [client]<br>"
				num_mods_online++

	var/noadmins_info = span_notice(span_small("<br>Даже если никого из менторов и администраторов нет в сети, вы всё равно можете оставить запрос на помощь. Все обращения к менторам и администраторам будут перенаправлены в наш Discord-сервер!"))
	msg = "<b>Онлайн Админов ([num_admins_online]):</b><br>" + msg + "<br><b>Онлайн Менторов/Модераторов ([num_mods_online]):</b><br>" + modmsg + noadmins_info
	msg = replacetext(msg, "\[Хост\]",	"\[<font color='#1ABC9C'>Хост</font>\]")
	msg = replacetext(msg, "\[Старший Админ\]",	"\[<font color='#f02f2f'>Старший Админ</font>\]")
	msg = replacetext(msg, "\[Главный Администратор Проекта\]",	"\[<font color='#f02f2f'>Главный Администратор Проекта</font>\]")
	msg = replacetext(msg, "\[Админ\]",	"\[<font color='#ee8f29'>Админ</font>\]")
	msg = replacetext(msg, "\[Триал Админ\]",	"\[<font color='#cfc000'>Триал Админ</font>\]")
	msg = replacetext(msg, "\[Модератор\]",	"\[<font color='#9db430'>Модератор</font>\]")
	msg = replacetext(msg, "\[Ментор\]",	"\[<font color='#67761e'>Ментор</font>\]")
	msg = replacetext(msg, "\[Разработчик\]",	"\[<font color='#2ecc71'>Разработчик</font>\]")
	msg = replacetext(msg, "\[Контрибьютор\]",	"\[<font color='#2ecc71'>Контрибьютор</font>\]")
	msg = replacetext(msg, "\[Ведущий Разработчик\]",	"\[<font color='#2ecc71'>Ведущий Разработчик</font>\]")
	to_chat(src, msg)

#undef DEFAULT_WHO_CELLS_PER_ROW
