/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at
	/// Dummy reference so BYOND includes the chat highlight sounds in the client resource pack, if it isn't included in any `.DM` file.
	var/static/list/_chat_highlight_sounds = list('sound/misc/highlight_sounds/Beep.ogg')

/datum/tgui_panel/New(client/client, id)
	if(!id)
		qdel(src)
		CRASH("New TGUI panel created for [client] but no id supplied, deleting.")
	src.client = client
	window = new(client, id)
	window.subscribe(src, PROC_REF(on_message))

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/datum/tgui_panel/can_vv_get(var_name)
	var/static/list/protected_vars = list("telemetry_connections")
	if(!check_rights(R_ADMIN, FALSE, src) && (var_name in protected_vars))
		return FALSE
	return TRUE

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/initialize(force = FALSE)
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(1)
	initialized_at = world.time
	// Perform a clean initialization
	window.initialize(
		strict_mode = TRUE,
		assets = list(
			get_asset_datum(/datum/asset/simple/tgui_panel),
		))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/fontawesome))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/tgfont))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet_batched/chat))
	request_telemetry()
	addtimer(CALLBACK(src, PROC_REF(on_initialize_timed_out)), 5 SECONDS)
	window.send_message("testTelemetryCommand")

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	// Currently does nothing but sending a message to old chat.
	// Users often miss this text, thinking it is wiki-page, so this text should be BIG
	SEND_TEXT(client, span_userdanger("<h1>Failed to load fancy chat, click <a href='byond://?src=[UID()];reload_tguipanel=1'>HERE</a> to attempt to reload it.<br>\
	<a href='https://discord.com/channels/617003227182792704/756409070721957918/1435670788748607599'>ИНСТРУКЦИЯ</a> из Discord по восстановлению работы чата, если перезагрузка не помогает!</h1>"))

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"locked" = FALSE,
				),
			),
		))
		send_player_info()
		send_hotkey_mode()
		return TRUE

	if(type == "theme")
		client.tgui_panel_theme = payload["theme"]
		return TRUE

	if(type == "audio/setAdminMusicVolume")
		client.admin_music_volume = payload["volume"]
		return TRUE
	if(type == "telemetry")
		analyze_telemetry(payload)
		return TRUE

	if(type == "verbs/request_verbs")
		client.init_verbs()
		if(!client?.holder)
			return TRUE

		window.send_asset(get_asset_datum(/datum/asset/json/spawn_menu))
		return TRUE

	if(type == "verbs/request_targets")
		var/verb_path = text2path(payload["verb_type"])
		if(!verb_path)
			return TRUE
		if(!(verb_path in client.verbs) && !(client.mob && (verb_path in client.mob.verbs)))
			return TRUE

		var/list/arg_list
		var/datum/verb_metadata/meta = SSverbs.verbs_by_verb_path[verb_path]
		if(meta)
			arg_list = meta.arguments
		else
			var/datum/admin_verb/av = SSadmin_verbs.admin_verbs_by_verb_path[verb_path]
			if(av)
				arg_list = av.arguments
		if(!length(arg_list))
			return TRUE
		var/datum/verb_arg_metadata/entity_arg
		for(var/datum/verb_arg_metadata/arg in arg_list)
			if(arg.arg_type & VERB_ARG_TYPE_ENTITY)
				entity_arg = arg
				break
		if(!entity_arg)
			return TRUE
		var/list/target_data = list()
		var/list/source_atoms = entity_arg.get_targets(client)
		for(var/atom/target in source_atoms)
			target_data += list(list("name" = "[target]", "ref" = target.UID()))
		window.send_message("verbs/targets", list("targets" = target_data))
		return TRUE

	if(type == "verbs/invoke")
		var/verb_path = text2path(payload["verb_type"])
		if(!verb_path)
			return TRUE

		var/datum/admin_verb/admin_meta = SSadmin_verbs.admin_verbs_by_verb_path[verb_path]
		if(admin_meta)
			var/list/resolved_args = resolve_invoke_args(payload["args"], admin_meta.arguments)
			SSadmin_verbs.dynamic_invoke_verb(client, admin_meta.type, resolved_args)
			return TRUE
		var/datum/verb_metadata/meta = SSverbs.verbs_by_verb_path[verb_path]
		if(!meta)
			return TRUE
		var/target = resolve_verb_target(verb_path)
		if(!target)
			return TRUE
		if(!(verb_path in client.verbs) && !(client.mob && (verb_path in client.mob.verbs)))
			return TRUE
		var/list/resolved_args = resolve_invoke_args(payload["args"], meta.arguments)
		call(target, meta.body_path)(resolved_args)
		return TRUE
	if(type == "requestMetadata")
		send_metadata()
		return TRUE

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart(position)
	window.send_message("roundrestart", list(
		"autoreconnect" = CONFIG_GET(flag/autoreconnect) && CONFIG_GET(flag/shutdown_on_reboot) && !CONFIG_GET(string/server),
		"position" = position,
	))

