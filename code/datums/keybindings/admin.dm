/datum/keybinding/admin
	abstract_type = /datum/keybinding/admin
	category = KB_CATEGORY_ADMIN
	weight = WEIGHT_ADMIN
	/// The rights to use with [/proc/check_rights] if any
	var/rights

/datum/keybinding/admin/can_use(client/user)
	if(rights && !check_rights(rights, FALSE))
		return FALSE
	return !isnull(user.holder)

/datum/keybinding/admin/mc_debug
	name = "mc_debug"
	full_name = "MC Debug"
	hotkey_keys = list("ShiftF3")
	rights = R_VIEWRUNTIMES|R_DEBUG
	keybind_signal = COMSIG_KB_ADMIN_MC_DEBUG

/datum/keybinding/admin/mc_debug/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	if(user in SSdebugview.processing)
		SSdebugview.stop_processing(user)
	else
		SSdebugview.start_processing(user)
	return TRUE

/datum/keybinding/admin/aghost
	name = "admin_ghost"
	full_name = "Aghost"
	description = "Go ghost"
	hotkey_keys = list("F6")
	keybind_signal = COMSIG_KB_ADMIN_AGHOST_DOWN
	rights = R_ADMIN|R_POSSESS

/datum/keybinding/admin/aghost/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)
	return TRUE

/datum/keybinding/admin/player_panel
	name = "player_panel"
	full_name = "Player Panel"
	description = "Opens up the player panel"
	hotkey_keys = list("F7")
	rights = R_ADMIN|R_MOD
	keybind_signal = COMSIG_KB_ADMIN_PLAYERPANELNEW_DOWN

/datum/keybinding/admin/player_panel/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/player_panel_veth)
	return TRUE

/datum/keybinding/admin/toggle_buildmode_self
	hotkey_keys = list("ShiftF7")
	name = "toggle_buildmode_self"
	full_name = "Toggle Buildmode Self"
	description = "Toggles buildmode"
	keybind_signal = COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN
	rights = R_BUILDMODE

/datum/keybinding/admin/toggle_buildmode_self/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/build_mode_self)
	return TRUE

/datum/keybinding/admin/stealthmode
	hotkey_keys = list("CtrlF8")
	name = "stealth_mode"
	full_name = "Stealth mode"
	description = "Enters stealth mode"
	keybind_signal = COMSIG_KB_ADMIN_STEALTHMODETOGGLE_DOWN
	rights = R_ADMIN|R_PERMISSIONS

/datum/keybinding/admin/stealthmode/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, (check_rights(R_PERMISSIONS, FALSE))? /datum/admin_verb/big_brother : /datum/admin_verb/stealth_mode)
	return TRUE

/datum/keybinding/admin/apm
	name = "admin_pm"
	full_name = "Admin PM"
	description = "Sends private message to user"
	hotkey_keys = list("F8")
	keybind_signal = COMSIG_KB_ADMIN_PM

/datum/keybinding/admin/apm/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/cmd_admin_pm_panel)
	return TRUE

/datum/keybinding/admin/invisimin
	name = "invisimin"
	full_name = "Admin invisibility"
	description = "Toggles ghost-like invisibility (Don't abuse this)"
	hotkey_keys = list("F9")
	keybind_signal = COMSIG_KB_ADMIN_INVISIMINTOGGLE_DOWN

/datum/keybinding/admin/invisimin/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/invisimin)
	return TRUE

/datum/keybinding/admin/view_tags
	name = "view_tags"
	full_name = "View Tags"
	description = "Open the View-Tags menu"
	hotkey_keys = list("F3")
	rights = R_ADMIN|R_DEBUG
	keybind_signal = COMSIG_KB_ADMIN_VIEWTAGS_DOWN

/datum/keybinding/admin/view_tags/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/display_tags)
	return TRUE

/datum/keybinding/admin/deadmin
	hotkey_keys = list(UNBOUND_KEY)
	name = "deadmin"
	full_name = "Deadmin"
	description = "Shed your admin powers"
	keybind_signal = COMSIG_KB_ADMIN_DEADMIN_DOWN

/datum/keybinding/admin/deadmin/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/deadmin_self)
	return TRUE

/datum/keybinding/admin/readmin
	hotkey_keys = list(UNBOUND_KEY)
	name = "readmin"
	full_name = "Readmin"
	description = "Regain your admin powers"
	keybind_signal = COMSIG_KB_ADMIN_READMIN_DOWN

/datum/keybinding/admin/readmin/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	user.readmin()
	return TRUE


/datum/keybinding/admin/admin_verb_panel
	hotkey_keys = list("`")
	name = "admin_verb_panel"
	full_name = "Admin Verb Panel"
	description = "Opens the admin verb panel"
	keybind_signal = COMSIG_KB_ADMIN_VERBPANEL_DOWN

/datum/keybinding/admin/admin_verb_panel/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_verb_panel)
	return TRUE
