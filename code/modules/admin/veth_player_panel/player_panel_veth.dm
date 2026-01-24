ADMIN_VERB(player_panel_veth, R_ADMIN|R_MOD, "Player Panel Veth", "Updated Player Panel with TGUI.", ADMIN_CATEGORY_GAME)
	var/datum/player_panel_veth/tgui = new(user.mob)
	tgui.ui_interact(user.mob)
	to_chat(user, span_interface("VUAP has been opened!"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("VUAP")

/datum/player_panel_veth/ /* required for tgui component */

/datum/player_panel_veth/proc/player_ui_data(mob/player)
#ifndef TESTING
	if(QDELETED(player) || !player.ckey)
#else
	if(QDELETED(player) || !player.mind) // if TESTING is enabled, this lets us test with a spawned debug crew
#endif
		return
	return list(
		"name" = player.name,
		"job" = player.job,
		"ckey" = player.ckey,
		"is_antagonist" = is_special_character(player),
		"last_ip" = player.lastKnownIP,
		"ref" = player.UID()
	)

/datum/player_panel_veth/ui_data(mob/user)
	var/list/players = list()
	var/mobs = sort_mobs()
	for(var/mob/mob as anything in mobs)
		var/list/mob_data = player_ui_data(mob)
		if(mob_data)
			players += list(mob_data)
	return list(
		"Data" = players
	)

/datum/player_panel_veth/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/mob/selected_mob = params["VUAP_selected_mob"]
	var/mob/selected_player = get_mob_by_ckey(params["selectedPlayerCkey"]) || selected_mob //gets the mob datum from the ckey in client datum which we've saved. if there's a better way to do this please let me know
	switch(action) //switch for all the actions from the frontend - all of the Topic() calls check rights & log inside themselves.
		if("refresh")
			ui.send_update()
			return
		if("sendPrivateMessage")
			usr.client.cmd_admin_pm(selected_player.ckey)
			BLACKBOX_LOG_VUAP("PM")
			return
		if("follow")
			usr.client.holder.Topic(null, list("adminplayerobservefollow" = selected_player.UID()))
			to_chat(usr, "Now following [selected_player.ckey].", confidential = TRUE)
			return
		if("smite")
			usr.client.holder.Topic(null, list("Smite" = selected_mob.UID()))
			to_chat(usr, "Smiting [selected_player.ckey].", confidential = TRUE)
		if("checkAntags")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/check_antagonists)
			return
		if("faxPanel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/fax_panel)
			return
		if("gamePanel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/game_panel)
			return
		if("openAdditionalPanel")
			var/mob/target = selected_player
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/vuap_personal, target)
			return
		if("createCommandReport")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_admin_create_centcom_report)
			return
		if("logs")
			usr.client.holder.Topic(null, list("open_logging_view" = selected_player.UID()))
			return
		if("notes")
			usr.client.holder.Topic(null, list("shownoteckey" = selected_player.ckey))
			return
		if("vv")
			usr.client.debug_variables(selected_player)
			return
		if("tp")
			usr.client.holder.Topic(null, list("traitor" = selected_player.UID()))
			return
		if("obs")
			usr.client.holder.Topic(null, list("observeinventory" = selected_player.UID()))
			return
		if("adminaiinteract")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/toggle_advanced_interaction)

/datum/player_panel_veth/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "VethPlayerPanel", "Veth's Ultimate Player Panel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/player_panel_veth/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN|R_MOD)
