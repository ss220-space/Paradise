/datum/controller/subsystem/voicechat/proc/join_vc(client/userClient, external=FALSE)
	if(!userClient)
		return
	RegisterSignal(userClient, COMSIG_TOPIC, PROC_REF(voicechat_topic), override=TRUE)

	var/dat = {"
	<html>
		<h4>Если это окно не закроется через несколько секунд, то это значит, что что-то сломалось.</h4>
	<script>
		window.location.href += `?src=[UID()];origin=${window.location.origin};external=[external]`
		</script>
	</html>"}

	var/datum/browser/popup = new(userClient, "origin_locator", "", 400, 500)
	popup.set_content(dat)
	popup.open()
	///join_vc -> Topic -> open_vc


/datum/controller/subsystem/voicechat/proc/voicechat_topic(atom/source, mob/user, href_list)
	var/client/userClient = user.client
	if(href_list["origin"])
		close_window(userClient,"origin_locator")
		UnregisterSignal(userClient, COMSIG_TOPIC)
		open_vc(userClient, href_list["origin"], href_list["external"])


/datum/controller/subsystem/voicechat/proc/generate_userCode(client/userClient)
	if(!userClient)
		// CRASH("no client")
		return
	. = copytext(md5("[userClient.computer_id][userClient.address][rand()]"),-4)
	//ensure unique
	while(. in userCode_client_map)
		. = copytext(md5("[userClient.computer_id][userClient.address][rand()]"),-4)
	return .

// Connects a client to voice chat via an external browser
/datum/controller/subsystem/voicechat/proc/open_vc(client/userClient, origin, external)
	if(!userClient || !origin)
		return
	// Disconnect existing session if present
	var/existing_userCode = client_userCode_map[userClient]
	if(existing_userCode)
		disconnect(existing_userCode, from_byond = TRUE)
	// Generate unique session and user codes
	var/sessionId = md5("[world.time][rand()][world.realtime][rand(0,9999)][userClient.address][userClient.computer_id]")
	var/userCode = generate_userCode(userClient)
	// "deliver" voicechat assets
	userClient << browse_rsc('voicechat/node/public/voicechat.html')
	userClient << browse_rsc('voicechat/node/public/voicechat.js')
	userClient << browse_rsc('voicechat/node/public/style.css')
	userClient << browse_rsc('voicechat/node/public/stopclown.png')
	userClient << browse_rsc('voicechat/node/public/socketio.js')
	userClient << browse_rsc('voicechat/node/public/megaphone.png')
	userClient << browse_rsc('voicechat/node/public/fastclown.gif')

	// opens voicechat
	var/socket_host = world.internet_address
	// If the server is bound to localhost or the client is local, prefer 127.0.0.1
	if(world.address == "127.0.0.1" || (userClient && userClient.address && userClient.address == "127.0.0.1"))
		socket_host = "127.0.0.1"
	// If the client's address is set and differs from the advertised internet address,
	// prefer the client's address (useful when the browser is running on the same host)
	else if(userClient && userClient.address && userClient.address != "" && userClient.address != world.internet_address)
		socket_host = userClient.address
	var/voicechat_port = CONFIG_GET(number/port_voicechat) || 3000
	var/web_link = "[origin]/voicechat.html?sessionId=[sessionId]&socket_address=[socket_host]:[voicechat_port]"
	if(text2num(external))
		var/dat = {"
		<html>
			<h4>[web_link]</h4>
			<p>
				Вставьте эту ссылку в браузер, поддерживающий технологию WebRTC (Браузер Firefox работает с этим лучше всего).
			</p>
		</html>"}
		var/datum/browser/popup = new(userClient, "voicechat_help", "", 400, 500)
		popup.set_content(dat)
		popup.open()
	else
		userClient << link(web_link)

	send_json(alist(
		cmd = "register",
		userCode = userCode,
		sessionId = sessionId
	))

	// Link client to userCode
	userCode_client_map[userCode] = userClient
	client_userCode_map[userClient] = userCode
	// Confirmation handled in confirm_usekrCode


// Confirms userCode when browser and mic access are granted
/datum/controller/subsystem/voicechat/proc/confirm_userCode(userCode)
	if(!userCode || (userCode in vc_clients))
		return
	var/client/userClient = userCode_client_map[userCode]
	if(!userClient)
		disconnect(userCode)
		return
	var/mob/userMob = userClient.mob
	if(!userMob)
		disconnect(userCode)
		return
	mob_client_map[userMob] = userClient

	vc_clients += userCode
	register_mob_signals(userMob)
	check_mob_conditions(userMob)
	RegisterSignal(userClient, COMSIG_QDELETING, PROC_REF(on_client_leaving_game))

/// the big ugly.
/datum/controller/subsystem/voicechat/proc/register_mob_signals(mob/userMob)
	SIGNAL_HANDLER
	// whenever client switches to a different mob, setup signals
	RegisterSignal(userMob, COMSIG_MOB_LOGOUT, PROC_REF(on_mob_changed))

	if(isliving(userMob))
		RegisterSignals(userMob, list(\
			SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
			SIGNAL_ADDTRAIT(TRAIT_DEAF),
			SIGNAL_ADDTRAIT(TRAIT_MUTE),
			), PROC_REF(clear_from_room))
		RegisterSignals(userMob, list(\
			SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT),
			SIGNAL_REMOVETRAIT(TRAIT_DEAF),
			SIGNAL_REMOVETRAIT(TRAIT_MUTE),
			), PROC_REF(add_to_room))

		RegisterSignal(userMob, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
		RegisterSignal(userMob, COMSIG_LIVING_REVIVE, PROC_REF(on_mob_revive))


/datum/controller/subsystem/voicechat/proc/on_mob_changed(mob/userMob)
	var/client/userClient = mob_client_map[userMob]
	if(!userClient)
		return

	mob_client_map.Remove(userMob)
	unregister_mob_signals(userMob)

	var/mob/new_mob = userClient.mob
	if(new_mob)
		mob_client_map[new_mob] = userClient
		register_mob_signals(new_mob)
		check_mob_conditions(new_mob)

/datum/controller/subsystem/voicechat/proc/unregister_mob_signals(mob/userMob)
	UnregisterSignal(userMob, COMSIG_MOB_LOGOUT)
	if(isliving(userMob))
		UnregisterSignal(userMob, list(\
			SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
			SIGNAL_ADDTRAIT(TRAIT_DEAF),
			SIGNAL_ADDTRAIT(TRAIT_MUTE),
			SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT),
			SIGNAL_REMOVETRAIT(TRAIT_DEAF),
			SIGNAL_REMOVETRAIT(TRAIT_MUTE),
			COMSIG_LIVING_DEATH,
			COMSIG_LIVING_REVIVE,
		))


/datum/controller/subsystem/voicechat/proc/clear_from_room(mob/userMob)
	SIGNAL_HANDLER
	if(!userMob)
		// CRASH("signal called without user {usr: [usr || "null"]}")
		return
	var/client/userClient = userMob.client
	var/userCode = client_userCode_map[userClient]
	if(!userClient || !userCode)
		return
	clear_userCode(userCode)

/datum/controller/subsystem/voicechat/proc/add_to_room(mob/userMob)
	SIGNAL_HANDLER
	if(!userMob)
		// CRASH("signal called without user {usr: [usr || "null"]}")
		return
	var/client/userClient = userMob.client
	var/userCode = client_userCode_map[userClient]
	if(!userClient || !userCode)
		return
	move_userCode_to_room(userCode, "living")

/datum/controller/subsystem/voicechat/proc/on_mob_death(mob/userMob)
	SIGNAL_HANDLER
	check_mob_conditions(userMob)

/datum/controller/subsystem/voicechat/proc/on_mob_revive(mob/userMob)
	SIGNAL_HANDLER
	check_mob_conditions(userMob)


/datum/controller/subsystem/voicechat/proc/check_mob_conditions(mob/userMob)
	if(!userMob)
		return

	var/client/userClient = userMob.client
	var/userCode = client_userCode_map[userClient]

	if(!userClient || !userCode)
		return



	var/room

	// everyone goes to no prox to yell at each other at round end and round start.
	if(isnewplayer(userMob) || SSticker.current_state == GAME_STATE_FINISHED)
		room = "lobby"

	else if(isdead(userMob) || userMob.stat == DEAD)
		room = "ghost"

	else if(isliving(userMob))
		if(HAS_TRAIT(userMob, TRAIT_KNOCKEDOUT) || HAS_TRAIT(userMob, TRAIT_DEAF)|| HAS_TRAIT(userMob, TRAIT_MUTE))
			clear_from_room(userMob)
		else
			room = "living"

	if(room && userCode_room_map[userCode] != room)
		move_userCode_to_room(userCode, room)
		//for lobby chat as ticker isnt intialized.
		if(SSticker.current_state < GAME_STATE_PLAYING)
			send_locations()

/datum/controller/subsystem/voicechat/proc/on_client_leaving_game(client/userClient)
	var/userCode = client_userCode_map[userClient]
	disconnect(userCode, from_byond = TRUE)

// Disconnects a user from voice chat
/datum/controller/subsystem/voicechat/proc/disconnect(userCode, from_byond = FALSE)
	if(!userCode)
		return
	toggle_active(userCode, FALSE)
	clear_userCode(userCode)

	var/client/userClient = userCode_client_map[userCode]
	var/mob/userMob
	if(userClient)
		userMob = userClient.mob
		userCode_client_map.Remove(userCode)
		client_userCode_map.Remove(userClient)
		userCode_room_map.Remove(userCode)
		vc_clients -= userCode

	if(userMob)
		unregister_mob_signals(userMob)
		mob_client_map.Remove(userMob)
		if(userCodes_speaking_icon[userCode])
			userMob.cut_overlay(userCodes_speaking_icon[userCode])

	userCode_mob_map.Remove(userCode)
	userCodes_speaking_icon.Remove(userCode)

	if(from_byond)
		send_json(alist(cmd= "disconnect", userCode= userCode))


// Toggles the speaker overlay for a user
/datum/controller/subsystem/voicechat/proc/toggle_active(userCode, is_active)
	if(!userCode || isnull(is_active))
		return
	var/client/userClient = userCode_client_map[userCode]

	if(!userClient || !userClient.mob)
		return
	var/mob/userMob = userClient.mob
	var/image/speaker
	if(!userCodes_speaking_icon[userCode])
		speaker = image('icons/mob/talk.dmi', icon_state = "voice")
		speaker.alpha = 200
		userCodes_speaking_icon[userCode] = speaker
	else
		speaker = userCodes_speaking_icon[userCode]

	var/mob/old_mob = userCode_mob_map[userCode]
	if(userMob != old_mob)
		if(old_mob)
			old_mob.overlays -= speaker
		userCode_mob_map[userCode] = userMob

	var/room = userCode_room_map[userCode]

	//stat is used to ensure dead people dont have talking overlays
	if(is_active && room && !userMob.stat)
		userCodes_active |= userCode
		userMob.add_overlay(speaker)
	else
		userCodes_active -= userCode
		userMob.cut_overlay(speaker)


// Mutes or deafens a user's microphone
/datum/controller/subsystem/voicechat/proc/mute_mic(client/userClient, deafen = FALSE)
	if(!userClient)
		return
	var/userCode = client_userCode_map[userClient]
	if(!userCode)
		return
	send_json(list(
		cmd = deafen ? "deafen" : "mute_mic",
		userCode = userCode
	))
