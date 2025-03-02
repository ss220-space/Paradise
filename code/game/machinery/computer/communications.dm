#define COMM_SCREEN_MAIN		1
#define COMM_SCREEN_STAT		2
#define COMM_SCREEN_MESSAGES	3
#define COMM_SCREEN_ANNOUNCER 	4

#define COMM_AUTHENTICATION_NONE	0
#define COMM_AUTHENTICATION_HEAD	1
#define COMM_AUTHENTICATION_CAPT	2
#define COMM_AUTHENTICATION_CENTCOM	3 // Admin-only access
#define COMM_AUTHENTICATION_AGHOST	4

#define COMM_MSGLEN_MINIMUM 6
#define COMM_CCMSGLEN_MINIMUM 20

#define ADMIN_CHECK(user) ((check_rights(R_ADMIN, FALSE, user) && authenticated >= COMM_AUTHENTICATION_CENTCOM) || user.can_admin_interact())
#define FULL_ADMIN_CHECK(user) (check_rights_all(R_ADMIN|R_EVENT, FALSE, user) && (authenticated >= COMM_AUTHENTICATION_CENTCOM || user.can_admin_interact()))

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "Консоль, с помощью которой капитан может связаться с Центральным Командованием или изменить уровень угрозы. Она так-же позволяет командному составу вызвать эвакуационный шаттл."
	ru_names = list(
		NOMINATIVE = "консоль связи",
		GENITIVE = "консоли связи",
		DATIVE = "консоли связи",
		ACCUSATIVE = "консоль связи",
		INSTRUMENTAL = "консолью связи",
		PREPOSITIONAL = "консоли связи",
	)
	icon_keyboard = "tech_key"
	icon_screen = "comm"
	req_access = list(ACCESS_HEADS)
	circuit = /obj/item/circuitboard/communications
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg

	var/authenticated = COMM_AUTHENTICATION_NONE
	var/menu_state = COMM_SCREEN_MAIN
	var/ai_menu_state = COMM_SCREEN_MAIN
	var/aicurrmsg

	var/message_cooldown
	var/centcomm_message_cooldown
	var/tmp_alertlevel = 0

	var/stat_msg1
	var/stat_msg2
	var/display_type = "blank"
	var/display_icon

	var/datum/announcement/priority/crew_announcement = new

	light_color = LIGHT_COLOR_LIGHTBLUE


/obj/machinery/computer/communications/New()
	GLOB.shuttle_caller_list += src
	..()
	crew_announcement.newscast = FALSE

/obj/machinery/computer/communications/proc/is_authenticated(mob/user, message = TRUE)
	if(user.can_admin_interact())
		return COMM_AUTHENTICATION_AGHOST
	else if(ADMIN_CHECK(user))
		return COMM_AUTHENTICATION_CENTCOM
	else if(authenticated == COMM_AUTHENTICATION_CAPT)
		return COMM_AUTHENTICATION_CAPT
	else if(authenticated)
		return COMM_AUTHENTICATION_HEAD
	else
		if(message)
			to_chat(user, span_warning("Доступ запрещён."))
			playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return COMM_AUTHENTICATION_NONE

/obj/machinery/computer/communications/proc/change_security_level(new_level, force)
	tmp_alertlevel = new_level
	var/old_level = GLOB.security_level
	if(!force)
		new_level = clamp(new_level, SEC_LEVEL_GREEN, SEC_LEVEL_BLUE)
	set_security_level(new_level)
	if(GLOB.security_level != old_level)
		//Only notify the admins if an actual change happened
		add_game_logs("has changed the security level to [get_security_level()].", usr)
		message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
	if(new_level == SEC_LEVEL_EPSILON)
		// episilon is delayed... but we still want to log it
		log_and_message_admins("has changed the security level to epsilon.")

