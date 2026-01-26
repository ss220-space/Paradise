ADMIN_VERB(centcom_podlauncher, R_EVENT, "Launch Supplypod", "Настройте и запустите капсулу снабжения, полную всего, что душе угодно!", ADMIN_CATEGORY_EVENTS)
	if(!SSticker)
		to_chat(user, span_warning("Игра ещё не началась!"))
		return

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		to_chat(user, span_warning("Раунд ещё не начался!"))
		return

	var/datum/centcom_podlauncher/centcom_podlauncher = new(user.mob)
	centcom_podlauncher.ui_interact(user.mob)
