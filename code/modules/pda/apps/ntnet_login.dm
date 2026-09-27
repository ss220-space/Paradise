#define NTNET_LOGIN_TIMEOUT (20 SECONDS)
#define NTNET_LOGIN_COOLDOWN (1 MINUTES)
#define NTNET_CODE_LIFETIME (15 MINUTES)
#define NTNET_LOGIN_MAX_BODY 4096
#define NTNET_VIEWER_TOKEN_TTL (1 HOURS)
#define NTNET_VIEWER_TOKEN_MARGIN (5 MINUTES)
#define NTNET_VIEWER_TOKEN_TIMEOUT (20 SECONDS)
#define NTNET_VIEWER_TOKEN_COOLDOWN (10 SECONDS)
#define NTNET_VIEWER_MAX_TOKENS 16
#define NTNET_VIEWER_MAX_TOKEN_LENGTH 1024
#define NTNET_VIEWER_MAX_NAME 64

/datum/controller/subsystem/ntnet/proc/request_login(client/user)
	if(!user || !is_enabled() || user.ntnet_login_pending || world.time < user.ntnet_login_retry)
		return
	var/identity = verified_identity(user)
	if(!identity)
		user.ntnet_login_error = "Для входа нужен подтверждённый BYOND-аккаунт."
		return
	user.ntnet_code = null
	user.ntnet_code_expires = 0
	user.ntnet_login_error = null
	user.ntnet_login_pending = TRUE
	user.ntnet_login_retry = world.time + NTNET_LOGIN_COOLDOWN
	user.ntnet_login_request++
	var/user_uid = user.UID()
	var/request_id = user.ntnet_login_request
	var/list/headers = list("X-Server-Key" = CONFIG_GET(string/ntnet_server_key), "Content-Type" = "application/json")
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, "[CONFIG_GET(string/ntnet_api_url)]/api/v1/device/new", json_encode(list("ckey" = identity)), headers, CALLBACK(src, PROC_REF(on_login), user_uid, identity, request_id), sensitive = TRUE)
	addtimer(CALLBACK(src, PROC_REF(login_timeout), user_uid, request_id), NTNET_LOGIN_TIMEOUT)

/datum/controller/subsystem/ntnet/proc/login_timeout(user_uid, request_id)
	var/client/user = locateUID(user_uid)
	if(!user || !user.ntnet_login_pending || user.ntnet_login_request != request_id)
		return
	user.ntnet_login_pending = FALSE
	user.ntnet_login_error = "NTnet не ответил. Попробуйте снова через минуту."

/datum/controller/subsystem/ntnet/proc/on_login(user_uid, identity, request_id, datum/http_response/response)
	var/client/user = locateUID(user_uid)
	if(!user || !user.ntnet_login_pending || user.ntnet_login_request != request_id)
		return
	user.ntnet_login_pending = FALSE
	if((user.account_ckey || user.ckey) != identity)
		return
	user.ntnet_login_error = "Не удалось получить код. Попробуйте снова через минуту."
	var/code = parse_ntnet_login_response(response)
	if(!code)
		return
	user.ntnet_code = code
	user.ntnet_code_expires = world.time + NTNET_CODE_LIFETIME - NTNET_LOGIN_TIMEOUT
	user.ntnet_login_error = null
	var/editor_url = html_encode(CONFIG_GET(string/ntnet_editor_url))
	to_chat(user, span_notice("NTnet: Ваш одноразовый код — [user.ntnet_code]. Действует до 15 минут. <a href='[editor_url]'>Открыть редактор</a>. Не передавайте код другим игрокам."), confidential = TRUE)

/datum/controller/subsystem/ntnet/proc/verified_identity(client/user)
	var/identity = user.account_ckey || user.ckey
	if((is_guest_key(user.key) && !user.is_launcher_client()) || is_launcher_ckey(identity) || (user.is_launcher_client() && user.launcher_state != LAUNCHER_VERIFIED))
		return null
	return identity

/datum/controller/subsystem/ntnet/proc/viewer_token(client/user, site_id)
	if(!user)
		return null
	var/list/entry = user.ntnet_viewer_tokens[site_id]
	if(!entry || world.time > entry["expires"])
		return null
	return entry["token"]

