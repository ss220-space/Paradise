#define NTNET_REFRESH_INTERVAL (5 MINUTES)
#define NTNET_RETRY_INTERVAL (30 SECONDS)
#define NTNET_IDLE_TIMEOUT (15 MINUTES)
#define NTNET_REQUEST_TIMEOUT (30 SECONDS)
#define NTNET_MAX_INDEX_BYTES (512 * 1024)
#define NTNET_MAX_PAGE_BYTES (96 * 1024)
#define NTNET_MAX_SITES 500
#define NTNET_MAX_ZONES 32
#define NTNET_MAX_ZONE_LENGTH 24
#define NTNET_MAX_PAGES 20
#define NTNET_CACHE_PAGES 32
#define NTNET_MAX_REQUESTS 4
#define NTNET_MAX_INTERACTIVE_URL 200
#define NTNET_MAX_ID_LENGTH 64

SUBSYSTEM_DEF(ntnet)
	name = "NTnet"
	wait = NTNET_REFRESH_INTERVAL
	ss_flags = SS_NO_INIT | SS_BACKGROUND
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	var/list/sites = list()
	var/list/catalog = list()
	var/list/zones = list()
	var/list/pages = list()
	var/list/page_retry = list()
	var/list/pending = list()
	var/available = FALSE
	var/index_pending = 0
	var/next_refresh = 0
	var/last_used = -INFINITY
	var/generation = 0

/datum/controller/subsystem/ntnet/fire(resumed = FALSE)
	if(world.time > last_used + NTNET_IDLE_TIMEOUT)
		return
	refresh_index()

/datum/controller/subsystem/ntnet/proc/is_enabled()
	return CONFIG_GET(flag/ntnet_enabled) && CONFIG_GET(string/ntnet_api_url) && CONFIG_GET(string/ntnet_server_key)

/datum/controller/subsystem/ntnet/proc/refresh_index()
	if(!is_enabled() || world.time < index_pending || world.time < next_refresh)
		return
	index_pending = world.time + NTNET_REQUEST_TIMEOUT
	next_refresh = world.time + NTNET_REFRESH_INTERVAL
	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/ntnet_api_url)]/api/v1/catalog", headers = list("X-Server-Key" = CONFIG_GET(string/ntnet_server_key)), proc_callback = CALLBACK(src, PROC_REF(on_index)), sensitive = TRUE)

/datum/controller/subsystem/ntnet/proc/on_index(datum/http_response/response)
	index_pending = 0
	available = FALSE
	next_refresh = world.time + NTNET_RETRY_INTERVAL
	if(response.errored || response.status_code != 200 || !istext(response.body) || length(response.body) > NTNET_MAX_INDEX_BYTES)
		return
	var/list/document = safe_json_decode(response.body)
	if(!islist(document) || !islist(document["sites"]))
		return
	var/list/entries = document["sites"]
	if(length(entries) > NTNET_MAX_SITES)
		return
	var/list/zone_names = document["zones"]
	var/list/new_zones = list()
	if(islist(zone_names))
		if(length(zone_names) > NTNET_MAX_ZONES)
			return
		for(var/zone in zone_names)
			if(!istext(zone) || !length(zone) || length(zone) > NTNET_MAX_ZONE_LENGTH)
				return
			new_zones += zone
	var/list/new_sites = list()
	for(var/list/site as anything in entries)
		if(!islist(site) || !istext(site["id"]) || !length(site["id"]) || length(site["id"]) > NTNET_MAX_ID_LENGTH || !istext(site["domain"]) || !istext(site["title"]) || !istext(site["version"]) || !islist(site["pages"]))
			return
		var/site_id = site["id"]
		var/list/site_pages = site["pages"]
		if(new_sites[site_id] || !length(site_pages) || length(site_pages) > NTNET_MAX_PAGES)
			return
		var/list/slugs = list()
		for(var/list/page as anything in site_pages)
			if(!islist(page) || !istext(page["slug"]) || !length(page["slug"]) || length(page["slug"]) > NTNET_MAX_ID_LENGTH || !istext(page["title"]) || (page["slug"] in slugs))
				return
			slugs += page["slug"]
		if(!isnull(site["icon"]) && !media_address(site["icon"]))
			site -= "icon"
		new_sites[site_id] = site
	sites = new_sites
	catalog = entries
	zones = new_zones
	for(var/cache_key in pages.Copy())
		var/list/cached = pages[cache_key]
		var/list/site = sites[cached["site_id"]]
		if(!site || site["version"] != cached["version"])
			pages -= cache_key
	page_retry.Cut()
	generation++
	next_refresh = world.time + NTNET_REFRESH_INTERVAL
	available = TRUE

