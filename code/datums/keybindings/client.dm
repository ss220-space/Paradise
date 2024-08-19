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

