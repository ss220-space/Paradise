/client/verb/webmap()
	set name = "webmap"
	set hidden = TRUE

	if(!SSmapping.map_datum.webmap_url)
		to_chat(usr, span_warning("У текущей карты нет веб-версии. Пожалуйста, сообщите об этом разработчикам в Discord."))
		return

	if(tgui_alert(usr, "Вы хотите открыть веб-версию этой карты в своём веб-браузере?", "Веб-карта", list("Да", "Нет")) != "Да")
		return

	usr << link(SSmapping.map_datum.webmap_url)