/datum/controller/subsystem/ntnet/proc/force_refresh(site_id, slug)
	next_refresh = 0
	refresh_index()
	if(!site_id)
		return
	var/cache_key = json_encode(list(site_id, slug))
	pages -= cache_key
	page_retry -= cache_key
	request_page(site_id, slug)

/datum/controller/subsystem/ntnet/proc/has_page(site_id, slug)
	if(!istext(site_id) || !istext(slug))
		return FALSE
	var/list/site = sites[site_id]
	if(!site)
		return FALSE
	for(var/list/page as anything in site["pages"])
		if(page["slug"] == slug)
			return TRUE
	return FALSE

/datum/controller/subsystem/ntnet/proc/request_page(site_id, slug)
	for(var/pending_key in pending.Copy())
		if(world.time > pending[pending_key])
			pending -= pending_key
	if(!is_enabled() || !has_page(site_id, slug))
		return
	var/cache_key = json_encode(list(site_id, slug))
	if(pages[cache_key] || pending[cache_key] || length(pending) >= NTNET_MAX_REQUESTS || world.time < page_retry[cache_key])
		return
	pending[cache_key] = world.time + NTNET_REQUEST_TIMEOUT
	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/ntnet_api_url)]/api/v1/sites/[url_encode(site_id)]/pages/[url_encode(slug)]?tree=text", headers = list("X-Server-Key" = CONFIG_GET(string/ntnet_server_key)), proc_callback = CALLBACK(src, PROC_REF(on_page), site_id, slug), sensitive = TRUE)

/datum/controller/subsystem/ntnet/proc/page_failed(site_id, slug)
	var/cache_key = json_encode(list(site_id, slug))
	return !pages[cache_key] && world.time < page_retry[cache_key]

/datum/controller/subsystem/ntnet/proc/on_page(site_id, slug, datum/http_response/response)
	var/cache_key = json_encode(list(site_id, slug))
	pending -= cache_key
	if(response.errored || response.status_code >= 500)
		available = FALSE
		page_retry[cache_key] = world.time + NTNET_RETRY_INTERVAL
		return
	available = TRUE
	if(response.status_code == 404)
		next_refresh = min(next_refresh, world.time + NTNET_RETRY_INTERVAL)
	if(response.status_code != 200 || !istext(response.body) || length(response.body) > NTNET_MAX_PAGE_BYTES)
		page_retry[cache_key] = world.time + NTNET_RETRY_INTERVAL
		return
	if(!has_page(site_id, slug))
		return
	var/list/site = sites[site_id]
	var/list/document = safe_json_decode(response.body)
	var/document_version = islist(document) && istext(document["version"]) ? text2num(document["version"]) : null
	if(!islist(document) || document["site_id"] != site_id || document["slug"] != slug || !isnum(document_version) || !(istext(document["tree"]) || islist(document["tree"])))
		page_retry[cache_key] = world.time + NTNET_RETRY_INTERVAL
		return
	var/catalog_version = text2num(site["version"])
	if(document_version < catalog_version)
		return
	if(document_version > catalog_version)
		next_refresh = 0
	var/list/interactive = document["interactive"]
	document -= "interactive"
	if(CONFIG_GET(flag/ntnet_interactive) && islist(interactive))
		var/address = interactive["url"]
		if(istext(address) && length(address) <= NTNET_MAX_INTERACTIVE_URL && interactive_address(address))
			document["interactive"] = list("url" = address)
	if(length(pages) >= NTNET_CACHE_PAGES)
		pages.Cut(1, 2)
	pages[cache_key] = document
	page_retry -= cache_key

/datum/controller/subsystem/ntnet/proc/media_address(address)
	var/static/regex/media = regex(@"^https://[a-z0-9.-]{4,64}/[a-f0-9]{32}/[a-f0-9]{16}\.(?:png|jpg|gif|webp)$")
	return istext(address) && length(address) <= NTNET_MAX_INTERACTIVE_URL && media.Find(address)

/datum/controller/subsystem/ntnet/proc/interactive_address(address)
	var/static/regex/sandbox = regex(@"^https://[a-z0-9.-]{4,64}/i/[a-f0-9]{32}/[a-z0-9][a-z0-9-]{0,62}$")
	return sandbox.Find(address)

#undef NTNET_MAX_INTERACTIVE_URL
#undef NTNET_MAX_ID_LENGTH
#undef NTNET_REFRESH_INTERVAL
#undef NTNET_RETRY_INTERVAL
#undef NTNET_IDLE_TIMEOUT
#undef NTNET_REQUEST_TIMEOUT
#undef NTNET_MAX_INDEX_BYTES
#undef NTNET_MAX_PAGE_BYTES
#undef NTNET_MAX_SITES
#undef NTNET_MAX_ZONES
#undef NTNET_MAX_ZONE_LENGTH
#undef NTNET_MAX_PAGES
#undef NTNET_CACHE_PAGES
#undef NTNET_MAX_REQUESTS
