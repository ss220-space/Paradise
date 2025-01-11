/client/proc/centcom_podlauncher()
	set name = "Launch Supplypod"
	set category = "Event"
	set desc = "Настройте и запустите капсулу снабжения, полную всего, что душе угодно!"

	if(!check_rights(R_EVENT))
		return

	if(!SSticker)
		to_chat(usr, span_warning("Игра еще не началась!"))
		return

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		to_chat(usr, span_warning("Раунд еще не начался!"))
		return

	var/datum/centcom_podlauncher/E = new(src.mob)
	E.ui_interact(usr)
