/client/verb/bugreport()
	set name = "Баг-репорт"
	set category = ADMIN_CATEGORY_TICKETS

	if(check_mute(ckey, MUTE_ADMINHELP))
		to_chat(src, span_red("Error: Admin-PM: You cannot send adminhelps (Muted)."), MESSAGE_TYPE_ADMINPM, confidential = TRUE)
		return

	var/msg

	var/description = tgui_input_text(src, "1. Опишите баг/недочет:", "Баг-репорт", max_length=700, encode = FALSE)
	if(!description)
		empty_input_alert(1)
		return
	var/correct_desc = tgui_input_text(src, "2. Опишите ожидаемое поведение (как должно работать):", "Баг-репорт", max_length=700, encode = FALSE)
	if(!correct_desc)
		empty_input_alert(2)
		return
	var/discord =  tgui_input_text(src, "3. Ваш дискорд для связи (обязательно):", "Баг-репорт", max_length=100, encode = FALSE)
	if(!discord)
		empty_input_alert(3)
		return
	var/have_screens = tgui_alert(src, "4. Есть ли у вас скрины/видео?", "Баг-репорт", list("Да", "Нет"))=="Да"
	if(!have_screens)
		empty_input_alert(4)
		return

	msg = "[key_name(src)]\nID раунда: [GLOB.round_id] \n1. [description]\n2. [correct_desc]\n3. [discord]\n4. Скрины: [have_screens ? "Да" : "Нет"]"

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, OOC_COOLDOWN))
		return

	if(tgui_alert(src, "Ваш репорт выглядит так:\n[msg]\nВы уверены что все заполнено правильно?", "Баг-репорт", list("Да", "Нет"))=="Да")
		SSdiscord.send2discord_simple(DISCORD_WEBHOOK_BUGREPORT, msg)
		to_chat(src, span_good("Баг-репорт успешно отправлен разработчикам!"))

/client/proc/empty_input_alert(question_number)
	tgui_alert(src, "Вы пропустили [question_number] пункт! Попробуйте сделать баг-репорт еще раз, заполняя все поля", "Баг-репорт")
