/// Max queries to ip-api.com per window, see [GLOB.geoip_next_counter_reset]. The free ip-api tier is 45 rpm.
#define GEOIP_QUERY_LIMIT 60
/// Length of the query counter window (90 seconds).
#define GEOIP_QUERY_WINDOW (90 SECONDS)
/// Set of fields requested from ip-api.com. Named fields are more robust than a bitmask.
#define GEOIP_API_FIELDS "status,message,country,countryCode,region,regionName,city,timezone,isp,mobile,proxy,query"

GLOBAL_LIST_INIT(isp_blacklist, world.file2list("config/isp/isp_blacklist.txt"))
GLOBAL_LIST_INIT(isp_whitelist, world.file2list("config/isp/isp_whitelist.txt"))

/**
 * # GeoIP data
 *
 * Cached GeoIP lookup result for a single [/client].
 *
 * Created on the client at login and populated asynchronously via [SShttp] and ip-api.com.
 * While the request is in flight [status] is `"pending"`; on success it becomes `"updated"`,
 * otherwise it holds a diagnostic value: `"admin"`, `"local"`, `"no address"`,
 * `"limit reached"`, `"export fail"`, or `"api fail: <message>"`.
 */
/datum/geoip_data
	/// Ckey of the client this lookup was performed for.
	var/holder = null
	/// Request status: `null` before start, `"pending"` in flight, `"updated"` on success, otherwise an error string.
	var/status = null
	/// Country name (e.g. `"Russia"`).
	var/country = null
	/// Two-letter ISO country code (e.g. `"RU"`).
	var/countryCode = null
	/// Region code.
	var/region = null
	/// Human-readable region name.
	var/regionName = null
	/// City.
	var/city = null
	/// Timezone in the form `"Europe/Moscow"`.
	var/timezone = null
	/// The client's ISP according to ip-api.
	var/isp = null
	/// `"true"`/`"false"` — whether ip-api considers the connection mobile.
	var/mobile = null
	/**
	 * Final proxy/VPN flag. Initially `"true"`/`"false"` from ip-api, then corrected against
	 * `isp_whitelist`/`isp_blacklist`, and finally for admin display it turns into an HTML
	 * string (`"whitelisted"` in orange or `"true"` in red).
	 */
	var/proxy = null
	/// Client IP as reported by ip-api (the `query` field of the response).
	var/ip = null

/datum/geoip_data/New(client/client, address)
	INVOKE_ASYNC(src, PROC_REF(get_geoip_data), client, address)

/**
 * Entry point for the asynchronous GeoIP lookup. Handles short branches (no address,
 * admin client) and delegates the network request to [try_update_geoip].
 *
 * Arguments:
 * * client - the client we are collecting data for
 * * address - the client's IP address (usually `client.address`)
 */
/datum/geoip_data/proc/get_geoip_data(client/client, address)
	if(!client)
		return

	if(!address)
		status = "no address"
		return

	if(client.holder && (client.holder.rights & R_ADMIN))
		status = "admin"
		return

	try_update_geoip(client, address)

/**
 * Kicks off (if not already started) an async request to ip-api and returns. The datum
 * fields are filled in by [on_geoip_response], invoked by [SShttp] once the request finishes.
 *
 * Safe to call repeatedly — while `status` is `"pending"` or `"updated"` it is a no-op.
 * Returns FALSE when no request was dispatched (local address, limit exceeded, etc.).
 *
 * Arguments:
 * * client - the client this record belongs to
 * * address - the IP address to query. `127.0.0.1` is substituted with `world.internet_address`.
 */
/datum/geoip_data/proc/try_update_geoip(client/client, address)
	if(!client || !address)
		return FALSE

	if(status == "updated" || status == "pending")
		return TRUE

	if(address == "127.0.0.1")
		if(!world.internet_address)
			status = "local"
			ip = address
			return FALSE
		address = "[world.internet_address]"

	if(world.time > GLOB.geoip_next_counter_reset)
		GLOB.geoip_next_counter_reset = world.time + GEOIP_QUERY_WINDOW
		GLOB.geoip_query_counter = 0

	GLOB.geoip_query_counter++
	if(GLOB.geoip_query_counter > GEOIP_QUERY_LIMIT)
		status = "limit reached"
		return FALSE

	holder = client.ckey
	status = "pending"

	var/datum/callback/callback = CALLBACK(src, PROC_REF(on_geoip_response), client)
	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, "http://ip-api.com/json/[address]?fields=[GEOIP_API_FIELDS]", "", null, callback)
	return TRUE

