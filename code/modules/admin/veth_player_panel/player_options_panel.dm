ADMIN_VERB_ONLY_CONTEXT_MENU(vuap_personal, R_ADMIN|R_MOD, "Open TGUI PP", mob/target in GLOB.mob_list)
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
		var/datum/vuap_personal/tgui = new(user.mob)
		tgui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("VUAP_personal")

/datum/vuap_personal /* required for tgui component */

/datum/vuap_personal/ui_data(mob/user)
	var/ckey = user.client?.selectedPlayerCkey
	var/list/player_data = list(
		"characterName" = "NO_CHARACTER",
		"ckey" = ckey || "NO_CKEY",
		"ipAddress" = "0.0.0.0",
		"CID" = "NO_CID",
		"discord" = "NO_DISCORD",
		"playtime" = "NO_CLIENT",
		"rank" = "Player",
		"byondVersion" = "0.0.0",
		"mobType" = "null",
		"accountRegistered" = "UNKNOWN",
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
	if(!length(ckey) || ckey[1] == "@")
		var/mob/player = usr.client.VUAP_selected_mob
		player_data["characterName"] = player.name || "NO_CHARACTER"
		player_data["playtime"] = "NO_CLIENT"
		player_data["mobType"] = "[initial(player.type)]" || "null"
		return player_data
	else
		var/mob/player = get_mob_by_ckey(ckey)
		var/client/client_info = player?.client
		if(player && client_info)
			player_data["characterName"] = player.real_name || "NO_CHARACTER"
			player_data["ipAddress"] = client_info.address || "0.0.0.0"
			player_data["CID"] = client_info.computer_id || "NO_CID"
			player_data["discord"] = client_info.prefs.discord_id || "NO_DISCORD"
			player_data["playtime"] = client_info.get_exp_type(EXP_TYPE_CREW) || "NONE"
			player_data["rank"] = client_info.holder?.rank || "Player"
			player_data["byondVersion"] = "[client_info.byond_version || 0].[client_info.byond_build || 0]"
			player_data["mobType"] = "[initial(player.type)]" || "null"
			player_data["accountRegistered"] = client_info.byondacc_date || "UNKNOWN"
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

/datum/vuap_personal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerPanel", "Player Panel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/vuap_personal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/mob/selected_mob = ui.user.client.VUAP_selected_mob
	var/mob/selected_player = get_mob_by_ckey(ui.user.client.selectedPlayerCkey) || selected_mob
	if(!selected_player)
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
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/show_old_player_panel, selected_player)
			return
		if("playtime")
			usr.client.holder.Topic(null, list("getplaytimewindow" = selected_player.UID()))
			return
		if("relatedbycid")
			usr.client.holder.Topic(null, list("showrelatedacc" = "cid", "client" = selected_player.client?.UID()))
			return
		if("relatedbyip")
			usr.client.holder.Topic(null, list("showrelatedacc" = "ip", "client" = selected_player.client?.UID()))
			return
		// Punish Section
		if("kick")
			usr.client.holder.Topic(null, list("boot2" = selected_player.UID()))
			return
		if("ban")
			if(!ui.user.client.selectedPlayerCkey)
				to_chat(usr, "No client inside!")
				return
			if(!check_rights(R_BAN))
				return
			usr.client.holder.Topic(null, list("newban" = selected_player.UID(), "dbbanaddckey" = ui.user.client.selectedPlayerCkey))
			return
		if("jobban")
			if(!ui.user.client.selectedPlayerCkey)
				to_chat(usr, "No client inside!")
				return
			if(!check_rights(R_BAN))
				return
			usr.client.holder.Topic(null, list("jobban2" = selected_player.UID(), "dbbanaddckey" = ui.user.client.selectedPlayerCkey))
			return
		if("appban")
			if(!ui.user.client.selectedPlayerCkey)
				to_chat(usr, "No client inside!")
				return
			if(!check_rights(R_BAN))
				return
			usr.client.holder.Topic(null, list("appearanceban" = selected_player.UID(), "dbbanaddckey" = ui.user.client.selectedPlayerCkey))
			return
		if("watchlist")
			if(!ui.user.client.selectedPlayerCkey)
				to_chat(usr, "No client inside!")
				return
			usr.client.watchlist_add(ui.user.client.selectedPlayerCkey)
			return
		if("bless")
			usr.client.holder.Topic(null, list("Bless" = selected_player.UID()))
			return
		if("smite")
			usr.client.holder.Topic(null, list("Smite" = selected_mob.UID()))
			to_chat(usr, "Smiting [selected_player.ckey].", confidential = TRUE)
			return
		// Message Section
		if("pm")
			usr.client.cmd_admin_pm(selected_player.ckey)
			BLACKBOX_LOG_VUAP("PM")
			return
		if("sm")
			usr.client.holder.Topic(null, list("subtlemessage" = selected_player.UID()))
			return
		if("narrate")
			usr.client.holder.Topic(null, list("narrateto" = selected_player.UID()))
			return
		if("playsoundto")
			if(!check_rights(R_SOUNDS))
				return
			var/sound = input(usr, "", "Select a sound file",) as null|sound
			if(sound)
				SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/play_direct_mob_sound, sound, selected_player)
				return
		if("sendalert")
			usr.client.holder.Topic(null, list("adminalert" = selected_player.UID()))
			return
		if("manup")
			usr.client.holder.Topic(null, list("man_up" = selected_player.UID()))
			return
		// Movement Section
		if("jumpto")
			usr.client.holder.Topic(null, list("jumpto" = selected_player.UID()))
			return
		if("get")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/get_mob, selected_mob)
			return
		if("send")
			usr.client.holder.Topic(null, list("sendmob" = selected_player.UID()))
			return
		if("lobby")
			usr.client.holder.Topic(null, list("sendbacktolobby" = selected_player.UID()))
			return
		if("flw")
			usr.client.holder.Topic(null, list("adminplayerobservefollow" = selected_player.UID()))
			return
		if("cryo")
			usr.client.holder.Topic(null, list("cryossd" = selected_player.UID()))
			return
		// Info Section
		if("vv")
			usr.client.debug_variables(selected_player)
			BLACKBOX_LOG_VUAP("VV")
			return
		if("tp")
			usr.client.holder.Topic(null, list("traitor" = selected_player.UID()))
			return
		if("obs")
			usr.client.holder.Topic(null, list("observeinventory" = selected_player.UID()))
			return
		if("logs")
			usr.client.holder.Topic(null, list("open_logging_view" = selected_mob.UID()))
			return
		if("notes")
			usr.client.holder.Topic(null, list("shownoteckey" = selected_player.ckey))
			return
		if("playtime")
			usr.client.holder.Topic(null, list("getplaytimewindow" = selected_mob.UID()))
			return
		if("geoip")
			usr.client.holder.Topic(null, list("geoip" = selected_player.UID()))
			return
		if("ccdb")
			usr.client.holder.Topic(null, list("open_ccDB" = selected_player.ckey))
			return
		// Transformation Section
		if("makeghost")
			usr.client.holder.Topic(null, list(
				"simplemake" = "observer",
				"mob" = selected_player.UID()
			))
			ui.send_update()
			return
		if("makehuman")
			usr.client.holder.Topic(null, list(
				"simplemake" = "human",
				"mob" = selected_player.UID()
			))
			ui.send_update()
			return
		if("makemonkey")
			usr.client.holder.Topic(null, list(
				"simplemake" = "monkey",
				"mob" = selected_player.UID()
			))
			ui.send_update()
			return
		if("makeborg")
			usr.client.holder.Topic(null, list(
				"simplemake" = "robot",
				"mob" = selected_player.UID()
			))
			ui.send_update()
			return
		if("makeanimal")
			usr.client.holder.Topic(null, list("makeanimal" = selected_player.UID()))
			ui.send_update()
			return
		if("makeai")
			usr.client.holder.Topic(null, list("makeai" = selected_player.UID()))
			ui.send_update()
			return
		//observer section
		if("reviveghost")
			usr.client.holder.Topic(null, list("incarn_ghost" = selected_player.UID()))
			return
		if("respawnability")
			usr.client.holder.Topic(null, list("togglerespawnability" = selected_player.UID()))
			return
		//health section
		if("healthscan")
			healthscan(usr, selected_player, TRUE)
			BLACKBOX_LOG_VUAP("HealthScan")
		if("chemscan")
			chemscan(usr, selected_player)
			BLACKBOX_LOG_VUAP("ChemScan")
		if("aheal")
			usr.client.holder.Topic(null, list("revive" = selected_player.UID()))
			to_chat(usr, "Adminhealed  [selected_player.ckey].", confidential = TRUE)
			return
		if("giveDisease")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/give_disease, selected_player)
			BLACKBOX_LOG_VUAP("GiveDisease")
			return
		if("cureDisease")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cure_disease, selected_player)
			BLACKBOX_LOG_VUAP("CureDisease")
			return
		if("cureAllDiseases")
			if(!check_rights(R_EVENT))
				return
			if(isliving(selected_player))
				var/mob/living/living = selected_player
				for(var/datum/disease/disease in living.diseases) // cure all crit conditions
					disease.cure()
			log_and_message_admins("Cured all diseases on [selected_player.ckey].")
			to_chat(usr, "Cured all negative diseases on [selected_player.ckey].", confidential = TRUE)
			BLACKBOX_LOG_VUAP("CureAllDiseases")
			return
		if("mutate")
			usr.client.holder.Topic(null, list("showdna" = selected_player.UID()))
			return
		//mob manipulation section
		if("randomizename")
			usr.client.holder.Topic(null, list("randomizename" = selected_player.UID()))
			return
		if("userandomname")
			usr.client.holder.Topic(null, list("userandomname" = selected_player.UID()))
			return
		if("eraseflavortext")
			usr.client.holder.Topic(null, list("eraseflavortext" = selected_player.UID()))
			return
		if("selectequip")
			usr.client.holder.Topic(null, list("select_equip" = selected_player.UID()))
			return
		if("changevoice")
			usr.client.holder.Topic(null, list("change_voice" = selected_player.UID()))
			return
		if("checkcontents")
			usr.client.holder.Topic(null, list("check_contents" = selected_player.UID()))
			return
		if("mirroradmin")
			usr.client.holder.Topic(null, list("cma_admin" = selected_player.UID()))
			return
		if("mirrorplayer")
			usr.client.holder.Topic(null, list("cma_self" = selected_player.UID()))
			return
		// Misc Section
		if("forcesay")
			usr.client.holder.Topic(null, list("forcespeech" = selected_player.UID()))
			return
		if("adminroom")
			usr.client.holder.Topic(null, list("aroomwarp" = selected_player.UID()))
			return
		if("thunderdome1")
			usr.client.holder.Topic(null, list("tdome1" = selected_player.UID()))
			return
		if("thunderdome2")
			usr.client.holder.Topic(null, list("tdome2" = selected_player.UID()))
			return
		if("thunderdomeadmin")
			usr.client.holder.Topic(null, list("tdomeadmin" = selected_player.UID()))
			return
		if("thunderdomeobserve")
			usr.client.holder.Topic(null, list("tdomeobserve" = selected_player.UID()))
			return
		if("contractor_stop")
			usr.client.holder.Topic(null, list("contractor_stop" = selected_player.UID()))
			return
		if("contractor_start")
			usr.client.holder.Topic(null, list("contractor_start" = selected_player.UID()))
			return
		if("contractor_release")
			usr.client.holder.Topic(null, list("contractor_release" = selected_player.UID()))
			return
		if("prison")
			usr.client.holder.Topic(null, list("sendtoprison" = selected_player.UID()))
			return
		if("spawncookie")
			usr.client.holder.Topic(null, list("adminspawncookie" = selected_player.UID()))
			return
		// Mute Controls
		if("toggleMute")
			var/muteType = params["type"]
			switch(muteType)
				if("ic")
					cmd_admin_mute(selected_player, MUTE_IC)
					ui.send_update()
					return
				if("ooc")
					cmd_admin_mute(selected_player, MUTE_OOC)
					ui.send_update()
					return
				if("pray")
					cmd_admin_mute(selected_player, MUTE_PRAY)
					ui.send_update()
					return
				if("adminhelp")
					cmd_admin_mute(selected_player, MUTE_ADMINHELP)
					ui.send_update()
					return
				if("deadchat")
					cmd_admin_mute(selected_player, MUTE_DEADCHAT)
					ui.send_update()
					return
				if("tts")
					cmd_admin_mute(selected_player, MUTE_TTS)
					ui.send_update()
					return
				if("emote")
					cmd_admin_mute(selected_player, MUTE_EMOTE)
					ui.send_update()
					return
				if("all")
					cmd_admin_mute(selected_player, MUTE_ALL)
					ui.send_update()
					return
			return

		if("someadminbutton")
			SEND_SOUND(usr, sound('sound/items/bikehorn.ogg'))
			return

/datum/vuap_personal/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN|R_MOD)
