/client/verb/bugreport()
	set name = "Баг-репорт"
	set category = ADMIN_CATEGORY_TICKETS

	if(check_mute(ckey, MUTE_ADMINHELP))
		to_chat(src, span_red("Error: Admin-PM: You cannot send adminhelps (Muted)."), MESSAGE_TYPE_ADMINPM, confidential = TRUE)
		return

	var/msg

	var/description = tgui_input_text(src, "Опишите баг/недочет:", "Баг-репорт", max_length=700, encode = FALSE)
	var/correct_desc = tgui_input_text(src, "Опишите ожидаемое поведение (как должно работать):", "Баг-репорт", max_length=700, encode = FALSE)
	var/discord =  tgui_input_text(src, "Ваш дискорд для связи (обязательно):", "Баг-репорт", max_length=100, encode = FALSE)
	var/have_screens = tgui_alert(src, "Есть ли у вас скрины?", "Баг-репорт", list("Да", "Нет"))=="Да"

	if(!description || !correct_desc || !discord)
		tgui_alert(src, "Вы пропустили один из пунктов! Попробуйте сделать баг-репорт еще раз, заполняя все поля", "Баг-репорт")
		return TRUE

	msg = "[key_name(src)]\nRound id: [GLOB.round_id] \n1. [description]\n2. [correct_desc]\n3. [discord]\n4. Скрины: [have_screens ? "Да" : "Нет"]"
	if(findtext(msg, "<@") || findtext(msg, "<@&"))
		tgui_alert(src, "Обнаружена попытка пинга (<@id> или <@&id>)! Сообщение не будет отправленно.", "Баг-репорт")
		return TRUE
	if(tgui_alert(src, "Ваш репорт выглядит так:\n[msg]\nВы уверены что все заполнено правильно?", "Баг-репорт", list("Да", "Нет"))=="Да")
		SSdiscord.send2discord_simple(DISCORD_WEBHOOK_BUGREPORT, msg)
