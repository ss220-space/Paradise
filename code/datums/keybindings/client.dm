/datum/keybinding/client
	category = KB_CATEGORY_UNSORTED


/datum/keybinding/client/admin_help
	name = "Admin Help"
	keys = list("F1")


/datum/keybinding/client/admin_help/down(client/user)
	. = ..()
	if(.)
		return .
	user.adminhelp()
	return TRUE


/datum/keybinding/client/ooc
	name = "OOC"
	keys = list("F2", "O")


/datum/keybinding/client/ooc/down(client/user)
	. = ..()
	if(.)
		return .
	user.ooc()
	return TRUE


/datum/keybinding/client/looc
	name = "Локальный OOC"
	keys = list("L")


/datum/keybinding/client/looc/down(client/user)
	. = ..()
	if(.)
		return .
	user.looc()
	return TRUE


/datum/keybinding/client/say
	name = "Say"
	keys = list("F3", "T")


/datum/keybinding/client/say/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.say_wrapper()
	return TRUE


/datum/keybinding/client/me
	name = "Me"
	keys = list("F4", "M")


/datum/keybinding/client/me/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.me_wrapper()
	return TRUE


/datum/keybinding/client/t_fullscreen
	name = "Переключить Fullscreen"
	keys = list("F11")


/datum/keybinding/client/t_fullscreen/down(client/user)
	. = ..()
	if(.)
		return .
	user.toggle_fullscreen()
	return TRUE


/datum/keybinding/client/toggle_min_hud
	name = "Переключить минимальный HUD"
	keys = list("F12")


/datum/keybinding/client/toggle_min_hud/down(client/user)
	. = ..()
	if(.)
		return .
	user.mob.button_pressed_F12()
	return TRUE

