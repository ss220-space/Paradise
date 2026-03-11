/datum/escape_menu/proc/show_home_page()
	page_holder.give_protected_screen_object(give_escape_menu_title())
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Продолжить",
			/* offset = */ list(-136, 30),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(home_resume)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Персонаж",
			/* offset = */ list(-171, 28),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(home_open_character_settings)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Настройки",
			/* offset = */ list(-206, 30),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(home_open_game_settings)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable/admin_help(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Помощь админа",
			/* offset = */ list(-241, 30),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable/leave_body(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Покинуть тело",
			/* offset = */ list(-276, 30),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(open_leave_body)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Выйти",
			/* offset = */ list(-311, 30),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(quit_game_prompt)),
		)
	)

	//Bottom right buttons, from right to left, starting with the button to open the list.
	page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small(
		null,
		/* hud_owner = */ null,
		"Ссылки",
		"Открыть/Закрыть список полезных ссылок",
		/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
		CALLBACK(src, PROC_REF(toggle_resources)),
		/* button_overlay = */ "resources",
	))

/datum/escape_menu/proc/toggle_resources()
	show_resources = !show_resources
	if(!show_resources)
		//collapsing it
		for(var/atom/movable/screen/escape_menu/lobby_button/small/collapsible/button as anything in resource_panels)
			button.collapse(page_holder)
		resource_panels.Cut()
		return
	//list of offsets we give, so missing icons don't leave a random gap.
	var/list/offset_order = list(
		-60,
		-120,
		-180,
		-240,
		-300,
		-360,
		-420,
		-480,
	)
	resource_panels = list()

	var/discordbugreporturl = CONFIG_GET(string/discordbugreporturl)
	if(discordbugreporturl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Баг репорт",
			"Сообщить о баге",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, reportissue)),
			/* button_overlay = */ "bug",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]

	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Github",
			"Открыть репозиторий игры",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, github)),
			/* button_overlay = */ "github",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]

	var/forumurl = CONFIG_GET(string/discordurl)
	if(forumurl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Дискорд",
			"Присоединиться к Discord-серверу проекта.",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, discord)),
			/* button_overlay = */ "discord",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]

	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Правила",
			"Посмотреть правила сервера",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, rules)),
			/* button_overlay = */ "rules",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]

	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Вики",
			"Посмотреть вики по игре",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, wiki)),
			/* button_overlay = */ "wiki",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]


	var/mapurl = SSmapping.map_datum.webmap_url
	if(mapurl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Карта",
			"Посмотреть текущую карту",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, webmap)),
			/* button_overlay = */ "map",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]
	/*
	var/configurl = CONFIG_GET(string/configurl)
	if(configurl)
		resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
			null,
			/* hud_owner = */ null,
			"Config",
			"View the server configuration files",
			/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
			CALLBACK(client, TYPE_VERB_REF(/client, config)),
			/* button_overlay = */ "config",
			/* end_point */ offset_order[1],
		))
		offset_order -= offset_order[1]
	*/
	resource_panels += page_holder.give_screen_object(new /atom/movable/screen/escape_menu/lobby_button/small/collapsible(
		null,
		/* hud_owner = */ null,
		"Ченжлог",
		"Посмотреть список изменений в билде",
		/* button_screen_loc */ "BOTTOM:30,RIGHT:-20",
		CALLBACK(client, TYPE_VERB_REF(/client, changelog)),
		/* button_overlay = */ "changelog",
		/* end_point */ offset_order[1],
	))

/datum/escape_menu/proc/home_resume()
	qdel(src)

/datum/escape_menu/proc/home_open_character_settings()
	if(!client)
		return
	client.prefs.current_tab = TAB_CHAR
	client.prefs.ShowChoices(client.mob)

/datum/escape_menu/proc/home_open_game_settings()
	if(!client)
		return
	client.prefs.current_tab = TAB_GAME
	client.prefs.ShowChoices(client.mob)
