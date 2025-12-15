ADMIN_VERB(player_panel_veth, R_ADMIN|R_MOD, "Player Panel Veth", "Updated Player Panel with TGUI.", ADMIN_CATEGORY_GAME)
	var/datum/player_panel_veth/tgui = new(user.mob)
	tgui.ui_interact(user.mob)
	to_chat(user, span_interface("VUAP has been opened!"), confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("VUAP")

ADMIN_VERB_AND_CONTEXT_MENU(vuap_personal, R_ADMIN, "Show Player Panel", "Player options panel for a mob.", ADMIN_CATEGORY_GAME, mob/target in GLOB.player_list)
	if(!target)
		to_chat(user, span_warning("Could not find desired target mob!"), type = MESSAGE_TYPE_ADMINLOG, confidential = TRUE)
		return
	if(!length(target.ckey) || target.ckey[1] == "@")
		var/mob/player = target
		var/datum/mind/player_mind = get_mind(player, include_last = TRUE)
		var/player_mind_ckey = ckey(player_mind.key)
		user.selectedPlayerCkey = player_mind_ckey
		user.VUAP_selected_mob = target
		var/datum/vuap_personal/tgui = new(user.mob)
		tgui.ui_interact(user.mob)
		tgui_alert(user, "WARNING! This mob has no associated Mind! Most actions will not work. Last ckey to control this mob is [player_mind_ckey].", "No Mind!")
	else
		user.selectedPlayerCkey = target.ckey
		user.VUAP_selected_mob = target
		var/datum/vuap_personal/tgui = new(user)
		tgui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("VUAP_personal")

/datum/player_panel_veth/ /* required for tgui component */
	var/title = "Veth's Ultimate Player Panel"

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
	if(!check_rights(R_ADMIN))
		return
	var/mob/selected_mob = get_mob_by_ckey(params["selectedPlayerCkey"]) //gets the mob datum from the ckey in client datum which we've saved. if there's a better way to do this please let me know
	switch(action) //switch for all the actions from the frontend - all of the Topic() calls check rights & log inside themselves.
		if("refresh")
			ui.send_update()
			return
		if("sendPrivateMessage")
			usr.client.cmd_admin_pm(selected_mob.ckey)
			SSblackbox.record_feedback("tally", "VUAP", 1, "PM")
			return
		if("follow")
			usr.client.holder.Topic(null, list("adminplayerobservefollow" = selected_mob.UID()))
			to_chat(usr, "Now following [selected_mob.ckey].", confidential = TRUE)
			return
		if("smite")
			usr.client.holder.Topic(null, list("Smite" = selected_mob.UID()))
			to_chat(usr, "Smiting [selected_mob.ckey].", confidential = TRUE)
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
			var/mob/target = selected_mob
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/vuap_personal, target)
			return
		if("createCommandReport")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_admin_create_centcom_report)
			return
		if("logs")
			usr.client.holder.Topic(null, list("open_logging_view" = selected_mob.UID()))
			return
		if("notes")
			usr.client.holder.Topic(null, list("shownoteckey" = selected_mob.ckey))
			return
		if("vv")
			usr.client.debug_variables(selected_mob)
			return
		if("tp")
			usr.client.holder.Topic(null, list("traitor" = selected_mob.UID()))
			return
		if("obs")
			usr.client.holder.Topic(null, list("observeinventory" = selected_mob.UID()))
			return
		if("adminaiinteract")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/toggle_advanced_interaction)

/datum/player_panel_veth/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "VethPlayerPanel", title)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/player_panel_veth/ui_status(mob/user, datum/ui_state/state)
	. = (check_rights(R_ADMIN|R_MOD, user = user)) ? UI_INTERACTIVE : ..()

/datum/player_panel_veth/ui_state(mob/user)
	return GLOB.admin_state
