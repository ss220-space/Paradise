#define VV_HK_GIVE_DEADCHAT_CONTROL "grantdeadchatcontrol"
#define VV_HK_REMOVE_DEADCHAT_CONTROL "removedeadchatcontrol"

/atom/movable/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /movable ---")
	if(!GetComponent(/datum/component/deadchat_control))
		VV_DROPDOWN_OPTION(VV_HK_GIVE_DEADCHAT_CONTROL, "Give deadchat control")
	else
		VV_DROPDOWN_OPTION(VV_HK_REMOVE_DEADCHAT_CONTROL, "Remove deadchat control")

/atom/movable/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list["grantdeadchatcontrol"])
		if(!check_rights(R_EVENT))
			return

		if(!CONFIG_GET(flag/dsay_allowed))
			// TODO verify what happens when deadchat is muted
			to_chat(usr, span_warning("Дедчат глобально отключён, включите его перед тем как включать это."))
			return

		if(GetComponent(/datum/component/deadchat_control))
			to_chat(usr, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] уже находится под контролем призраков!"))
			return

		var/control_mode = tgui_input_list(usr, "Выберите режим управления","Тип управления", list("демократия", "анархия"), null)

		var/selected_mode
		switch(control_mode)
			if("демократия")
				selected_mode = DEADCHAT_DEMOCRACY_MODE
			if("анархия")
				selected_mode = DEADCHAT_ANARCHY_MODE
			else
				return

		var/cooldown = tgui_input_number(usr, "Пожалуйста, введите время между действиями в секундах. Для демократии это время между действиями (должно быть больше нуля). Для анархии это время между действиями каждого пользователя или -1, если время между ними отсутствует.", "Время между действиями", 0)
		if(isnull(cooldown) || (cooldown == -1 && selected_mode == DEADCHAT_DEMOCRACY_MODE))
			return
		if(cooldown < 0 && selected_mode == DEADCHAT_DEMOCRACY_MODE)
			to_chat(usr, span_warning("Время между действиями режима демократии должно быть больше нуля."))
			return
		if(cooldown == -1)
			cooldown = 0
		else
			cooldown = cooldown SECONDS

		deadchat_plays(selected_mode, cooldown)
		log_and_message_admins("provided deadchat control to [src].")

	if(href_list["removedeadchatcontrol"])
		if(!check_rights(R_EVENT))
			return

		if(!GetComponent(/datum/component/deadchat_control))
			to_chat(usr, "[DECLENT_RU_CAP(src, NOMINATIVE)] больше не находится под контролем призраков!")
			return

		stop_deadchat_plays()
		log_and_message_admins("removed deadchat control from [src].")

#undef VV_HK_GIVE_DEADCHAT_CONTROL
#undef VV_HK_REMOVE_DEADCHAT_CONTROL