/**
 * public
 *
 * Sends the client's current job, character and saved character names,
 * used for conditional chat highlights.
 */
/datum/tgui_panel/proc/send_player_info()
	window.send_message("player/set", list(
		"job" = client.mob?.mind?.assigned_role,
		"character" = client.mob?.real_name,
		"characters" = /*client.prefs?.create_character_profiles()*/ list(client.mob?.real_name),
	))

/**
 * private
 *
 * Sent when a client requests metadata - used for websocket stuff.
 */
/datum/tgui_panel/proc/send_metadata()
	var/static/list/webroot_asset_urls

	var/list/metadata = list(
		"game_version" = GLOB.game_version,
		"server_name" = CONFIG_GET(string/servername),
		"round_id" = GLOB.round_id,
		"map_name" = SSmapping.map_datum?.name,
		"round_duration" = round(STATION_TIME_PASSED() / 10, 1),
		"gamestate" = SSticker.current_state,
	)
	// if we're using webroot - also pass along the webroot url and such, so we can embed chat logs with the proper styles/images if desired
	if(istype(SSassets.transport, /datum/asset_transport/webroot))
		if(isnull(webroot_asset_urls))
			webroot_asset_urls = list()
			for(var/asset_type in list(/datum/asset/simple/tgui_panel, /datum/asset/simple/namespaced/fontawesome, /datum/asset/simple/namespaced/tgfont, /datum/asset/spritesheet_batched/chat))
				var/datum/asset/asset = get_asset_datum(asset_type)
				webroot_asset_urls += asset.get_url_mappings()
		metadata["webroot"] = list(
			"base_url" = CONFIG_GET(string/asset_cdn_url),
			"assets" = webroot_asset_urls,
		)
	window.send_message("metadata", metadata)

/datum/tgui_panel/proc/resolve_invoke_args(list/raw_args, list/arg_metadata)
	if(!islist(raw_args))
		raw_args = list()
	var/alist/resolved = alist()
	for(var/datum/verb_arg_metadata/meta in arg_metadata)
		if(!(meta.name in raw_args))
			continue
		var/value = raw_args[meta.name]
		if(meta.arg_type & VERB_ARG_TYPE_NUM)
			value = text2num(value)
		else if(meta.arg_type & VERB_ARG_TYPE_ENTITY && istext(value))
			var/located = locateUID(value)
			if(!located)
				continue
			var/list/valid_targets = meta.get_targets(client)
			if(length(valid_targets) && !(located in valid_targets))
				continue
			value = located
		resolved[meta.name] = value
	return resolved

/datum/tgui_panel/proc/resolve_verb_target(verb_path)
	if(verb_path in client.verbs)
		return client
	if(client.mob && (verb_path in client.mob.verbs))
		return client.mob
	return null

/datum/tgui_panel/proc/send_hotkey_mode()
	window.send_message("verbs/hotkey_mode", list("hotkeys" = client.hotkeys))
