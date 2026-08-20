/datum/keybinding/client

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
	if(user.mob.hud_used)
		user.mob.hud_used.show_hud() //Shows the next hud preset
		to_chat(user, span_notice("Изменён режим HUD. Переключение — клавиша F12."))
	else
		to_chat(user, span_warning("У этого типа существ нет HUD."))

	return TRUE

