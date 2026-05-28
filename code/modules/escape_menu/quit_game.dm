/datum/escape_menu/proc/show_quit_game_page()
	PRIVATE_PROC(TRUE)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/center(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Вы уверены, что \n хотите выйти?",
			/* offset = */ list(-160, -80),
			/* font_size = */ 24,
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable/center(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Да",
			/* offset = */ list(-250, -60),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(quit_game)),
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/text/clickable/center(
			null,
			/* hud_owner = */ null,
			/* escape_menu = */ src,
			/* button_text = */ "Нет",
			/* offset = */ list(-250, 60),
			/* font_size = */ 24,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(open_home_page)),
		)
	)

/datum/escape_menu/proc/quit_game()
	PRIVATE_PROC(TRUE)

	winset(usr, null, list("command"=".quit"))
