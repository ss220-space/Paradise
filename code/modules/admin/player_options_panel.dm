
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

/datum/admins/proc/vuap_open_context(mob/M)
	if(!check_rights(NONE))
		return
	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.", confidential=TRUE)
		return
	var/mob = null
	// First we get mob. Check for ckey and client inside
	if(findtext(M.ckey, "@" ) || M.ckey == "" || M.ckey == null)
		// No ckey? No problem, We will manipulate clientless mob then.
		mob = M
	// But we still need to check out ckey so /ui_data will properly work
	var/ckey = M.ckey
	// open
	usr.client.holder.vuap_open(ckey, mob)

/datum/vuap_personal
	var/selected_ckey = ""
	var/selected_mob = null

/datum/vuap_personal/ui_data(mob/user)
	var/list/player_data = list(
		"characterName" = "No Character",
		"ckey" = selected_ckey || "NO CKEY",
		"ipAddress" = "0.0.0.0",
		"CID" = "NO CID",
		"discord" = "No Discord",
		"playtime" = "No client",
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
		),
		"adminRights" = "",
	)
	if(selected_ckey == null || selected_ckey == "" || selected_ckey[1] == "@")
		var/mob/player = selected_mob
		player_data["characterName"] = player.name || "No Character"
		player_data["playtime"] = "No client"
		player_data["mobType"] = "[initial(player.type)]" || "null"
	else
		var/mob/player = get_mob_by_ckey(selected_ckey)
		var/client/client_info = player?.client
		if(player && client_info)
			player_data["characterName"] = player.real_name || "No Character"
			player_data["ipAddress"] = client_info.address || "0.0.0.0"
			player_data["CID"] = client_info.computer_id || "NO_CID"
			player_data["discord"] = client_info.prefs.discord_id || "No Discord"
			player_data["playtime"] = client_info.get_exp_type(EXP_TYPE_CREW) || "none"
			player_data["rank"] = client_info.holder?.rank || "Player"
			player_data["byondVersion"] = "[client_info.byond_version || 0].[client_info.byond_build || 0]"
			player_data["mobType"] = "[initial(player.type)]" || "null"
			player_data["accountRegistered"] = client_info.byondacc_date || "Unknown"
			// Safely check mute states
			if(client_info.prefs)
				player_data["muteStates"] = list(
					"ic" = check_mute(player.client.ckey, MUTE_IC),
					"ooc" = check_mute(player.client.ckey, MUTE_OOC),
					"pray" = check_mute(player.client.ckey, MUTE_PRAY),
					"adminhelp" = check_mute(player.client.ckey, MUTE_ADMINHELP),
					"deadchat" = check_mute(player.client.ckey, MUTE_DEADCHAT),
					"tts" = check_mute(player.client.ckey, MUTE_TTS),
					"emote" = check_mute(player.client.ckey, MUTE_EMOTE),
					"all" = check_mute(player.client.ckey, MUTE_ALL)
				)

	player_data["adminRights"] = rights2text(user.client.holder.rights)

	return player_data

/datum/vuap_personal/ui_status(mob/user, datum/ui_state/state)
	. = (check_rights(R_ADMIN | R_MOD, user = user)) ? UI_INTERACTIVE : ..()


/datum/vuap_personal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerPanel", "Player Panel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/vuap_personal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	var/mob/M = get_mob_by_ckey(selected_ckey) || selected_mob
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
		if("old_pp")
			usr.client.holder.show_old_player_panel(M)
			return
		if("playtime")
			usr.client.holder.Topic(null, list("getplaytimewindow" = M.UID()))
		if("relatedbycid")
			usr.client.holder.Topic(null, list("showrelatedacc" = "cid", "client" = M.client?.UID()))
		if("relatedbyip")
			usr.client.holder.Topic(null, list("showrelatedacc" = "ip", "client" = M.client?.UID()))
		// Punish Section
		if("kick")
			usr.client.holder.Topic(null, list("boot2" = M.UID()))
		if("ban")
			if(!selected_ckey)
				to_chat(usr, "No client inside!")
				return
			if(!check_rights(R_BAN))
				return
			usr.client.holder.Topic(null, list("newban" = M.UID(), "dbbanaddckey" = selected_ckey))
		if("jobban")
			if(!selected_ckey)
				to_chat(usr, "No client inside!")
				return
			if(!check_rights(R_BAN))
				return
			usr.client.holder.Topic(null, list("jobban2" = M.UID(), "dbbanaddckey" = selected_ckey))
		if("appban")
			if(!selected_ckey)
				to_chat(usr, "No client inside!")
				return
			if(!check_rights(R_BAN))
				return
			usr.client.holder.Topic(null, list("appearanceban" = M.UID(), "dbbanaddckey" = selected_ckey))
		if("watchlist")
			if(!selected_ckey)
				to_chat(usr, "No client inside!")
				return
			usr.client.watchlist_add(selected_ckey)
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
			var/S = input(usr, "", "Select a sound file",) as null|sound
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
		if("geoip")
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
			usr.client.holder.Topic(null, list("togglerespawnability" = M.UID()))
		//health section
		if("healthscan")
			healthscan(usr, M, TRUE)
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
					cmd_admin_mute(M, MUTE_IC)
					ui.send_update()
				if("ooc")
					cmd_admin_mute(M, MUTE_OOC)
					ui.send_update()
				if("pray")
					cmd_admin_mute(M, MUTE_PRAY)
					ui.send_update()
				if("adminhelp")
					cmd_admin_mute(M, MUTE_ADMINHELP)
					ui.send_update()
				if("deadchat")
					cmd_admin_mute(M, MUTE_DEADCHAT)
					ui.send_update()
				if("tts")
					cmd_admin_mute(M, MUTE_TTS)
					ui.send_update()
				if("emote")
					cmd_admin_mute(M, MUTE_EMOTE)
					ui.send_update()
				if("all")
					cmd_admin_mute(M, MUTE_ALL)
					ui.send_update()
		if("someadminbutton")
			SEND_SOUND(usr, 'sound/items/bikehorn.ogg')


/datum/vuap_personal/ui_state(mob/user)
	return GLOB.admin_mod_state

/datum/admins/proc/vuap_open(ckey, mob/M)
	if (!check_rights(NONE))
		message_admins("[key_name(src)] attempted to use VUAP without sufficient rights.")
		return
	var/datum/vuap_personal/tgui = new(usr)
	tgui.selected_ckey = ckey
	tgui.selected_mob = M
	tgui.ui_interact(usr)
