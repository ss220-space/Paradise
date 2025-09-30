/datum/admins/proc/custom_allow_panel()//The new one
	if(!usr.client.holder)
		return
	// This stops the panel from being invoked by mentors who press F7.
	if(!check_rights(R_ADMIN|R_MOD))
		message_admins("[key_name_admin(usr)] attempted to invoke custom allower panel without admin rights. \
		If this is NOT a mentor, there is a high chance an exploit is being used")
		return

	var/datum/custom_allower/tgui = new(usr)
	tgui.ui_interact(usr)


/datum/custom_allower
	var/title = "Custom Allower"
	/// Selected custom
	var/choosen_ckey
	/// Ref to screen object that displays in the middle of the UI
	var/atom/movable/screen/map_view/ui_view
	/// Atom ref witch we use to show image to user
	var/atom/movable/manequien

/datum/custom_allower/New()
	. = ..()
	ui_view = new
	ui_view.generate_view("custom_allower_[UID()]")

/datum/custom_allower/ui_data(mob/user)
	var/list/data = list()
	data["ckeys"] = GLOB.temp_custom_holders
	ui_view.appearance = appearance
	data["custom_view"] = ui_view.assigned_map
	var/datum/custom_holder/holder = GLOB.temp_custom_holders?[choosen_ckey]
	data["name"] = holder ? holder.name : ""
	data["desc"] = holder ? holder.desc : ""

/datum/custom_allower/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return

/datum/custom_allower/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "CustomAllower", title)
		ui.set_autoupdate(FALSE)
		ui_view.display_to(user, ui.window)
		ui.open()

/datum/custom_allower/ui_close(mob/user)
	. = ..()
	ui_view.hide_from(user)

/datum/custom_allower/ui_status(mob/user, datum/ui_state/state)
	. = (check_rights(R_ADMIN | R_MOD, user = user)) ? UI_INTERACTIVE : ..()

/datum/custom_allower/ui_state(mob/user)
	return GLOB.admin_state