/**
 * [SShttp] callback for an ip-api response. Parses JSON, fills in the datum fields, applies
 * the ISP whitelist/blacklist to [proxy] and, on a confirmed proxy, triggers the autoban
 * path (if enabled in config).
 *
 * Arguments:
 * * client - the client whose record we are updating. May be `null` if the client has already left.
 * * response - the ip-api response, wrapped into a [/datum/http_response] by [SShttp].
 */
/datum/geoip_data/proc/on_geoip_response(client/client, datum/http_response/response)
	if(!response || response.errored || response.status_code != 200 || !response.body)
		status = "export fail"
		return

	var/list/data = safe_json_decode(response.body)

	if(!islist(data))
		status = "export fail"
		return

	if(data["status"] == "fail")
		status = "api fail: [data["message"]]"
		ip = data["query"]
		return

	country = data["country"]
	countryCode = data["countryCode"]
	region = data["region"]
	regionName = data["regionName"]
	city = data["city"]
	timezone = data["timezone"]
	isp = data["isp"]
	mobile = data["mobile"] ? "true" : "false"
	proxy = data["proxy"] ? "true" : "false"
	ip = data["query"]

	if(proxy == "true")
		proxy = (isp in GLOB.isp_whitelist) ? "false" : "true"
	else
		proxy = (isp in GLOB.isp_blacklist) ? "true" : "false"

	status = "updated"

	if(!client)
		return

	var/msg = "[holder] connected from ([country], [regionName], [city]) using ISP: ([isp]) with IP: ([ip]) Proxy: ([proxy])"
	log_admin(msg)
	if(SSticker.current_state > GAME_STATE_STARTUP && !(client.ckey in GLOB.geoip_ckey_updated))
		GLOB.geoip_ckey_updated |= client.ckey
		message_admins(msg)

	if(proxy != "true")
		return

	if(proxy_whitelist_check(client.ckey))
		proxy = span_orange("whitelisted")
		return

	proxy = span_red("true")
	if(!CONFIG_GET(flag/proxy_autoban))
		return

	var/reason = "Ваш IP определяется как прокси. Прокси запрещены на сервере. Обратитесь к администрации за разрешением. Client ISP: ([isp])"
	AddBan(client.ckey, client.computer_id, reason, "SyndiCat", 0, 0, client.mob.lastKnownIP)
	to_chat(client, span_danger(span_bigbold("You have been banned by SyndiCat.\nReason: [reason].")))
	to_chat(client, span_red("This is a permanent ban."))
	if(CONFIG_GET(string/banappeals))
		to_chat(client, span_red("To try to resolve this matter head to [CONFIG_GET(string/banappeals)]"))
	else
		to_chat(client, span_red("No ban appeals URL has been set."))
	ban_unban_log_save("SyndiCat has permabanned [client.ckey]. - Reason: [reason] - This is a permanent ban.")
	log_admin("SyndiCat has banned [client.ckey].")
	log_admin("Reason: [reason]")
	log_admin("This is a permanent ban.")
	message_admins("SyndiCat has banned [client.ckey].\nReason: [reason]\nThis is a permanent ban.")
	DB_ban_record_SyndiCat(BANTYPE_PERMA, client.mob, -1, reason)
	qdel(client)

#undef GEOIP_QUERY_LIMIT
#undef GEOIP_QUERY_WINDOW
#undef GEOIP_API_FIELDS

/**
 * Static per-bantype metadata used by [/proc/DB_ban_record_SyndiCat]:
 * * `str` — display string used in the DB row and admin messages.
 * * `perma` — TRUE if this type forces `duration = -1`.
 * * `jobban` — TRUE for job bans (also triggers `jobban_client_fullban`).
 * * `announce` — TRUE for admin bans (posts to the admin Discord webhook).
 * * `kick` — TRUE for admin bans (kicks the banned client from the server after insert).
 */
