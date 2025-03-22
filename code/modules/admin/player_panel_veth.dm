
/datum/admins/proc/player_panel_veth()//The new one
	if(!usr.client.holder)
		return
	// This stops the panel from being invoked by mentors who press F7.
	if(!check_rights(R_ADMIN|R_MOD))
		message_admins("[key_name_admin(usr)] attempted to invoke player panel without admin rights. If this is a mentor, \
		its a chance they accidentally hit F7. If this is NOT a mentor, there is a high chance an exploit is being used")
		return

	var/datum/player_panel_veth/tgui = new(usr)
	tgui.ui_interact(usr)


/datum/player_panel_veth/ //required for tgui component
	var/title = "Veth's Ultimate Player Panel"

/datum/player_panel_veth/ui_data(mob/user)
	var/list/players = list()
	for(var/mob/M in GLOB.mob_list)
		if (M.ckey)
			players += list(list(
				"name" = M.name || "No Character",
				"job" = M.job || "No Job",
				"ckey" = M.ckey || "No Ckey",
				"is_antagonist" = M.mind?.special_role,
				"last_ip" = M.lastKnownIP || "No Last Known IP",
				"ref" = M.UID()
			))
	return list(
		"Data" = players
	)

/datum/player_panel_veth/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	var/mob/M = get_mob_by_ckey(params["selectedPlayerCkey"]) //gets the mob datum from the ckey in client datum which we've saved. if there's a better way to do this please let me know
	switch(action) //switch for all the actions from the frontend - all of the Topic() calls check rights & log inside themselves.
		if("refresh")
			ui.send_update()
		if("sendPrivateMessage")
			usr.client.cmd_admin_pm(M.ckey)
		if("follow")
			usr.client.holder.Topic(null, list("adminplayerobservefollow" = M.UID()))
		if("smite")
			usr.client.holder.Topic(null, list("Smite" = M.UID()))
		if("checkAntags")
			usr.client.check_antagonists()
		if("faxPanel")
			usr.client.fax_panel()
		if("gamePanel")
			usr.client.game_panel()
		if("openAdditionalPanel")
			usr.client.holder.vuap_open(params["selectedPlayerCkey"], M)
		if("createCommandReport")
			usr.client.cmd_admin_create_centcom_report()
		if("logs")
			usr.client.holder.Topic(null, list("open_logging_view" = M.UID()))
		if("notes")
			usr.client.holder.Topic(null, list("shownoteckey" = M.ckey))
		if("vv")
			usr.client.debug_variables(M)
		if("tp")
			usr.client.holder.Topic(null, list("traitor" = M.UID()))
		if("adminaiinteract")
			usr.client.toggle_advanced_interaction()

/datum/player_panel_veth/ui_interact(mob/user, datum/tgui/ui)

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "VethPlayerPanel", title)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/player_panel_veth/ui_status(mob/user, datum/ui_state/state)
	. = (check_rights(R_ADMIN | R_MOD, user = user)) ? UI_INTERACTIVE : ..()

/datum/player_panel_veth/ui_state(mob/user)
	return GLOB.admin_state
