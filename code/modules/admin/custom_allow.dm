/datum/admins/proc/custom_allow_panel()
	set category = "Admin"
	set name = "Show Custom Allow Panel"
	set desc = ""

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
	///
	var/datum/custom_holder/choosen_holder
	///
	var/choosen_icon

/datum/custom_allower/New()
	. = ..()
	ui_view = new
	ui_view.generate_view("custom_allower_[UID()]")

/datum/custom_allower/ui_data(mob/user)
	var/list/data = list()
	data["ckeys"] = GLOB.temp_custom_holders
	data["choosen_ckey"] = choosen_ckey ? choosen_ckey : ""
	ui_view.appearance = manequien?.appearance
	data["custom_view"] = ui_view.assigned_map
	data["sprite_types"] = choosen_holder ? choosen_holder.icons : list()
	data["choosen_icon"] = choosen_icon ? choosen_icon : ""
	data["name"] = choosen_holder ? choosen_holder.name : ""
	data["desc"] = choosen_holder ? choosen_holder.desc : ""
	return data

/datum/custom_allower/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	switch(action)
		if("select_user")
			choosen_ckey = params["ckey"]
			if(!LAZYIN(GLOB.temp_custom_holders, choosen_ckey))
				return
			choosen_holder = GLOB.temp_custom_holders[choosen_ckey]
			choosen_icon = choosen_holder.icons[1]
			make_manequien()
		if("select_icon")
			choosen_icon = params["icon_name"]
			make_manequien()

/datum/custom_allower/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "CustomAllower", title)
		ui.set_autoupdate(TRUE)
		ui.open()
		ui_view.display_to(user, ui.window)

/datum/custom_allower/ui_close(mob/user)
	. = ..()
	ui_view.hide_from(user)

/datum/custom_allower/ui_status(mob/user, datum/ui_state/state)
	. = (check_rights(R_ADMIN | R_MOD, user = user)) ? UI_INTERACTIVE : ..()

/datum/custom_allower/ui_state(mob/user)
	return GLOB.admin_state

/datum/custom_allower/proc/make_manequien()
	if(!choosen_holder || !choosen_icon)
		return
	qdel(manequien)
	switch(choosen_icon)
		if("base")
			var/obj/item/thing = new
			thing.icon = choosen_holder.icons[choosen_icon]
			thing.icon_state = choosen_holder.ckey
			manequien = thing
		if("inhand_l")
			var/mob/living/carbon/human/human_to_show = new
			var/obj/item/thing = new
			thing.lefthand_file = choosen_holder.icons[choosen_icon]
			thing.item_state = choosen_holder.ckey
			human_to_show.put_in_l_hand(thing, TRUE, TRUE, TRUE)
			manequien = human_to_show
		if("inhand_r")
			var/mob/living/carbon/human/human_to_show = new
			var/obj/item/thing = new
			thing.righthand_file = choosen_holder.icons[choosen_icon]
			thing.item_state = choosen_holder.ckey
			human_to_show.put_in_r_hand(thing, TRUE, TRUE, TRUE)
			manequien = human_to_show

