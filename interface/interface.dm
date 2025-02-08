//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Напишите, о чём вы хотите узнать. Это откроет соответствующую страницу Вики в вашем веб-браузере."
	set hidden = 1
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

/client/verb/forum()
	set name = "forum"
	set desc = "Посетить форум."
	set hidden = 1
	if(CONFIG_GET(string/forumurl))
		if(tgui_alert(src, "Открыть форум в вашем веб-браузере?", "Форум", list("Да", "Нет")) != "Да")
			return
		if(CONFIG_GET(string/forum_link_url) && prefs && !prefs.fuid)
			link_forum_account()
		src << link(CONFIG_GET(string/forumurl))
	else
		to_chat(src, span_danger("В конфиге отсутствует URL-адрес форума."))

/client/verb/rules()
	set name = "Правила"
	set desc = "Посмотреть правила сервера."
	set hidden = 1
	if(CONFIG_GET(string/rulesurl))
		if(tgui_alert(src, "В вашем веб-браузере откроется страница с правилами сервера. Продолжить?", "Правила", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/rulesurl))
	else
		to_chat(src, span_danger("В конфиге отсутствует URL-адрес страницы с правилами."))

/client/verb/github()
	set name = "GitHub"
	set desc = "Посмотреть GitHub репозиторий."
	set hidden = 1
	if(CONFIG_GET(string/githuburl))
		if(tgui_alert(src, "В вашем веб-браузере откроется GitHub репозиторий сервера. Продолжить?", "GitHub", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/githuburl))
	else
		to_chat(src, span_danger("В конфиге отсутствует URL-адрес репозитория сервера."))

/client/verb/discord()
	set name = "Discord"
	set desc = "Присоединиться к Discord-серверу проекта."
	set hidden = 1

	var/durl = CONFIG_GET(string/discordurl)
	if(CONFIG_GET(string/forum_link_url) && prefs && prefs.fuid && CONFIG_GET(string/discordforumurl))
		durl = CONFIG_GET(string/discordforumurl)
	if(!durl)
		to_chat(src, span_danger("В конфиге отсутствует URL-адрес Discord-сервера проекта."))
		return
	if(tgui_alert(src, "В вашем веб-браузере откроется страница с приглашением на Discord-сервер проекта. Продолжить?", "Discord", list("Да", "Нет")) != "Да")
		return
	src << link(durl)

/client/verb/donate()
	set name = "Пожертвовать"
	set desc = "Пожертвуйте нам, чтобы помочь нам с хостом сервера."
	set hidden = 1
	if(CONFIG_GET(string/donationsurl))
		if(tgui_alert(src, "В вашем веб-браузере откроется страница с пожертвованиями проекту. Продолжить?", "Пожертвование", list("Да", "Нет")) != "Да")
			return
		src << link(CONFIG_GET(string/donationsurl))
	else
		to_chat(src, span_danger("В вашем веб-браузере откроется страница для пожертвований на хост сервера. Продолжить?"))
