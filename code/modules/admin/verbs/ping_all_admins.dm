/client/proc/ping_all_admins()
	set name = "Ping all admins"
	set category = "Admin.Admin"

	if(!check_rights(R_ADMIN, FALSE))
		return

	var/msg = tgui_input_text(src, "Какое сообщение вы хотите, чтобы пинг показывал?", "Пингануть всех админов", encode = FALSE)
	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	var/list/admins_to_ping = list()

	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			admins_to_ping += C

	var/de_admin_also = tgui_alert(usr, "Хотите ли вы пинговать администраторов, которые находятся в де-админе?", "Пингануть всех админов", list("Да", "Нет"))
	if(de_admin_also == "Да")
		for(var/key in GLOB.de_admins)
			var/client/C = GLOB.directory[ckey]
			if(!C)
				continue
			admins_to_ping += C

	if(length(admins_to_ping) < 2) // All by yourself?
		to_chat(usr, span_boldannounceooc("Нет других админов онлайн для пинга[de_admin_also == "Да" ? ", включая тех, кто находится в де-админе" : ""]!"))
		return

	var/datum/say/asay = new(usr.ckey, usr.client.holder.rank, msg, world.timeofday)
	GLOB.asays += asay
	log_ping_all_admins("[length(admins_to_ping)] clients pinged: [msg]", src)

	for(var/client/C in admins_to_ping)
		SEND_SOUND(C, sound('sound/misc/ping.ogg'))
		to_chat(C, span_all_admin_ping("ALL ADMIN PING: <span class='name'>[key_name(usr, TRUE)]</span> ([admin_jump_link(mob)]): <span class='emoji_enabled'>[msg]</span>"))
	to_chat(usr, "[length(admins_to_ping)] клиентов пропинговано.")
