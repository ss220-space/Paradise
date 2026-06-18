/client/verb/request_internet_sound()
	set name = "Заказать музыку"
	set category = VERB_CATEGORY_OOC

	if(!CONFIG_GET(flag/request_internet_sound))
		to_chat(src, span_danger("Заказ музыки на этом сервере отключён."), confidential = TRUE)
		return

	if(!CONFIG_GET(string/invoke_youtubedl))
		to_chat(src, span_danger("Заказ музыки недоступен: yt-dlp не настроен."), confidential = TRUE)
		return

	var/allowed_sites = CONFIG_GET(string/request_internet_allowed)
	var/sites_display = replacetext(replacetext(allowed_sites, "\\", ""), ",", ", ")
	var/request_url = tgui_input_text(src, "Введите URL. Поддерживаемые источники: [sites_display].", "Заказ музыки", encode = FALSE)
	if(!request_url)
		return
	request_url = trim(request_url)

	if(findtext(request_url, ":") && !findtext(request_url, GLOB.is_http_protocol))
		to_chat(src, span_danger("Разрешены только http(s) ссылки."), confidential = TRUE)
		return

	var/regex/allowed_regex = regex(replacetext(allowed_sites, ",", "|"), "i")
	if(!allowed_regex.Find(request_url))
		to_chat(src, span_danger("Недопустимый URL. Используйте ссылку с одного из сайтов: [sites_display]"), confidential = TRUE)
		return

	if(check_mute(ckey, MUTE_INTERNET_REQUEST))
		to_chat(src, span_danger("Вы не можете заказывать музыку (заглушено)."), confidential = TRUE)
		return

	var/credit = tgui_alert(src, "Указать вас как заказавшего? (будет показано как [ckey])", "Указывать себя?", list("Нет", "Да", "Отмена"))
	if(credit == "Отмена" || isnull(credit))
		return
	credit = (credit == "Да") ? ckey : null

	if(handle_spam_prevention(request_url, MUTE_INTERNET_REQUEST, OOC_COOLDOWN))
		return

	var/mob/requester = mob
	add_game_logs("Requested internet sound: [request_url]", requester)
	GLOB.requests.music_request(src, request_url)

	var/display_url = html_encode(request_url)
	var/list/admin_message = list()
	admin_message += "[ADMIN_FULLMONTY(requester)] ([ADMIN_SC(requester, "SC")]) заказал(а) к проигрыванию:<br>"
	admin_message += "[span_linkify(display_url)] [ADMIN_PLAY_INTERNET(request_url, credit)]"

	var/list/admins = get_holders_with_rights(R_SOUNDS)
	for(var/client/holder in admins)
		to_chat(holder, fieldset_block(span_bold("Заказ музыки"), jointext(admin_message, ""), "boxed_message"), confidential = TRUE)
		if(holder.prefs.sound & SOUND_ADMINHELP)
			SEND_SOUND(holder, sound('sound/effects/internet_request.ogg'))

	to_chat(src, span_notice("Вы заказали [span_linkify(display_url)]. Запрос отправлен администрации."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "music_request", 1, "Music Request")
