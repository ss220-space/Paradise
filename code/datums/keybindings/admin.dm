/datum/keybinding/admin
	category = KB_CATEGORY_ADMIN
	/// The rights to use with [/proc/check_rights] if any
	var/rights


/datum/keybinding/admin/can_use(client/user)
	if(rights && !check_rights(rights, FALSE))
		return FALSE
	return !isnull(user.holder)


/datum/keybinding/admin/mc_debug
	name = "MC Debug"
	keys = list("ShiftF3")
	rights = R_VIEWRUNTIMES|R_DEBUG


/datum/keybinding/admin/mc_debug/down(client/user)
	. = ..()
	if(.)
		return .
	if(user in SSdebugview.processing)
		SSdebugview.stop_processing(user)
	else
		SSdebugview.start_processing(user)
	return TRUE


/datum/keybinding/admin/aghost
	name = "Aghost"
	keys = list("F6")


/datum/keybinding/admin/aghost/down(client/user)
	. = ..()
	if(.)
		return .
	user.admin_ghost()
	return TRUE


/datum/keybinding/admin/player_panel
	name = "Player Panel"
	keys = list("F7")
	rights = R_ADMIN|R_MOD


/datum/keybinding/admin/player_panel/down(client/user)
	. = ..()
	if(.)
		return .
	user.holder.player_panel_new()
	return TRUE


/datum/keybinding/admin/apm
	name = "Admin PM"
	keys = list("F8")


/datum/keybinding/admin/apm/down(client/user)
	. = ..()
	if(.)
		return .
	user.cmd_admin_pm_panel()
	return TRUE


/datum/keybinding/admin/invisimin
	name = "Invisimin"
	keys = list("F9")


/datum/keybinding/admin/invisimin/down(client/user)
	. = ..()
	if(.)
		return .
	user.invisimin()
	return TRUE