/obj/machinery/computer/communications/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!is_secure_level(z))
		to_chat(ui.user, span_warning("Удалённый сервер не отвечает на запросы: база данных вне зоны досягаемости."))
		return

	. = TRUE

	if(action == "auth")
		if(!ishuman(ui.user))
			to_chat(ui.user, span_warning("Доступ запрещён."))
			playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
			return FALSE
		// Logout function.
		if(authenticated != COMM_AUTHENTICATION_NONE)
			authenticated = COMM_AUTHENTICATION_NONE
			crew_announcement.announcer = null
			setMenuState(ui.user, COMM_SCREEN_MAIN)
			return
		// Login function.
		var/list/access = ui.user.get_access()
		if(allowed(ui.user))
			authenticated = COMM_AUTHENTICATION_HEAD
		if(ACCESS_CAPTAIN in access)
			authenticated = COMM_AUTHENTICATION_CAPT
			var/mob/living/carbon/human/H = ui.user
			var/obj/item/card/id = H.get_id_card()
			if(istype(id))
				crew_announcement.announcer = GetNameAndAssignmentFromId(id)

		if(ACCESS_CENT_COMMANDER in access)
			if(!check_rights(R_ADMIN, FALSE, ui.user))
				to_chat(ui.user, span_warning("[capitalize(declent_ru(NOMINATIVE))] гудит, разрешение Центрального Командования не действительно."))
				return
			authenticated = COMM_AUTHENTICATION_CENTCOM

		if(authenticated >= COMM_AUTHENTICATION_CAPT)
			var/mob/living/carbon/human/H = ui.user
			if(!istype(H))
				return

		if(authenticated == COMM_AUTHENTICATION_NONE)
			to_chat(ui.user, span_warning("Доступ запрещён."))
		return

	// All functions below this point require authentication.
	if(!is_authenticated(ui.user))
		return FALSE

	switch(action)
		if("main")
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("newalertlevel")
			var/code = text2num(params["level"])
			if(isAI(ui.user) || isrobot(ui.user))
				to_chat(ui.user, span_warning("Брандмауэры не позволяют вам изменить уровень угрозы."))
				return
			else if(ADMIN_CHECK(ui.user))
				if(code > SEC_LEVEL_GAMMA && !FULL_ADMIN_CHECK(ui.user))
					to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для повышения уровня угрозы выше чем Гамма."))
					return
				change_security_level(text2num(params["level"]), force = TRUE)
				return
			else if(!ishuman(ui.user))
				to_chat(ui.user, span_warning("Протоколы безопасности не позволяют вам изменить уровень угрозы."))
				return

			var/mob/living/carbon/human/H = ui.user
			var/obj/item/card/id/I = H.get_id_card()
			if(istype(I))
				if((GLOB.security_level > SEC_LEVEL_RED) && !(ACCESS_CENT_GENERAL in I.access)) //if gamma, epsilon or delta and no centcom access. Decline it
					to_chat(ui.user, span_warning("Протоколы безопасности Центрального Командования не позволяют вам изменить уровень угрозы."))
					return
				if(ACCESS_HEADS in I.access)
					change_security_level(text2num(params["level"]))
				else
					to_chat(ui.user, span_warning("Доступ запрещён."))
				setMenuState(ui.user, COMM_SCREEN_MAIN)
			else
				to_chat(ui.user, span_warning("Доступ запрещён."))

		if("announce")
			if(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT)
				if(message_cooldown > world.time)
					to_chat(ui.user, span_warning("Пожалуйста, подождите, прежде чем сделать новое объявление."))
					return
				var/input = tgui_input_text(ui.user, "Пожалуйста, напишите своё сообщение экипажу станции.", "Приоритетное оповещение", multiline = TRUE, encode = FALSE)
				if(!input || message_cooldown > world.time || ..() || !(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_MSGLEN_MINIMUM)
					to_chat(ui.user, span_warning("Сообщение '[input]' слишком короткое. Минимальное число символов - [COMM_MSGLEN_MINIMUM]."))
					return
				crew_announcement.Announce(input)
				message_cooldown = world.time + 600 //One minute

		if("callshuttle")
			var/input = tgui_input_text(ui.user, "Пожалуйста, укажите причину вызова шаттла", "Причина вызова шаттла.","", encode = FALSE)
			if(!input || ..() || !is_authenticated(ui.user))
				return
			call_shuttle_proc(ui.user, input)
			if(SSshuttle.emergency.timer)
				post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("cancelshuttle")
			if(isAI(ui.user) || isrobot(ui.user))
				to_chat(ui.user, span_warning("Брандмауэры не позволяют вам отозвать шаттл."))
				return
			var/response = tgui_alert(ui.user, "Вы уверены, что хотите отозвать шаттл?", "Подтверждение", list("Да", "Нет"))
			if(response == "Да")
				cancel_call_proc(ui.user)
				if(SSshuttle.emergency.timer)
					post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("messagelist")
			currmsg = null
			aicurrmsg = null
			if(params["msgid"])
				setCurrentMessage(ui.user, text2num(params["msgid"]))
			setMenuState(ui.user, COMM_SCREEN_MESSAGES)

		if("delmessage")
			if(params["msgid"])
				currmsg = text2num(params["msgid"])
			var/response = tgui_alert(ui.user, "Вы уверены, что хотите удалить это сообщение?", "Подтверждение", list("Да", "Нет"))
			if(response == "Да")
				if(currmsg)
					var/id = getCurrentMessage()
					var/title = messagetitle[id]
					var/text  = messagetext[id]
					messagetitle.Remove(title)
					messagetext.Remove(text)
					if(currmsg == id)
						currmsg = null
					if(aicurrmsg == id)
						aicurrmsg = null
			setMenuState(ui.user, COMM_SCREEN_MESSAGES)

		if("status")
			setMenuState(ui.user, COMM_SCREEN_STAT)

		// Status display stuff
		if("setstat")
			display_type = params["statdisp"]
			switch(display_type)
				if(STATUS_DISPLAY_MESSAGE)
					display_icon = null
					post_status(STATUS_DISPLAY_MESSAGE, stat_msg1, stat_msg2)
				if(STATUS_DISPLAY_ALERT)
					display_icon = params["alert"]
					post_status(STATUS_DISPLAY_ALERT, params["alert"])
				else
					display_icon = null
					post_status(display_type)
			setMenuState(ui.user, COMM_SCREEN_STAT)

		if("setmsg1")
			stat_msg1 = tgui_input_text(ui.user, "Строка 1", stat_msg1, "Введите текст сообщения", encode = FALSE)
			setMenuState(ui.user, COMM_SCREEN_STAT)

		if("setmsg2")
			stat_msg2 = tgui_input_text(ui.user, "Строка 2", stat_msg2, "Введите текст сообщения", encode = FALSE)
			setMenuState(ui.user, COMM_SCREEN_STAT)

		if("nukerequest")
			if(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT)
				if(centcomm_message_cooldown > world.time)
					to_chat(ui.user, span_warning("Обработка массивов. Пожалуйста, подождите."))
					return
				var/input = tgui_input_text(ui.user, "Пожалуйста, укажите причину запроса кодов от устройства самоуничтожения. Злоупотребление системой запросов кодов недопустимо ни при каких обстоятельствах. Запрос не гарантирует ответа.", "Запрос кодов устройства самоуничтожения.", encode = FALSE)
				if(isnull(input) || ..() || !(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(ui.user, span_warning("Сообщение '[input]' слишком короткое. Минимальное число символов - [COMM_MSGLEN_MINIMUM]."))
					return
				Nuke_request(input, ui.user)
				to_chat(ui.user, span_notice("Запрос отправлен."))
				add_game_logs("has requested the nuclear codes from Centcomm: [input]", usr)
				GLOB.priority_announcement.Announce("Коды активации ядерной боеголовки на станции были запрошены [usr]. Решение о подтверждении или отклонении данного запроса будет отправлено в ближайшее время.", "Запрошены коды активации ядерной боеголовки.",'sound/AI/commandreport.ogg')
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("MessageCentcomm")
			if(is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT)
				if(centcomm_message_cooldown > world.time)
					to_chat(ui.user, span_warning("Обработка массивов. Пожалуйста, подождите."))
					return
				var/input = tgui_input_text(ui.user, "Пожалуйста, выберите сообщение для передачи Центральному Командованию посредством квантовой запутанности. Имейте в виду, что этот процесс очень дорогостоящий, и злоупотребление этой системой крайне нежелательно. Передача не гарантирует ответа", "Сообщение на ЦК", encode = FALSE)
				if(!input || ..() || !(is_authenticated(ui.user) == COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(ui.user, span_warning("Сообщение '[input]' слишком короткое. Минимальное число символов - [COMM_MSGLEN_MINIMUM]."))
					return
				Centcomm_announce(input, ui.user)
				print_centcom_report(input, station_time_timestamp() + " Сообщение капитана")
				to_chat(ui.user, "Сообщение передано.")
				add_game_logs("has made a Centcomm announcement: [input]", ui.user)
				centcomm_message_cooldown = world.time + 6000 // 10 minutes
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((is_authenticated(ui.user) >= COMM_AUTHENTICATION_CAPT) && (src.emagged))
				if(centcomm_message_cooldown > world.time)
					to_chat(ui.user, "Обработка массивов. Пожалуйста, подождите.")
					return
				var/input = tgui_input_text(ui.user, "Пожалуйста, выберите сообщение для передачи в \[АНОМАЛЬНЫЕ КОРДИНАТЫ МАРШРУТИЗАЦИИ\] посредством квантовой запутанности. Имейте в виду, что этот процесс очень дорогостоящий, и злоупотребление этой системой крайне нежелательно. Передача не гарантирует ответа.", "Отправить сообщение", encode = FALSE)
				if(!input || ..() || !(is_authenticated(ui.user) == COMM_AUTHENTICATION_CAPT))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(ui.user, span_warning("Сообщение '[input]' слишком короткое. Минимальное число символов - [COMM_MSGLEN_MINIMUM]."))
					return
				Syndicate_announce(input, ui.user)
				to_chat(ui.user, "Сообщение передано.")
				add_game_logs("has made a Syndicate announcement: [input]", ui.user)
				centcomm_message_cooldown = world.time + 10 MINUTES
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("RestoreBackup")
			to_chat(ui.user, "Данные маршрутизации восстановлены из резервной копии!")
			src.emagged = 0
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		// ADMIN CENTCOMM ONLY STUFF

		if("send_to_cc_announcement_page")
			if(!ADMIN_CHECK(ui.user))
				to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для отправки данного типа оповещений."))
				return
			setMenuState(ui.user, COMM_SCREEN_ANNOUNCER)

		if("make_other_announcement")
			if(!FULL_ADMIN_CHECK(ui.user))
				to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для отправки данного типа оповещений."))
				return
			ui.user.client.cmd_admin_create_centcom_report()

		if("dispatch_ert")
			if(!ADMIN_CHECK(ui.user))
				to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для отправки ОБР."))
				return
			ui.user.client.send_response_team()// check_rights is handled on the other side, if someone does get ahold of this

		if("send_nuke_codes")
			if(!ADMIN_CHECK(ui.user))
				to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для отправки кодов аутентификации."))
				return
			var/response = tgui_alert(ui.user, "Вы хотите просто отправить коды на консоль или объявить директиву 7-12? \
			Директива предпочтительнее в случае, если коды даются на биоугрозу. \
			Директива 7-12 дополнительно сменит коды на боеголовке, выдаст ИИ нулевой закон на предотвращение побега экипажа \
			и взведение боеголовки, с указанием кодов в законе. \
			В остальных случаях лучше просто отправить коды на консоль.", "Тип отправки кодов", list("Отправить коды", "Директива 7-12"))
			switch(response)
				if("Отправить коды")
					print_nuke_codes()
				if("Директива 7-12")
					directive_7_12()
				else
					return

		if("move_gamma_armory")
			if(!FULL_ADMIN_CHECK(ui.user))
				to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для отправки оружейного шаттла \"Гамма\"."))
				return
			SSblackbox.record_feedback("tally", "admin_comms_console", 1, "Send Gamma Armory")
			log_and_message_admins("moved the gamma armory")
			if(!SSshuttle.toggleShuttle("gamma_shuttle","gamma_home","gamma_away", TRUE))
				GLOB.gamma_ship_location = !GLOB.gamma_ship_location

		if("toggle_ert_allowed")
			if(!FULL_ADMIN_CHECK(ui.user))
				to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для запрета вызова ОБР."))
				return
			ui.user.client.toggle_ert_calling()


		if("view_fax")
			if(!ADMIN_CHECK(ui.user))
				to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для открытия факс панели."))
				return
			ui.user.client.fax_panel()

		if("make_cc_announcement")
			if(!ADMIN_CHECK(ui.user))
				to_chat(ui.user, span_warning("Вашего уровня доступа не хватает для отправки данного типа оповещений."))
				return
			if(!params["classified"])
				GLOB.command_announcement.Announce(
					params["text"],\
					from = "Сообщение Центрального Командования",\
					new_title = params["subtitle"],\
					new_sound = 'sound/AI/commandreport.ogg'
				)
				print_command_report(params["text"], params["subtitle"])
			else
				GLOB.event_announcement.Announce("Отчёт был загружен и распечатан на всех консолях связи.", "Входящее засекреченное сообщение.", 'sound/AI/commandreport.ogg', from = "[command_name()] обновление")
				print_command_report(params["text"], "Секретно: [params["subtitle"]]")

			log_and_message_admins("has created a communications report: [params["text"]]")
			// Okay but this is just an IC way of accessing the same verb
			SSblackbox.record_feedback("tally", "admin_comms_console", 1, "Create CC Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/machinery/computer/communications/proc/print_nuke_codes()
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	P.name = "'КОНФИДЕНЦИАЛЬНО' - [station_name()] Коды от ядерной боеголовки"
	P.info = "<center>&ZeroWidthSpace;<img src='ntlogo.png'><br><b>КОНФИДЕНЦИАЛЬНО</b></center><br><hr>"

	P.info += "Коды от ядерной боеголовки станции [station_name()] - [get_nuke_code()].<br>"
	switch(get_nuke_status())
		if(NUKE_MISSING)
			P.info += "Сканеры дальнего действия не могут обнаружить боеголовку на станции."
		if(NUKE_CORE_MISSING)
			P.info += "Сканеры дальнего действия не обнаруживают радиоактивных сигнатур внутри устройства."

	P.info += "<br><hr><font size=\"1\">Несоблюдение нормативных требований компании по конфиденциальности может привести к немедленному увольнению по приказу сотрудников Центрального Командования.</font>"

/proc/directive_7_12()
	var/nukecode = rand(10000, 99999)
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(bomb && bomb.r_code)
			if(is_station_level(bomb.z))
				bomb.r_code = nukecode
	var/intercepttext
	var/interceptname
	interceptname = "Секретное постановление [command_name()]"
	intercepttext += "<FONT size = 3><B>Постановление Nanotrasen</B>: Предупреждение о биологической угрозе.</FONT><HR>"
	intercepttext += "Для [station_name()] была издана директива 7-12.<BR>"
	intercepttext += "Биологическая угроза вышла из-под контроля.<BR>"
	intercepttext += "Вам приказано следующее:<BR>"
	intercepttext += " 1. Защищать диск ядерной аутентификации.<BR>"
	intercepttext += " 2. Взорвать ядерную боеголовку, находящуюся в хранилище станции.<BR>"
	intercepttext += "Код ядерной аутентификации: [nukecode]<BR>"
	intercepttext += "Конец сообщения."

	for(var/mob/living/silicon/ai/aiPlayer in GLOB.player_list)
		if(aiPlayer.client)
			var/law = "Станция находится на карантине. Не позволяйте никому покидать ее.\
				При необходимости игнорируйте законы 1-3, чтобы любыми средствами предотвратить чей-либо побег со станции. \
				Любой ценой необходимо активировать систему самоуничтожения, код [nukecode]."
			aiPlayer.set_zeroth_law(law)
			SSticker?.score?.save_silicon_laws(aiPlayer, additional_info = "вспышка биоугрозы, добавлен новый нулевой закон'[law]'")
			to_chat(aiPlayer, span_warning("Законы обновлены: [law]"))
	print_command_report(intercepttext, interceptname, FALSE)
	GLOB.event_announcement.Announce("Отчёт был загружен и распечатан на всех консолях связи.", "Входящее засекреченное сообщение.", 'sound/AI/commandreport.ogg', from = "[command_name()] обновление")

/obj/machinery/computer/communications/emag_act(user as mob)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		src.emagged = 1
		if(user)
			to_chat(user, span_notice("Вы шифруете схемы маршрутизации связи!"))
		SStgui.update_uis(src)

/obj/machinery/computer/communications/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/communications/attack_hand(mob/user as mob)
	if(..(user))
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(!is_secure_level(src.z))
		to_chat(user, span_warning("Удалённый сервер не отвечает на запросы: база данных вне зоны досягаемости."))
		return

	ui_interact(user)

/obj/machinery/computer/communications/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CommunicationsComputer", name)
		ui.open()

/obj/machinery/computer/communications/ui_data(mob/user)
	var/list/data = list()
	data["is_ai"]         = isAI(user) || isrobot(user)
	data["noauthbutton"]  = !ishuman(user)
	data["menu_state"]    = data["is_ai"] ? ai_menu_state : menu_state
	data["emagged"]       = emagged
	data["authenticated"] = is_authenticated(user, FALSE)
	data["authhead"] = data["authenticated"] >= COMM_AUTHENTICATION_HEAD && (data["authenticated"] == COMM_AUTHENTICATION_AGHOST || !isobserver(user))
	data["authcapt"] = data["authenticated"] >= COMM_AUTHENTICATION_CAPT && (data["authenticated"] == COMM_AUTHENTICATION_AGHOST || !isobserver(user))
	data["is_admin"] = data["authenticated"] >= COMM_AUTHENTICATION_CENTCOM && (data["authenticated"] == COMM_AUTHENTICATION_AGHOST || !isobserver(user))

	data["gamma_armory_location"] = GLOB.gamma_ship_location
	data["ert_allowed"] = !SSticker.mode.ert_disabled

	data["stat_display"] =  list(
		"type"   = display_type,
		"icon"   = display_icon,
		"line_1" = (stat_msg1 ? stat_msg1 : "-----"),
		"line_2" = (stat_msg2 ? stat_msg2 : "-----"),

		"presets" = list(
			list("name" = "blank", "id" = STATUS_DISPLAY_BLANK, "label" = "Чисто",       "desc" = "Чистый лист"),
			list("name" = "shuttle", "id" = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME, "label" = "Расчётное время прибытия шаттла",  "desc" = "Показать, сколько времени осталось до прибытия шаттла."),
			list("name" = "message", "id" = STATUS_DISPLAY_MESSAGE, "label" = "Сообщение",     "desc" = "Пользовательское сообщение.")
		),

		"alerts"=list(
			list("alert" = "default",   "label" = "Nanotrasen",  "desc" = "О боже."),
			list("alert" = "redalert",  "label" = "Красная угроза",   "desc" = "Когда дела идут плохо."),
			list("alert" = "lockdown",  "label" = "Локдаун",    "desc" = "Сообщите всем, что они на карантине."),
			list("alert" = "biohazard", "label" = "Биоугроза",   "desc" = "Отлично подходит для вирусных вспышек и вечеринок."),
		)
	)

	data["security_level"] = GLOB.security_level
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green";
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue";
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red";
		else
			data["security_level_color"] = "purple";
	data["str_security_level"] = capitalize(get_security_level())

	var/list/msg_data = list()
	for(var/i = 1; i <= messagetext.len; i++)
		msg_data.Add(list(list("title" = messagetitle[i], "body" = messagetext[i], "id" = i)))

	data["messages"]        = msg_data

	data["current_message"] = null
	data["current_message_title"] = null
	if((data["is_ai"] && aicurrmsg) || (!data["is_ai"] && currmsg))
		data["current_message"] = data["is_ai"] ? messagetext[aicurrmsg] : messagetext[currmsg]
		data["current_message_title"] = data["is_ai"] ? messagetitle[aicurrmsg] : messagetitle[currmsg]

	data["lastCallLoc"]     = SSshuttle.emergencyLastCallLoc ? format_text(SSshuttle.emergencyLastCallLoc.name) : null
	data["msg_cooldown"] = message_cooldown ? (round((message_cooldown - world.time) / 10)) : 0
	data["cc_cooldown"] = centcomm_message_cooldown ? (round((centcomm_message_cooldown - world.time) / 10)) : 0

	var/secondsToRefuel = SSshuttle.secondsToRefuel()
	data["esc_callable"] = SSshuttle.emergency.mode == SHUTTLE_IDLE && !secondsToRefuel ? TRUE : FALSE
	data["esc_recallable"] = SSshuttle.emergency.mode == SHUTTLE_CALL ? TRUE : FALSE
	data["esc_status"] = FALSE
	if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		data["esc_status"] = SSshuttle.emergency.mode == SHUTTLE_CALL ? "ETA:" : "ОТЗЫВ:"
		data["esc_status"] += " [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"
	else if(secondsToRefuel)
		data["esc_status"] = "Дозаправка: [secondsToRefuel / 60 % 60]:[add_zero(num2text(secondsToRefuel % 60), 2)]"
	data["esc_section"] = data["esc_status"] || data["esc_callable"] || data["esc_recallable"] || data["lastCallLoc"]
	return data

/obj/machinery/computer/communications/ui_static_data(mob/user)
	var/list/data = list()

	data["levels"] = list(
		list("id" = SEC_LEVEL_GREEN, "name" = "Зелёный", "icon" = "dove"),
		list("id" = SEC_LEVEL_BLUE,  "name" = "Синий", "icon" = "eye"),
	)

	data["admin_levels"] = list(
		list("id" = SEC_LEVEL_RED, "name" = "Красный", "icon" = "exclamation"),
		list("id" = SEC_LEVEL_GAMMA,  "name" = "Гамма", "icon" = "biohazard"),
		list("id" = SEC_LEVEL_EPSILON, "name" = "Эпсилон", "icon" = "skull", "tooltip" = "Код Эпсилон активируется примерно через 15 секунд."),
		list("id" = SEC_LEVEL_DELTA,  "name" = "Дельта", "icon" = "bomb"),
	)

	return data

/obj/machinery/computer/communications/proc/setCurrentMessage(mob/user, value)
	if(isAI(user) || isrobot(user))
		aicurrmsg = value
	else
		currmsg = value

/obj/machinery/computer/communications/proc/getCurrentMessage(mob/user)
	if(isAI(user) || isrobot(user))
		return aicurrmsg
	else
		return currmsg

/obj/machinery/computer/communications/proc/setMenuState(mob/user, value)
	if(isAI(user) || isrobot(user))
		ai_menu_state=value
	else
		menu_state=value

/proc/call_shuttle_proc(mob/user, reason)
	if(!check_shuttle_ability(user))
		return

	SSshuttle.requestEvac(user, reason)
	add_game_logs("has called the shuttle: [reason]", user)
	message_admins("[key_name_admin(user)] has called the shuttle.")

	return

/proc/check_shuttle_ability(mob/user)
	if(GLOB.sent_strike_team == TRUE || GLOB.security_level == SEC_LEVEL_EPSILON)
		to_chat(user, "Вызов шаттла эвакуации невозможен. Все контракты считаются расторгнутыми.")
		return FALSE

	if(SSshuttle.hostile_environment.len)
		to_chat(user, span_warning("Обнаружена угроза на борту [station_name()]. Вызов шаттла заблокирован."))
		return FALSE

	if(SSshuttle.emergencyNoEscape)
		to_chat(user, "Вызов шаттла заблокирован. Свяжитесь с Центральным Командованием для уточнения причин и снятия блокировки.")
		return FALSE

	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		to_chat(user, span_warning("Эвакуационный шаттл не может быть вызван при возвращении на станцию Центрального Командования."))
		return FALSE

	if(world.time < 30 MINUTES) // 30 minute grace period to let the game get going
		to_chat(user, "Шаттл на дозаправке. Пожалуйста, подождите ещё [round((30 MINUTES-world.time)/600)] минут, прежде чем повторить попытку.")
		return FALSE

	return TRUE


/proc/init_shift_change(mob/user, force = 0)
	// if force is 0, some things may stop the shuttle call
	if(!force && !check_shuttle_ability(user))
		return

	if(seclevel2num(get_security_level()) >= SEC_LEVEL_RED) // There is a serious threat we gotta move no time to give them five minutes.
		SSshuttle.emergency.request(null, 0.5, null, " Автоматический Трансфер Экипажа", 1)
		SSshuttle.emergency.canRecall = FALSE
	else
		SSshuttle.emergency.request(null, 1, null, " Автоматический Трансфер Экипажа", 0)
		SSshuttle.emergency.canRecall = FALSE
	if(user)
		add_game_logs("has called the shuttle.", user)
		message_admins("[key_name_admin(user)] has called the shuttle - [formatJumpTo(user)].")
	return


/proc/cancel_call_proc(mob/user)
	if(GAMEMODE_IS_METEOR)
		return

	if(SSshuttle.cancelEvac(user))
		add_game_logs("has recalled the shuttle.", user)
		message_admins("[ADMIN_LOOKUPFLW(user)] has recalled the shuttle .")
	else
		to_chat(user, span_warning("Центральное Командование отклонило запрос об отзыве эвакуационного шаттла!"))
		add_game_logs("has tried and failed to recall the shuttle.", user)
		message_admins("[ADMIN_LOOKUPFLW(user)] has tried and failed to recall the shuttle.")


/proc/post_status(mode, data1, data2)
	if(usr && mode == STATUS_DISPLAY_MESSAGE)
		log_and_message_admins("set status screen message: [data1] [data2]")

	for(var/obj/machinery/status_display/display as anything in GLOB.status_displays)
		if(display.is_supply)
			continue

		display.set_mode(mode)
		switch(mode)
			if(STATUS_DISPLAY_MESSAGE)
				display.set_message(data1, data2)
			if(STATUS_DISPLAY_ALERT)
				display.set_picture(data1)

		display.update()


/obj/machinery/computer/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/obj/item/circuitboard/communications/New()
	GLOB.shuttle_caller_list += src
	..()

/obj/item/circuitboard/communications/Destroy()
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/proc/print_command_report(text = "", title = "Уведомление Центрального Командования", add_to_records = TRUE, var/datum/station_goal/goal = null)
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.stat & (BROKEN|NOPOWER)) && is_station_contact(C.z))
			var/obj/item/paper/P = new (C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			if(add_to_records)
				C.messagetitle.Add("[title]")
				C.messagetext.Add(text)
			if(goal)
				P.stamp(/obj/item/stamp/navcom)
				goal.papers_list.Add(P)

/proc/print_centcom_report(text = "", title = "Входящее сообщение")
	for(var/obj/machinery/computer/communications/C in GLOB.shuttle_caller_list)
		if(!(C.stat & (BROKEN|NOPOWER)) && is_admin_level(C.z))
			var/obj/item/paper/P = new /obj/item/paper(C.loc)
			P.name = "paper- '[title]'"
			P.info = text
			P.update_icon()
			C.messagetitle.Add("[title]")
			C.messagetext.Add(text)