/datum/controller/subsystem/ntnet/proc/request_viewer_token(client/user, site_id, character_name, renew = FALSE)
	if(!user || !is_enabled() || !CONFIG_GET(flag/ntnet_interactive) || !istext(site_id) || !sites[site_id])
		return
	var/list/entry = user.ntnet_viewer_tokens[site_id]
	if(renew && entry)
		entry["expires"] = 0
	if(viewer_token(user, site_id))
		return
	if(entry && (world.time < entry["pending"] || world.time < entry["retry"]))
		return
	if(!entry && length(user.ntnet_viewer_tokens) >= NTNET_VIEWER_MAX_TOKENS)
		user.ntnet_viewer_tokens.Cut(1, 2)
	entry = list("pending" = world.time + NTNET_VIEWER_TOKEN_TIMEOUT, "retry" = world.time + NTNET_VIEWER_TOKEN_COOLDOWN)
	user.ntnet_viewer_tokens[site_id] = entry
	var/identity = verified_identity(user)
	if(!identity)
		entry["pending"] = 0
		entry["error"] = "Для базы сайта нужен подтверждённый BYOND-аккаунт."
		return
	var/list/headers = list("X-Server-Key" = CONFIG_GET(string/ntnet_server_key), "Content-Type" = "application/json")
	var/body = json_encode(list("ckey" = identity, "site_id" = site_id, "name" = copytext_char(character_name, 1, NTNET_VIEWER_MAX_NAME + 1)))
	SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, "[CONFIG_GET(string/ntnet_api_url)]/api/v1/viewer-token", body, headers, CALLBACK(src, PROC_REF(on_viewer_token), user.UID(), identity, site_id), sensitive = TRUE)

/datum/controller/subsystem/ntnet/proc/on_viewer_token(user_uid, identity, site_id, datum/http_response/response)
	var/client/user = locateUID(user_uid)
	if(!user || (user.account_ckey || user.ckey) != identity)
		return
	var/list/entry = user.ntnet_viewer_tokens[site_id]
	if(!entry || !entry["pending"])
		return
	entry["pending"] = 0
	var/token = parse_ntnet_viewer_token(response)
	if(!token)
		entry["error"] = "Не удалось получить доступ к базе сайта."
		return
	entry -= "error"
	entry["token"] = token
	entry["expires"] = world.time + NTNET_VIEWER_TOKEN_TTL - NTNET_VIEWER_TOKEN_MARGIN

/proc/parse_ntnet_viewer_token(datum/http_response/response)
	if(response.errored || response.status_code != 201 || !istext(response.body) || length(response.body) > NTNET_LOGIN_MAX_BODY)
		return
	var/list/document = safe_json_decode(response.body)
	if(!islist(document) || !istext(document["token"]) || length(document["token"]) > NTNET_VIEWER_MAX_TOKEN_LENGTH || document["expires_in"] != NTNET_VIEWER_TOKEN_TTL / (1 SECONDS))
		return
	var/static/regex/token_pattern = regex(@"^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$")
	if(!token_pattern.Find(document["token"]))
		return
	return document["token"]

/proc/parse_ntnet_login_response(datum/http_response/response)
	if(response.errored || response.status_code != 201 || !istext(response.body) || length(response.body) > NTNET_LOGIN_MAX_BODY)
		return
	var/list/document = safe_json_decode(response.body)
	if(!islist(document) || !istext(document["code"]) || document["expires_in"] != NTNET_CODE_LIFETIME / (1 SECONDS))
		return
	var/static/regex/code_pattern = regex("^\[23456789ABCDEFGHJKLMNPQRSTUVWXYZ\]{4}-\[23456789ABCDEFGHJKLMNPQRSTUVWXYZ\]{4}-\[23456789ABCDEFGHJKLMNPQRSTUVWXYZ\]{4}$")
	if(!code_pattern.Find(document["code"]))
		return
	return document["code"]

#undef NTNET_LOGIN_TIMEOUT
#undef NTNET_LOGIN_COOLDOWN
#undef NTNET_CODE_LIFETIME
#undef NTNET_LOGIN_MAX_BODY
#undef NTNET_VIEWER_TOKEN_TTL
#undef NTNET_VIEWER_TOKEN_MARGIN
#undef NTNET_VIEWER_TOKEN_TIMEOUT
#undef NTNET_VIEWER_TOKEN_COOLDOWN
#undef NTNET_VIEWER_MAX_TOKENS
#undef NTNET_VIEWER_MAX_TOKEN_LENGTH
#undef NTNET_VIEWER_MAX_NAME
