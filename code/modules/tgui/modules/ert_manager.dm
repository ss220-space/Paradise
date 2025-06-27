/datum/ui_module/ert_manager
	name = "ERT Manager"
	var/ert_type = "Red"
	var/commander_slots = 1 // defaults for open slots
	var/security_slots = 4
	var/medical_slots = 0
	var/engineering_slots = 0
	var/janitor_slots = 0
	var/paranormal_slots = 0
	var/cyborg_slots = 0

/datum/ui_module/ert_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/ert_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ERTManager", name)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/ert_manager/ui_data(mob/user)
	var/list/data = list()
	data["str_security_level"] = capitalize(get_security_level())
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green"
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue"
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red"
		else
			data["security_level_color"] = "purple"
	data["ert_request_answered"] = GLOB.ert_request_answered
	data["ert_type"] = ert_type
	data["com"] = commander_slots
	data["sec"] = security_slots
	data["med"] = medical_slots
	data["eng"] = engineering_slots
	data["jan"] = janitor_slots
	data["par"] = paranormal_slots
	data["cyb"] = cyborg_slots
	data["total"] = commander_slots + security_slots + medical_slots + engineering_slots + janitor_slots + paranormal_slots + cyborg_slots
	data["spawnpoints"] = GLOB.emergencyresponseteamspawn.len
	data["ert_request_messages"] = GLOB.ert_request_messages
	return data

/datum/ui_module/ert_manager/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("toggle_ert_request_answered")
			GLOB.ert_request_answered = !GLOB.ert_request_answered
		if("ert_type")
			ert_type = params["ert_type"]
		if("toggle_com")
			commander_slots = commander_slots ? 0 : 1
		if("set_sec")
			security_slots = text2num(params["set_sec"])
		if("set_med")
			medical_slots = text2num(params["set_med"])
		if("set_eng")
			engineering_slots = text2num(params["set_eng"])
		if("set_jan")
			janitor_slots = text2num(params["set_jan"])
		if("set_par")
			paranormal_slots = text2num(params["set_par"])
		if("set_cyb")
			cyborg_slots = text2num(params["set_cyb"])
		if("dispatch_ert")
			if(GLOB.send_emergency_team)
				to_chat(usr, span_warning("Центральное Командование уже направило Отряд Быстрого Реагирования!"))
				return
			var/datum/response_team/D
			switch(ert_type)
				if("Amber")
					D = new /datum/response_team/amber
				if("Red")
					D = new /datum/response_team/red
				if("Gamma")
					if(!check_rights(R_EVENT, TRUE, ui.user))
						to_chat(ui.user, span_warning("Вы не можете отправить ОБР кода Гамма."))
						return
					D = new /datum/response_team/gamma
				else
					to_chat(usr, span_userdanger("Неверный тип ОБР."))
					return
			GLOB.send_emergency_team = TRUE
			GLOB.ert_request_answered = TRUE
			var/slots_list = list()
			if(commander_slots > 0)
				slots_list += "командир: [commander_slots]"
			if(security_slots > 0)
				slots_list += "боец: [security_slots]"
			if(medical_slots > 0)
				slots_list += "медик: [medical_slots]"
			if(engineering_slots > 0)
				slots_list += "инженер: [engineering_slots]"
			if(janitor_slots > 0)
				slots_list += "уборщик: [janitor_slots]"
			if(paranormal_slots > 0)
				slots_list += "паранормал: [paranormal_slots]"
			if(cyborg_slots > 0)
				slots_list += "борг: [cyborg_slots]"
			D.silent = params["silent"]
			var/slot_text = english_list(slots_list)
			log_and_message_admins("dispatched a [params["silent"] ? "silent " : ""][ert_type] ERT. Slots: [slot_text]")
			if(!params["silent"])
				GLOB.event_announcement.Announce("Внимание, [station_name()]. Мы предпринимаем шаги для отправки отряда быстрого реагирования. Ожидайте.", "ВНИМАНИЕ: Активирован протокол ОБР.")
			trigger_armed_response_team(D, commander_slots, security_slots, medical_slots, engineering_slots, janitor_slots, paranormal_slots, cyborg_slots)

		if("view_player_panel")
			ui.user.client.holder.show_player_panel(locate(params["uid"]))

		if("deny_ert")
			GLOB.ert_request_answered = TRUE
			var/message = "[station_name()], к сожалению, в настоящее время мы не можем направить к вам отряд быстрого реагирования."
			if(params["reason"])
				message += " Ваш запрос ОБР был отклонен по следующим причинам:\n[params["reason"]]"
			GLOB.event_announcement.Announce(message, "Оповещение: ОБР недоступен.")
		else
			return FALSE

