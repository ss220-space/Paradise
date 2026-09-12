//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
GAME_VERB_HIDDEN(/client, wiki, "wiki")
	if(CONFIG_GET(string/wikiurl))
		var/query = tgui_input_text(src, "Что вы хотите найти?", "Поиск на Вики", "Главная страница")
		if(query == "Главная страница")
			src << link(CONFIG_GET(string/wikiurl))
		else if(query)
			var/output = CONFIG_GET(string/wikiurl) + "/index.php?title=Special%3ASearch&profile=default&search=" + query
			src << link(output)
	else
		to_chat(src, span_danger("В конфиге отсутствует URL-адрес Вики."))
	return

GAME_VERB_HIDDEN(/client, rules, "rules")
	if(CONFIG_GET(string/rulesurl))
		if(tgui_alert(src, "В вашем веб-браузере откроется страница с правилами сервера. Продолжить?", "Правила", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/rulesurl))
	else
		to_chat(src, span_danger("В конфиге отсутствует URL-адрес страницы с правилами."))

GAME_VERB_HIDDEN(/client, github, "github")
	if(CONFIG_GET(string/githuburl))
		if(tgui_alert(src, "В вашем веб-браузере откроется GitHub репозиторий сервера. Продолжить?", "GitHub", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/githuburl))
	else
		to_chat(src, span_danger("В конфиге отсутствует URL-адрес репозитория сервера."))

GAME_VERB_HIDDEN(/client, discord, "Discord")

	var/durl = CONFIG_GET(string/discordurl)
	if(CONFIG_GET(string/forum_link_url) && prefs && prefs.fuid && CONFIG_GET(string/discordforumurl))
		durl = CONFIG_GET(string/discordforumurl)
	if(!durl)
		to_chat(src, span_danger("В конфиге отсутствует URL-адрес Discord-сервера проекта."))
		return
	if(tgui_alert(src, "В вашем веб-браузере откроется страница с приглашением на Discord-сервер проекта. Продолжить?", "Discord", list("Да", "Нет")) != "Да")
		return
	src << link(durl)

GAME_VERB_HIDDEN(/client, donate, "Пожертвовать")
	if(CONFIG_GET(string/donationsurl))
		if(tgui_alert(src, "В вашем веб-браузере откроется страница с пожертвованиями проекту. Продолжить?", "Пожертвование", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/donationsurl))
	else
		to_chat(src, span_danger("В вашем веб-браузере откроется страница для пожертвований на хост сервера. Продолжить?"))

GAME_VERB_HIDDEN(/client, reportissue, "Баг репорт")

	if(CONFIG_GET(string/discordbugreporturl))
		if(tgui_alert(src, "В вашем веб-браузере откроется страница, которая перенесёт вас в дискорд канал с баг репортами. Продолжить?", "Баг репорт", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/discordbugreporturl))
	else
		to_chat(src, span_danger("В конфигурации сервера отсутствует URL-адрес для баг-репортов"))

GAME_VERB_HIDDEN(/client, hotkeys_help, "Hotkeys Help")

	if(!GLOB.hotkeys_tgui)
		GLOB.hotkeys_tgui = new /datum/hotkeys_help()

	GLOB.hotkeys_tgui.ui_interact(mob)

GAME_VERB_HIDDEN(/client, emote_panel, "Emote Panel")

	if(!isliving(mob) && !isobserver(mob))
		to_chat(mob, span_notice("Вам не доступны эмоции!"))
		return

	if(!GLOB.emote_panel)
		GLOB.emote_panel = new /datum/emote_panel()
	GLOB.emote_panel.ui_interact(mob)
