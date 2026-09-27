GLOBAL_LIST_EMPTY(launcher_account_aliases)

/proc/is_launcher_ckey(test_ckey)
	return findtext(test_ckey, LAUNCHER_CKEY_PREFIX, 1, length(LAUNCHER_CKEY_PREFIX) + 1) == 1

/proc/load_launcher_aliases()
	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT launcher_ckey, ckey FROM [format_table_name("launcher_link_request")]
		WHERE approved = 1 ORDER BY resolved
	"})

	if(!query.warn_execute(async = FALSE))
		qdel(query)
		return

	while(query.NextRow())
		GLOB.launcher_account_aliases[query.item[1]] = query.item[2]
	qdel(query)

/mob/proc/get_account_ckey()
	return client?.account_ckey || persistent_client?.account_ckey || ckey

/client/proc/is_launcher_client()
	return account_ckey != ckey

/client/proc/display_key()
	if(!is_launcher_client())
		return key
	if(!is_launcher_ckey(account_ckey))
		return account_ckey
	return launcher_nickname ? "[launcher_nickname] (Steam)" : key

/client/proc/request_launcher_link()
	launcher_link_target = null
	if(!is_launcher_client() || !SSdbcore.IsConnected())
		return LAUNCHER_LINK_NONE
	if(GLOB.launcher_account_aliases[launcher_claimed_ckey])
		return LAUNCHER_LINK_NONE

	var/datum/db_query/query_sibling = SSdbcore.NewQuery({"
		SELECT byond.ckey FROM [format_table_name("player")] AS launcher
		INNER JOIN [format_table_name("player")] AS byond ON byond.discord_id = launcher.discord_id
		WHERE launcher.ckey = :ckey AND byond.ckey NOT LIKE :prefix
		AND LENGTH(launcher.discord_id) < :token_length
		LIMIT 1
	"}, list("ckey" = launcher_claimed_ckey, "prefix" = "[LAUNCHER_CKEY_PREFIX]%", "token_length" = DISCORD_TOKEN_LENGTH))

	if(!query_sibling.warn_execute())
		qdel(query_sibling)
		return LAUNCHER_LINK_NONE

	if(query_sibling.NextRow())
		launcher_link_target = query_sibling.item[1]
	qdel(query_sibling)

	if(!launcher_link_target)
		return LAUNCHER_LINK_NONE

	var/datum/db_query/query_request = SSdbcore.NewQuery({"
		SELECT approved FROM [format_table_name("launcher_link_request")]
		WHERE launcher_ckey = :launcher_ckey AND ckey = :ckey
	"}, list("launcher_ckey" = launcher_claimed_ckey, "ckey" = launcher_link_target))

	if(!query_request.warn_execute())
		qdel(query_request)
		return LAUNCHER_LINK_NONE

	var/known_request = FALSE
	var/approved
	if(query_request.NextRow())
		known_request = TRUE
		approved = query_request.item[1]
	qdel(query_request)

	if(!known_request)
		var/datum/db_query/query_insert = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("launcher_link_request")] (launcher_ckey, ckey)
			VALUES (:launcher_ckey, :ckey)
		"}, list("launcher_ckey" = launcher_claimed_ckey, "ckey" = launcher_link_target))
		query_insert.warn_execute()
		qdel(query_insert)
		log_game("Launcher account [launcher_claimed_ckey] asked to be linked to [launcher_link_target]")
		var/client/target = GLOB.directory[launcher_link_target]
		if(target)
			INVOKE_ASYNC(target, TYPE_PROC_REF(/client, prompt_launcher_link), launcher_claimed_ckey)
		return LAUNCHER_LINK_PENDING

	if(isnull(approved))
		return LAUNCHER_LINK_PENDING

	if(!text2num("[approved]"))
		return LAUNCHER_LINK_REJECTED

	GLOB.launcher_account_aliases[launcher_claimed_ckey] = launcher_link_target
	return LAUNCHER_LINK_APPROVED

/client/proc/blocked_by_launcher_link()
	switch(request_launcher_link())
		if(LAUNCHER_LINK_PENDING)
			to_chat(src, span_danger("Этот Discord привязан к игровому аккаунту [launcher_link_target]."), confidential = TRUE)
			to_chat(src, span_warning("Зайдите в игру под [launcher_link_target] и подтвердите связку — так мы убеждаемся, что оба аккаунта ваши."), confidential = TRUE)
			return TRUE
		if(LAUNCHER_LINK_REJECTED)
			to_chat(src, span_danger("Владелец аккаунта [launcher_link_target] отклонил связку. Обратитесь к администрации."), confidential = TRUE)
			return TRUE
		if(LAUNCHER_LINK_APPROVED)
			to_chat(src, span_danger("Связка с [launcher_link_target] подтверждена."), confidential = TRUE)
			to_chat(src, span_warning("Перезайдите на сервер, чтобы играть под ним со всеми своими персонажами и наигранным временем."), confidential = TRUE)
			return TRUE
	return FALSE

/client/proc/check_launcher_link_requests()
	set waitfor = FALSE
	if(is_launcher_client() || !SSdbcore.IsConnected())
		return

	var/datum/db_query/query = SSdbcore.NewQuery({"
		SELECT launcher_ckey FROM [format_table_name("launcher_link_request")]
		WHERE ckey = :ckey AND approved IS NULL
	"}, list("ckey" = account_ckey))

	if(!query.warn_execute())
		qdel(query)
		return

	var/list/pending = list()
	while(query.NextRow())
		pending += query.item[1]
	qdel(query)

	for(var/launcher_ckey in pending)
		prompt_launcher_link(launcher_ckey)

/client/proc/prompt_launcher_link(launcher_ckey)
	var/answer = tgui_alert(src, "Аккаунт лаунчера [launcher_ckey] просит связать себя с вашим аккаунтом. После связки вход из Steam будет идти под [account_ckey]: те же персонажи, настройки и наигранное время. Если это не вы — откажите и смените пароль от Discord.", "Связка аккаунтов", list("Подтвердить", "Отклонить"), timeout = 5 MINUTES)
	if(!answer)
		return

	var/approved = answer == "Подтвердить"
	var/datum/db_query/query = SSdbcore.NewQuery({"
		UPDATE [format_table_name("launcher_link_request")] SET approved = :approved, resolved = Now()
		WHERE launcher_ckey = :launcher_ckey AND ckey = :ckey AND approved IS NULL
	"}, list("approved" = approved, "launcher_ckey" = launcher_ckey, "ckey" = account_ckey))

	if(!query.warn_execute())
		qdel(query)
		return
	qdel(query)

	if(approved)
		GLOB.launcher_account_aliases[launcher_ckey] = account_ckey
		to_chat(src, span_notice("Аккаунт лаунчера [launcher_ckey] связан с вашим."), confidential = TRUE)
	else
		to_chat(src, span_notice("Связка с [launcher_ckey] отклонена."), confidential = TRUE)

	log_game("[account_ckey] [approved ? "approved" : "rejected"] the launcher link with [launcher_ckey]")
	message_admins("[key_name_admin(src)] [approved ? "подтвердил" : "отклонил"] связку с аккаунтом лаунчера [launcher_ckey].")

/client/proc/has_persistent_identity()
	return !is_guest_key(key) || launcher_state == LAUNCHER_VERIFIED

/client/proc/setup_account_ckey(connectiontopic)
	account_ckey = ckey

	var/client/squatter = GLOB.directory[ckey]
	if(squatter && squatter != src && squatter.is_launcher_client())
		addtimer(CALLBACK(squatter, TYPE_PROC_REF(/client, reject_launcher_client), "Владелец аккаунта [ckey] зашёл через BYOND."))

	if(!CONFIG_GET(string/launcher_api_url))
		return

	var/list/connection_params = params2list(connectiontopic)
	if(!connection_params["launcher_token"])
		return

	var/claimed_ckey = ckey(connection_params["launcher_ckey"])
	if(!is_launcher_ckey(claimed_ckey))
		return

	launcher_claimed_ckey = claimed_ckey
	if(!is_guest_key(key))
		return

	if(GLOB.directory[claimed_ckey])
		launcher_claimed_ckey = null
		addtimer(CALLBACK(src, PROC_REF(reject_launcher_client), "Этот аккаунт лаунчера уже в игре."))
		return

	var/linked_ckey = GLOB.launcher_account_aliases[claimed_ckey]
	account_ckey = (linked_ckey && !GLOB.directory[linked_ckey]) ? linked_ckey : claimed_ckey
	launcher_state = LAUNCHER_PENDING
	addtimer(CALLBACK(src, PROC_REF(launcher_link_timeout)), LAUNCHER_VERIFY_TIMEOUT)

/client/proc/launcher_link_timeout()
	if(launcher_state != LAUNCHER_PENDING)
		return

	reject_launcher_client("Сервис лаунчера не ответил.")

/client/proc/check_launcher_link(connectiontopic)
	set waitfor = FALSE
	var/api_url = CONFIG_GET(string/launcher_api_url)
	if(!api_url)
		return

	var/list/connection_params = params2list(connectiontopic)
	var/token = connection_params["launcher_token"]
	if(!token)
		reject_unlinked_client()
		return

	var/list/headers = list(
		"content-type" = "application/json",
		"x-game-secret" = CONFIG_GET(string/launcher_api_secret),
	)
	var/body = json_encode(list(
		"token" = token,
		"serverId" = CONFIG_GET(string/launcher_server_id),
	))
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, "[api_url]/v1/connect/verify", body, headers, CALLBACK(src, PROC_REF(on_launcher_link_response), connectiontopic))

/client/proc/on_launcher_link_response(connectiontopic, datum/http_response/response)
	if(QDELETED(src))
		return

	if(!response || response.errored || response.status_code != 200 || !response.body)
		fail_launcher_link("Не удалось подтвердить вход через лаунчер.")
		return

	var/list/data = safe_json_decode(response.body)
	if(!islist(data) || !data["steamid64"])
		fail_launcher_link("Не удалось подтвердить вход через лаунчер.")
		return

	if(data["ckey"] != launcher_claimed_ckey)
		log_adminwarn("Launcher identity mismatch: [key] claimed [launcher_claimed_ckey], backend returned [data["ckey"]]")
		fail_launcher_link("Учётная запись лаунчера не совпала с заявленной.")
		return

	steam_id = data["steamid64"]
	launcher_nickname = sanitize(copytext_char(data["nickname"], 1, LAUNCHER_NICKNAME_MAX_LEN))
	store_launcher_link()

	if(launcher_state != LAUNCHER_PENDING)
		approve_launcher_link()
		return

	launcher_state = LAUNCHER_VERIFIED
	bind_verified_preferences()
	log_client_to_db(connectiontopic)
	claim_admin_holder()
	if(holder)
		add_admin_verbs()
		INVOKE_ASYNC(src, PROC_REF(announce_join))
		INVOKE_ASYNC(src, PROC_REF(admin_memo_output), "Show", FALSE, TRUE)
	donator_check()
	referral_payout_check()

/client/proc/bind_verified_preferences()
	var/datum/preferences/stored = GLOB.preferences_datums[account_ckey]
	if(stored)
		prefs = stored
		prefs.parent = src
	else
		GLOB.preferences_datums[account_ckey] = prefs
		if(prefs.load_preferences(src) && prefs.load_character(src))
			prefs.init_custom_emotes(prefs.custom_emotes)

	apply_preferences()

/client/proc/fail_launcher_link(reason)
	if(launcher_state != LAUNCHER_PENDING)
		log_game("Launcher link check failed for [account_ckey]: [reason]")
		return

	reject_launcher_client(reason)

/client/proc/approve_launcher_link()
	if(!launcher_claimed_ckey || !SSdbcore.IsConnected() || GLOB.launcher_account_aliases[launcher_claimed_ckey] == account_ckey)
		return

	var/datum/db_query/query = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("launcher_link_request")] (launcher_ckey, ckey, resolved, approved)
		VALUES (:launcher_ckey, :ckey, Now(), 1)
		ON DUPLICATE KEY UPDATE resolved = Now(), approved = 1
	"}, list("launcher_ckey" = launcher_claimed_ckey, "ckey" = account_ckey))

	if(!query.warn_execute())
		qdel(query)
		return
	qdel(query)

	GLOB.launcher_account_aliases[launcher_claimed_ckey] = account_ckey
	log_game("Launcher account [launcher_claimed_ckey] linked to [account_ckey] by BYOND login")
	to_chat(src, span_notice("Ваш аккаунт лаунчера [launcher_claimed_ckey] связан с [account_ckey]."), confidential = TRUE)

/client/proc/store_launcher_link()
	if(!SSdbcore.IsConnected())
		return

	var/datum/db_query/query = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("launcher_link")] (steamid64, ckey, nickname)
		VALUES (:steamid, :ckey, :nickname)
		ON DUPLICATE KEY UPDATE ckey = :ckey, nickname = :nickname, last_seen = Now()
	"}, list("steamid" = steam_id, "ckey" = account_ckey, "nickname" = copytext_char(launcher_nickname, 1, LAUNCHER_NICKNAME_MAX_LEN + 1)))
	query.warn_execute()
	qdel(query)

/client/proc/check_launcher_ban()
	set waitfor = FALSE
	if(!is_launcher_client())
		return

	var/ban_message
	if(CONFIG_GET(flag/ban_legacy_system))
		var/list/legacy_ban = CheckBan(account_ckey, computer_id, address)
		if(legacy_ban)
			ban_message = "Учётная запись [account_ckey] заблокирована.[legacy_ban["desc"]]"
	else
		if(!SSdbcore.IsConnected())
			log_world("Ban database connection failure. Launcher account [account_ckey] not checked")
			return

		var/datum/db_query/query = SSdbcore.NewQuery({"
			SELECT a_ckey, reason, expiration_time, duration, bantime, bantype FROM [CONFIG_GET(string/utility_database)].[format_table_name("ban")]
			WHERE ckey = :ckey AND (bantype = 'PERMABAN' OR bantype = 'ADMIN_PERMABAN'
			OR ((bantype = 'TEMPBAN' OR bantype = 'ADMIN_TEMPBAN') AND expiration_time > Now())) AND isnull(unbanned)
		"}, list("ckey" = account_ckey))

		if(!query.warn_execute())
			message_admins("Failed to do a launcher ban check for [account_ckey]. You have been warned.")
			qdel(query)
			return

		while(query.NextRow())
			var/a_ckey = query.item[1]
			var/reason = query.item[2]
			var/expiration = query.item[3]
			var/duration = query.item[4]
			var/bantime = query.item[5]
			var/bantype = query.item[6]
			var/is_admin_ban = bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN"
			if(holder && (holder.rights & R_ADMIN) && !is_admin_ban)
				log_admin("The admin [account_ckey] has been allowed to bypass a matching ban")
				continue
			var/expires = "Бан не истекает автоматически, его нужно обжаловать."
			if(text2num(duration) > 0)
				expires = "Бан выдан на [duration] минут и истекает [expiration] (время сервера)."
			var/appeal = ""
			if(CONFIG_GET(string/banappeals))
				appeal = " Обжаловать можно здесь: [CONFIG_GET(string/banappeals)]"
			ban_message = "Учётная запись [account_ckey] заблокирована. Причина: [reason]. Бан выдал [a_ckey], [bantime]. [expires][appeal]"
			break

		qdel(query)

	if(!ban_message)
		return

	log_adminwarn("Failed Login: [key]/[account_ckey] [computer_id] [address] - Banned launcher account")
	to_chat(src, span_danger(ban_message), confidential = TRUE)
	qdel(src)

/client/proc/reject_launcher_client(reason)
	to_chat(src, span_danger("[reason] Запустите игру из лаунчера или войдите с аккаунтом BYOND."), confidential = TRUE)
	qdel(src)

/client/proc/reject_unlinked_client()
	if(!CONFIG_GET(flag/launcher_required))
		return
	if(!is_guest_key(key))
		return

	reject_launcher_client("Вход без лаунчера здесь закрыт.")