GLOBAL_LIST_INIT(syndicat_bantype_meta, list(
	"[BANTYPE_PERMA]" = list("str" = "PERMABAN", "perma" = TRUE, "jobban" = FALSE, "announce" = FALSE, "kick" = FALSE),
	"[BANTYPE_TEMP]" = list("str" = "TEMPBAN", "perma" = FALSE, "jobban" = FALSE, "announce" = FALSE, "kick" = FALSE),
	"[BANTYPE_JOB_PERMA]" = list("str" = "JOB_PERMABAN", "perma" = TRUE, "jobban" = TRUE, "announce" = FALSE, "kick" = FALSE),
	"[BANTYPE_JOB_TEMP]" = list("str" = "JOB_TEMPBAN", "perma" = FALSE, "jobban" = TRUE, "announce" = FALSE, "kick" = FALSE),
	"[BANTYPE_APPEARANCE]" = list("str" = "APPEARANCE_BAN", "perma" = TRUE, "jobban" = FALSE, "announce" = FALSE, "kick" = FALSE),
	"[BANTYPE_ADMIN_PERMA]" = list("str" = "ADMIN_PERMABAN", "perma" = TRUE, "jobban" = FALSE, "announce" = TRUE, "kick" = TRUE),
	"[BANTYPE_ADMIN_TEMP]" = list("str" = "ADMIN_TEMPBAN", "perma" = FALSE, "jobban" = FALSE, "announce" = TRUE, "kick" = TRUE),
))

/**
 * Inserts a ban row into the SQL ban table on behalf of the synthetic admin `SyndiCat`.
 *
 * Used by the proxy autoban path driven by GeoIP (see [/datum/geoip_data/proc/on_geoip_response]).
 * Supports every standard ban type (`BANTYPE_PERMA`, `BANTYPE_TEMP`, job and appearance bans,
 * admin bans); kicks the target when required and mirrors admin bans to Discord.
 *
 * Arguments:
 * * bantype - one of the `BANTYPE_*` defines from [code/__DEFINES/admin.dm]
 * * banned_mob - the target's mob (or `null` when banning by ckey)
 * * duration - duration in minutes, `-1` for permanent bans
 * * reason - ban reason, must be text
 * * job - for job bans: the job title
 * * rounds - duration in rounds (job bans only)
 * * banckey - target ckey when `banned_mob` is absent
 * * banip - target IP when `banned_mob` is absent
 * * bancid - target computer id when `banned_mob` is absent
 */
