#define DEFAULT_WHO_CELLS_PER_ROW 4
#define NO_ADMINS_ONLINE_MESSAGE "Все запросы помощи администраторов перенаправляются в наш Discord-сервер! Даже если в игре в данный момент нет администраторов, ваше сообщение может быть замечено, и на него может быть дан ответ."

/client/verb/who()
	set name = "Список игроков"
	set category = VERB_CATEGORY_OOC

	var/msg = ""

	var/list/lines = list()
	var/columns_per_row = DEFAULT_WHO_CELLS_PER_ROW

	if(holder)
		if(check_rights(R_ADMIN, FALSE) && isobserver(src.mob)) //If they have +ADMIN and are a ghost they can see players IC names and statuses.
			columns_per_row = 1
			var/mob/dead/observer/admin_observer = src.mob
			if(!admin_observer.started_as_observer) //If you aghost to do this
				log_admin("[key_name(usr)] checked advanced who in-round.")
			for(var/client/client in GLOB.clients)
				if(client.holder && client.holder.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // need PERMISSIONS to see BB
					continue

				var/entry = "\t[client.key]"
				if(client.holder && client.holder.fakekey)
					entry += " <i>(как [client.holder.fakekey])</i>"
				if(isnewplayer(client.mob))
					entry += " – <span style='color: darkgray;'><b>В лобби</b></span>"
				else
					entry += " – Играет за [client.mob.real_name]"
					switch(client.mob.stat)
						if(UNCONSCIOUS)
							entry += " – <span style='color: darkgray;'><b>Без сознания</b></span>"
						if(DEAD)
							if(isobserver(client.mob))
								var/mob/dead/observer/observer = client.mob
								if(observer.started_as_observer)
									entry += " – <span style='color: gray;'>Наблюдает</span>"
								else
									entry += " – <span style='color: black;'><b>МЕРТВ</b></span>"
							else
								entry += " – <span style='color: black;'><b>МЕРТВ</b></span>"

					if(is_special_character(client.mob))
						entry += " – <span style='color: red;'><b>Антагонист</b></span>"

				var/age
				if(isnum(client.player_age))
					age = client.player_age
				else
					age = 0
				if(age <= 1)
					age = "<span style='color: red;'><b>[age]</b></span>"
				else if(age < 10)
					age = "<span style='color: orange;'><b>[age]</b></span>"
				entry += " – [age]"

				entry += " ([ADMIN_QUE(client.mob,"?")])"
				entry += " ([round(client.avgping, 1)]ms)"
				lines += entry
		else //If they don't have +ADMIN, only show hidden admins
			for(var/client/client in GLOB.clients)
				if(client.holder && client.holder.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // need PERMISSIONS to see BB
					continue

				var/entry = "[client.key]"
				if(client.holder && client.holder.fakekey)
					entry += " <i>(как [client.holder.fakekey])</i>"
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

	msg += span_bold("Всего в сети: [length(lines)]")

	to_chat(src, fieldset_block(span_bold("Игроков онлайн"), span_infoplain(msg), "boxed_message"), type = MESSAGE_TYPE_INFO)

/client/verb/adminwho()
	set name = "В сети"
	set category = ADMIN_CATEGORY_TICKETS

	var/list/adminwho_data = generate_adminwho_string()
	var/header = adminwho_data["has_admins"] ? "В сети" : "Нет никого в сети"

	to_chat(src, fieldset_block(span_bold(header), adminwho_data["body"], "boxed_message"), type = MESSAGE_TYPE_INFO)

/// Builds the adminwho body, split into admin / mentor / developer sections.
/// Returns an assoc list with "body" (ready-to-display string) and "has_admins" (TRUE if any admin is online).
/client/proc/generate_adminwho_string()
	var/list/adminmsg = list()
	var/list/mentormsg = list()
	var/list/devmsg = list()

	for(var/client/staffer in GLOB.admins)
		var/list/line = list()
		line += "\[[get_colored_rank(staffer.holder.rank)]\] [staffer]"

		if(holder) // Only for those with perms see the extra bit
			if(staffer.holder.fakekey && check_rights(R_ADMIN, FALSE))
				line += " <i>(как [staffer.holder.fakekey])</i>"

			if(isobserver(staffer.mob))
				line += " – Наблюдает"
			else if(isnewplayer(staffer.mob))
				line += " – В лобби"
			else
				line += " – Играет"

			if(staffer.is_afk())
				line += " (AFK)"

		line += "<br>"
		if(check_rights(R_ADMIN, FALSE, staffer.mob)) // Is this client an admin?
			if(staffer?.holder?.fakekey && !check_rights(R_ADMIN, FALSE)) // Only admins can see stealthmins
				continue

			if(staffer?.holder?.big_brother && !check_rights(R_PERMISSIONS, FALSE)) // Normal admins can't see Big Brother
				continue

			adminmsg += jointext(line, "")

		else if(check_rights(R_MENTOR|R_MOD, FALSE, staffer.mob)) // Is this client a mentor or moderator?
			mentormsg += jointext(line, "")

		else if(check_rights(R_VIEWRUNTIMES, FALSE, staffer.mob)) // Is this client a developer?
			devmsg += jointext(line, "")

	var/list/final_message = list()
	final_message += build_adminwho_section("Админов онлайн", adminmsg)
	final_message += build_adminwho_section("Менторов онлайн", mentormsg)
	final_message += build_adminwho_section("Разработчиков онлайн", devmsg)

	if(!length(adminmsg)) // Only admin tickets are parsed to discord.
		final_message += span_notice(NO_ADMINS_ONLINE_MESSAGE)

	return list(
		"body" = jointext(final_message, ""),
		"has_admins" = length(adminmsg) > 0,
	)

/// Builds a single titled adminwho section, or an empty string when there are no entries.
/proc/build_adminwho_section(title, list/entries)
	if(!length(entries))
		return ""
	return span_bold("[title] ([length(entries)]):<br>") + jointext(entries, "") + "<br>"

/// Returns colored rank representation.
/proc/get_colored_rank(rank)
	switch(rank)
		if("Хост")
			return "<span style='color: #1ABC9C;'>[rank]</span>" // rgb(26, 188, 156)
		if("Старший Админ", "Главный Администратор Проекта")
			return "<span style='color: #f02f2f;'>[rank]</span>" // rgb(240, 47, 47)
		if("Админ")
			return "<span style='color: #ee8f29;'>[rank]</span>" // rgb(238, 143, 41)
		if("Триал Админ")
			return "<span style='color: #cfc000;'>[rank]</span>" // rgb(207, 192, 0)
		if("Модератор")
			return "<span style='color: #9db430;'>[rank]</span>" // rgb(157, 180, 48)
		if("Ментор")
			return "<span style='color: #67761e;'>[rank]</span>" // rgb(103, 118, 30)
		if("Разработчик", "Контрибьютор", "Ведущий Разработчик")
			return "<span style='color: #2ecc71;'>[rank]</span>" // rgb(46, 204, 113)
		else
			return rank

#undef DEFAULT_WHO_CELLS_PER_ROW
#undef NO_ADMINS_ONLINE_MESSAGE
