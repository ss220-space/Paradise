/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/* check_grep:ignore */ /client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_tgui_panel()
	set name = "Починить чат"
	set category = STATPANEL_SPECIALVERBS
	var/action
	log_tgui(src, "Started fixing.")

	nuke_chat()

	// Failed to fix
	action = alert(src, "Сработало?", "", "Да", "Нет, переключить на старый интерфейс")
	if(action == "Нет, переключить на старый интерфейс")
		winset(src, "output_selector.legacy_output_selector", "left=output_legacy")
		log_tgui(src, "Failed to fix.")

/client/proc/nuke_chat()
	// Catch all solution (kick the whole thing in the pants)
	winset(src, "output_selector.legacy_output_selector", "left=output_legacy")
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel datum is missing")
		tgui_panel = new(src, "chat_panel")
	tgui_panel.initialize(force = TRUE)
	sleep(3 SECONDS)
	// Force show the panel to see if there are any errors
	winset(src, "output_selector.legacy_output_selector", "left=output_browser")

/client/verb/refresh_tgui()
	set name = "Обновить TGUI"
	set category = STATPANEL_SPECIALVERBS

	var/choice = alert(usr,
		"Используйте ЭТО ТОЛЬКО если у вас проблемы с окнами TGUI.\n\
		Это те интерфейсы, у которых в верхнем левом углу.\n\
		Иначе вы можете получить белое окно, которое закроется только после перезапуска игры!",
		"Обновить TGUI",
		"Обновить",
		"Отмена")
	if(choice != "Обновить")
		return
	var/refreshed_count = 0
	for(var/window_id in tgui_windows)
		var/datum/tgui_window/window = tgui_windows[window_id]
		if(!window.locked)
			window.acquire_lock()
			continue
		window.reinitialize()
		refreshed_count++
	to_chat(usr, span_notice("Окон TGUI обновлено - [refreshed_count].<br>Если появилось пустое окно - перезапустите игру или откройте предыдущее окно TGUI."))