/proc/DB_ban_record_SyndiCat(bantype, mob/banned_mob, duration = -1, reason, job = "", rounds = 0, banckey = null, banip = null, bancid = null)
	if(!SSdbcore.IsConnected())
		return

	var/list/meta = GLOB.syndicat_bantype_meta["[bantype]"]
	if(!meta)
		return
	if(!istext(reason))
		return
	if(!isnum(duration))
		return

	var/bantype_str = meta["str"]
	if(meta["perma"])
		duration = -1

	// Resolve target ckey/computerid/ip from either the mob or the explicit ckey fallback.
	var/ckey
	var/computerid
	var/ip
	if(ismob(banned_mob) && banned_mob.ckey)
		ckey = banned_mob.ckey
		if(banned_mob.client)
			computerid = banned_mob.client.computer_id
			ip = banned_mob.client.address
		else
			ip = banned_mob.lastKnownIP
			computerid = banned_mob.computer_id
	else if(banckey)
		ckey = ckey(banckey)
		computerid = bancid
		ip = banip
	else
		var/detail = ismob(banned_mob) ? "ckey-less mob" : "non-existent mob"
		message_admins(span_red("SyndiCat attempted to add a ban based on a [detail], with no ckey provided. Report this bug."))
		return

	// Make sure the ckey exists in the player DB. Guests are exempt — they aren't tracked there.
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT id FROM [format_table_name("player")] WHERE ckey=:ckey", list("ckey" = ckey))
	if(!query.warn_execute())
		qdel(query)
		return
	var/validckey = query.NextRow()
	qdel(query)
	if(!validckey && (!banned_mob || !is_guest_key(banned_mob.key)))
		message_admins(span_red("SyndiCat attempted to ban [ckey], but [ckey] does not exist in the player database. Please only ban actual players."))
		return

	var/list/who_list = list()
	for(var/client/connected in GLOB.clients)
		who_list += "[connected]"
	var/list/adminwho_list = list()
	for(var/client/admin_client in GLOB.admins)
		adminwho_list += "[admin_client]"

	// SQL driver expects string-typed numbers, hence `"[... || 0]"` on duration/rounds.
	var/list/ban_row = list(
		"serverip" = "[world.internet_address]:[world.port]",
		"bantype_str" = bantype_str,
		"reason" = reason,
		"job" = job,
		"duration" = "[duration || 0]",
		"rounds" = "[rounds || 0]",
		"ckey" = ckey,
		"computerid" = computerid,
		"ip" = ip,
		"a_ckey" = "SyndiCat",
		"a_computerid" = "4221007721",
		"a_ip" = "127.0.0.1",
		"who" = jointext(who_list, ", "),
		"adminwho" = jointext(adminwho_list, ", "),
		"server_id" = CONFIG_GET(string/instance_id),
	)

	var/datum/db_query/query_insert = SSdbcore.NewQuery({"
		INSERT INTO [CONFIG_GET(string/utility_database)].[format_table_name("ban")] (
			`id`, `bantime`, `serverip`, `bantype`, `reason`, `job`,
			`duration`, `rounds`, `expiration_time`,
			`ckey`, `computerid`, `ip`,
			`a_ckey`, `a_computerid`, `a_ip`,
			`who`, `adminwho`, `edits`,
			`unbanned`, `unbanned_datetime`, `unbanned_ckey`, `unbanned_computerid`, `unbanned_ip`,
			`server_id`
		) VALUES (
			null, Now(), :serverip, :bantype_str, :reason, :job,
			:duration, :rounds, Now() + INTERVAL :duration MINUTE,
			:ckey, :computerid, :ip,
			:a_ckey, :a_computerid, :a_ip,
			:who, :adminwho, '',
			null, null, null, null, null,
			:server_id
		)
	"}, ban_row)
	if(!query_insert.warn_execute())
		qdel(query_insert)
		return
	qdel(query_insert)

	message_admins("SyndiCat has added a [bantype_str] for [ckey] [job ? "([job])" : ""] [duration > 0 ? "([duration] minutes)" : ""] with the reason: \"[reason]\" to the ban database.")

	if(meta["announce"])
		SSdiscord.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "**BAN ALERT** SyndiCat applied a [bantype_str] on [ckey]")

	if(meta["kick"] && banned_mob?.client && banned_mob.client.ckey == ckey)
		qdel(banned_mob.client)

	if(meta["jobban"])
		jobban_client_fullban(ckey, job)
	else
		flag_account_for_forum_sync(ckey)

/**
 * Checks whether the given ckey is present in the `vpn_whitelist` table of the utility DB.
 *
 * Used by [/datum/geoip_data/proc/on_geoip_response] so that players with a whitelisted
 * VPN/proxy are not autobanned. Returns FALSE if the DB is unavailable or no row matches.
 *
 * Arguments:
 * * target_ckey - the player's ckey to check (normalised via `ckey()`).
 */
/proc/proxy_whitelist_check(target_ckey)
	var/target_sql_ckey = ckey(target_ckey)
	var/datum/db_query/query = SSdbcore.NewQuery("SELECT * FROM [CONFIG_GET(string/utility_database)].[format_table_name("vpn_whitelist")] WHERE ckey=:ckey", list("ckey" = target_sql_ckey))
	if(!query.warn_execute())
		qdel(query)
		return FALSE
	if(query.NextRow())
		qdel(query)
		return TRUE // At least one row in the whitelist names their ckey. That means they are whitelisted.
	qdel(query)
	return FALSE
