
/*
	features that need to add
	Soulless things should now be PP'able with warning.
	Some (poor) explanation of what's going on -
	player_panel_veth is the new tgui version of the player panel, it also includes some most pressed verbs
	I've tried to comment in as much stuff as possible so it can be changed in the future is necessary
	Vuap_personal is the new tgui version of the options panel. It basically does everything the same way the player panel does
	minus some features that the player panel didn't have I guess.
	the client/var/selectedPlayerCkey is used to hold the selected player ckey for moving to and from pp/vuap
*/

/datum/admins/proc/player_panel_new()//The new one
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
	var/mobs = sort_mobs()
	for (var/mob/M in mobs)
		if (M.ckey)
			players += list(list(
				"name" = M.name || "No Character",
				"job" = M.job || "No Job",
				"ckey" = M.ckey || "No Ckey",
				"is_antagonist" = is_special_character(M, allow_fake_antags = TRUE),
				"last_ip" = M.lastKnownIP ||	 "No Last Known IP",
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
			return
		if("sendPrivateMessage")
			usr.client.cmd_admin_pm(M.ckey)
			return
		if("follow")
			usr.client.holder.Topic(null, list("adminplayerobservefollow" = M.UID()))
			to_chat(usr, "Now following [M.ckey].", confidential = TRUE)
			return
		if("smite")
			usr.client.holder.Topic(null, list("Smite" = M.UID()))
		if("checkAntags")
			usr.client.check_antagonists() //logs/rightscheck inside the proc
			return
		if("faxPanel")
			usr.client.fax_panel() //logs/rightscheck inside the proc
			return
		if("gamePanel")
			usr.client.game_panel() //logs/rightscheck inside the proc
			return
		if("openAdditionalPanel") //logs/rightscheck inside the proc
			usr.client.selectedPlayerCkey = params["selectedPlayerCkey"]
			usr.client.holder.vuap_open()
			return
		if("createCommandReport")
			usr.client.cmd_admin_create_centcom_report() //logs/rightscheck inside the proc
			return
		if("logs")
			usr.client.holder.Topic(null, list(
				"individuallog" = M.UID(),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("notes") //i'm pretty sure this checks rights inside the proc but to be safe
			if(!check_rights(NONE))
				return
			browse_messages(target_ckey = M.ckey)
			return
		if("vv") //logs/rightscheck inside the proc
			usr.client.debug_variables(M)
			return
		if("tp")
			usr.client.holder.Topic(null, list("traitor" = M.UID()))
			return
		if("adminaiinteract") //loggin inside the proc
			usr.client.toggle_advanced_interaction()

/datum/player_panel_veth/ui_interact(mob/user, datum/tgui/ui)

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "VethPlayerPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/player_panel_veth/ui_state(mob/user)
	return GLOB.admin_state


/client //this is needed to hold the selected player ckey for moving to and from pp/vuap
	var/selectedPlayerCkey = ""
	var/VUAP_selected_mob = null

/datum/admins/proc/vuap_open_context(mob/M in GLOB.mob_list) //this is the proc for the right click menu
	if(!check_rights(NONE))
		return
	if(findtext(M.ckey, "@" ) || M.ckey == "" || M.ckey == null)
		var/mob/player = M
		var/datum/mind/player_mind = get_mind(player, include_last = TRUE)
		var/player_mind_ckey = player_mind.key
		usr.client.VUAP_selected_mob = M
		usr.client.holder.vuap_open()
		tgui_alert(usr, "WARNING! This mob has no associated Mind! Most actions will not work. Last ckey to control this mob is [player_mind_ckey].", "No Mind!")

	else
		usr.client.selectedPlayerCkey = M.ckey
		usr.client.holder.vuap_open()

/datum/vuap_personal


/datum/vuap_personal/ui_data(mob/user)
	var/ckey = user.client?.selectedPlayerCkey
	var/list/player_data = list(
		"characterName" = "No Character",
		"ckey" = ckey || "Unknown",
		"ipAddress" = "0.0.0.0",
		"CID" = "NO_CID",
		"discord" = "No Discord",
		"gameState" = "Unknown",
		"rank" = "Player",
		"byondVersion" = "0.0.0",
		"mobType" = "null",
		"accountRegistered" = "Unknown",
		"muteStates" = list(
			"ic" = FALSE,
			"ooc" = FALSE,
			"pray" = FALSE,
			"adminhelp" = FALSE,
			"deadchat" = FALSE,
			"webreq" = FALSE
		)
		"adminRights" = "",
	)
	if(ckey[1] == "@" || ckey == "" || ckey == null)
		var/mob/player = user.client.VUAP_selected_mob
		player_data["characterName"] = player.name || "No Character"
		player_data["gameState"] = istype(player) ? "Active" : "Unknown"
		player_data["mobType"] = "[initial(player.type)]" || "null"
	else
		var/mob/player = get_mob_by_ckey(ckey)
		var/client/client_info = player?.client
		if(player && client_info)
			player_data["characterName"] = player.real_name || "No Character"
			player_data["ipAddress"] = client_info.address || "0.0.0.0"
			player_data["CID"] = client_info.computer_id || "NO_CID"
			player_data["discord"] = client.prefs.discord_id || "No Discord",
			player_data["gameState"] = istype(player) ? "Active" : "Unknown"
			player_data["rank"] = client.holder?.rank || "Player",
			player_data["byondVersion"] = "[client_info.byond_version || 0].[client_info.byond_build || 0]"
			player_data["mobType"] = "[initial(player.type)]" || "null"
			player_data["accountRegistered"] = client_info.byondacc_date || "Unknown"
			// Safely check mute states
			if(client_info.prefs)
				player_data["muteStates"] = list(
					"ic" = check_mute(M.client.ckey, MUTE_IC),
					"ooc" = check_mute(M.client.ckey, MUTE_OOC),
					"pray" = check_mute(M.client.ckey, MUTE_PRAY),
					"adminhelp" = check_mute(M.client.ckey, MUTE_ADMINHELP),
					"deadchat" = check_mute(M.client.ckey, MUTE_DEADCHAT),
					"tts" = check_mute(M.client.ckey, MUTE_TTS),
					"emote" = check_mute(M.client.ckey, MUTE_EMOTE),
					"all" = check_mute(M.client.ckey, MUTE_ALL)
				)

	player_data["adminRights"] = rights2text(user.client.holder.rights)

	return player_data

/datum/vuap_personal/ui_static_data(mob/user)
	0

/datum/vuap_personal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/vuap_personal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	var/mob/M = get_mob_by_ckey(ui.user.client.selectedPlayerCkey)
	if(!M)
		tgui_alert(usr, "Selected player not found!")
		return
	//pretty much all of these actions use the Topic() admin call. This admin call is secure, checks rights, and does stuff the way the old player panel did.
	//see code/modules/admin/topic.dm for more info on how it works.
	//essentially you have to pass a list of parameters to Topic(). It needs to be provided with an admin token to do any of its functions.
	switch(action)
		if("refresh")
			ui.send_update()
			return
		if("relatedbycid")
			usr.client.holder.Topic(null, list("showrelatedacc" = "cid", "client" = M.client.UID()))
		if("relatedbyip")
			usr.client.holder.Topic(null, list("showrelatedacc" = "ip", "client" = M.client.UID()))
		// Punish Section
		if("kick")
			usr.client.holder.Topic(null, list("boot2" = M.UID()))
		if("ban")
			if(!check_rights(R_BAN))
				return
			usr.client.ban_panel()
		if("watchlist")
			usr.client.holder.Topic(null, list("watchadd" = M.UID()))
		if("bless")
			usr.client.holder.Topic(null, list("Bless" = M.UID()))
		if("smite")
			usr.client.holder.Topic(null, list("Smite" = M.UID()))
		// Message Section
		if("pm")
			if (!check_rights(NONE))
				return
			usr.client.cmd_admin_pm(M.ckey)
		if("sm")
			usr.client.holder.Topic(null, list("subtlemessage" = M.UID()))
		if("narrate")
			usr.client.holder.Topic(null, list("narrateto" = M.UID()))
		if("playsoundto")
			if(!check_rights(R_SOUNDS))
				return
			var/S = input("", "Select a sound file",) as null|sound
			if(S)
				usr.client.play_direct_mob_sound(S, M)
		if("sendalert")
			usr.client.holder.Topic(null, list("adminalert" = M.UID()))
		if("manup")
			usr.client.holder.Topic(null, list("man_up" = M.UID()))
		// Movement Section
		if("jumpto")
			usr.client.holder.Topic(null, list("jumpto" = M.UID()))
		if("get")
			usr.client.holder.Topic(null, list("getmob" = M.UID()))
		if("send")
			usr.client.holder.Topic(null, list("sendmob" = M.UID()))
		if("lobby")
			usr.client.holder.Topic(null, list("sendbacktolobby" = M.UID()))
		if("flw")
			usr.client.holder.Topic(null, list("adminplayerobservefollow" = M.UID()))
		if("cryo")
			usr.client.holder.Topic(null, list("cryossd" = M.UID()))
		// Info Section
		if("vv")
			usr.client.debug_variables(M)
		if("tp")
			usr.client.holder.Topic(null, list("traitor" = M.UID()))
		if("logs")
			usr.client.holder.Topic(null, list("open_logging_view" = M.UID()))
		if("notes")
			usr.client.holder.Topic(null, list("shownoteckey" = M.ckey))
		if("playtime")
			usr.client.holder.Topic(null, list("getplaytimewindow" = M.UID()))
		if("playtime")
			usr.client.holder.Topic(null, list("geoip" = M.UID()))
		if("ccdb")
			usr.client.holder.Topic(null, list("open_ccDB" = M.ckey))
		// Transformation Section
		if("makeghost")
			usr.client.holder.Topic(null, list(
				"simplemake" = "observer",
				"mob" = M.UID()
			))
			ui.send_update()
		if("makehuman")
			usr.client.holder.Topic(null, list(
				"simplemake" = "human",
				"mob" = M.UID()
			))
			ui.send_update()
		if("makemonkey")
			usr.client.holder.Topic(null, list(
				"simplemake" = "monkey",
				"mob" = M.UID()
			))
			ui.send_update()
		if("makeborg")
			usr.client.holder.Topic(null, list(
				"simplemake" = "robot",
				"mob" = M.UID()
			))
			ui.send_update()
		if("makeanimal")
			usr.client.holder.Topic(null, list("makeanimal" = M.UID()))
			ui.send_update()
		if("makeai")
			usr.client.holder.Topic(null, list("makeai" = M.UID()))
			ui.send_update()
		//observer section
		if("reviveghost")
			usr.client.holder.Topic(null, list("incarn_ghost" = M.UID()))
		if("respawnability")
			usr.client.holder.Topic(null, list("f" = M.UID()))
		//health section
		if("healthscan")
			healthscan(usr, M, advanced = TRUE, tochat = TRUE)
		if("chemscan")
			chemscan(usr, M)
		if("aheal")
			usr.client.holder.Topic(null, list("revive" = M.UID()))
		if("giveDisease")
			usr.client.give_disease(M)
		if("cureDisease")
			usr.client.cure_disease(M)
		if("cureAllDiseases")
			if(!check_rights(R_EVENT))
				return
			if (istype(M, /mob/living))
				var/mob/living/L = M
				for(var/datum/disease/D in L.diseases) // cure all crit conditions
					D.cure()
			log_and_message_admins("Cured all diseases on [M.ckey].")
		if("mutate")
			usr.client.holder.Topic(null, list("showdna" = M.UID()))
		//mob manipulation section
		if("randomizename")
			usr.client.holder.Topic(null, list("randomizename" = M.UID()))
		if("userandomname")
			usr.client.holder.Topic(null, list("userandomname" = M.UID()))
		if("eraseflavortext")
			usr.client.holder.Topic(null, list("eraseflavortext" = M.UID()))
		if("selectequip")
			usr.client.holder.Topic(null, list("select_equip" = M.UID()))
		if("changevoice")
			usr.client.holder.Topic(null, list("change_voice" = M.UID()))
		if("checkcontents")
			usr.client.holder.Topic(null, list("check_contents" = M.UID()))
		if("mirroradmin")
			usr.client.holder.Topic(null, list("cma_admin" = M.UID()))
		if("mirrorplayer")
			usr.client.holder.Topic(null, list("cma_self" = M.UID()))
		// Misc Section
		//if("language")
		//	usr.client.holder.Topic(null, list("languagemenu" = M.UID()))
		if("forcesay")
			usr.client.holder.Topic(null, list("forcespeech" = M.UID()))
		if("adminroom")
			usr.client.holder.Topic(null, list("aroomwarp" = M.UID()))
		if("thunderdome1")
			usr.client.holder.Topic(null, list("tdome1" = M.UID()))
		if("thunderdome2")
			usr.client.holder.Topic(null, list("tdome2" = M.UID()))
		if("thunderdomeadmin")
			usr.client.holder.Topic(null, list("tdomeadmin" = M.UID()))
		if("thunderdomeobserve")
			usr.client.holder.Topic(null, list("tdomeobserve" = M.UID()))
		if("contrastop")
			usr.client.holder.Topic(null, list("contractor_stop" = M.UID()))
		if("contrastart")
			usr.client.holder.Topic(null, list("contractor_start" = M.UID()))
		if("contrarelease")
			usr.client.holder.Topic(null, list("contractor_release" = M.UID()))
		if("prison")
			usr.client.holder.Topic(null, list("sendtoprison" = M.UID()))
		if("spawncookie")
			usr.client.holder.Topic(null, list("adminspawncookie" = M.UID()))
		// Mute Controls
		if("toggleMute")
			var/muteType = params["type"]
			switch(muteType)
				if("ic")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_IC)
					ui.send_update()
				if("ooc")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_OOC)
					ui.send_update()
				if("pray")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_PRAY)
					ui.send_update()
				if("adminhelp")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_ADMINHELP)
					ui.send_update()
				if("deadchat")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_DEADCHAT)
					ui.send_update()
				if("tts")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_TTS)
					ui.send_update()
				if("emote")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_EMOTE)
					ui.send_update()
				if("all")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_ALL)
					ui.send_update()


/datum/vuap_personal/ui_state(mob/user)
	return GLOB.admin_state

/datum/admins/proc/vuap_open()
	if (!check_rights(NONE))
		message_admins("[key_name(src)] attempted to use VUAP without sufficient rights.")
		return
	var/datum/vuap_personal/tgui = new(usr)
	tgui.ui_interact(usr)
