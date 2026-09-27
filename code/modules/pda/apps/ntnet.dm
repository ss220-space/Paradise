#define NTNET_SEARCH_TIMEOUT (20 SECONDS)
#define NTNET_SEARCH_MAX_QUERY_LENGTH 80
#define NTNET_SEARCH_MAX_RESULTS 20
#define NTNET_SEARCH_MAX_BODY (64 * 1024)
#define NTNET_SEARCH_MAX_SNIPPET 400

/datum/data/pda/app/ntnet
	name = "NTnet"
	icon = "globe"
	template = "pda_ntnet"
	fullscreen = TRUE
	window_width = 1000
	window_height = 820
	var/site_id
	var/slug
	var/search_query
	var/list/search_results = list()
	var/search_pending = FALSE
	var/search_error
	var/search_request = 0
	var/search_generation = 0

/datum/data/pda/app/ntnet/start()
	if(!SSntnet.is_enabled())
		return FALSE
	return ..()

/datum/data/pda/app/ntnet/update_ui(mob/user, list/data)
	SSntnet.last_used = world.time
	SSntnet.refresh_index()
	if(length(search_results) && search_generation != SSntnet.generation)
		search_generation = SSntnet.generation
		for(var/list/entry as anything in search_results.Copy())
			if(!SSntnet.has_page(entry["site_id"], entry["slug"]))
				search_results -= list(entry)
	var/list/site = SSntnet.sites[site_id]
	if(site_id && !SSntnet.has_page(site_id, slug))
		site_id = null
		slug = null
		site = null
	has_back = !isnull(site_id)
	data["app"]["has_back"] = has_back
	var/cache_key = json_encode(list(site_id, slug))
	if(site_id)
		SSntnet.request_page(site_id, slug)
	data["ntnet"] = list(
		"available" = SSntnet.available,
		"loading" = site_id ? !SSntnet.pages[cache_key] && !SSntnet.page_failed(site_id, slug) : world.time < SSntnet.index_pending,
		"failed" = site_id && SSntnet.page_failed(site_id, slug),
		"catalog" = SSntnet.catalog,
		"zones" = SSntnet.zones,
		"site" = site,
		"page" = SSntnet.pages[cache_key],
		"slug" = slug,
	)
	data["ntnet"]["search"] = list(
		"query" = search_query,
		"results" = search_results,
		"pending" = search_pending,
		"error" = search_error,
	)
	data["ntnet"]["theme"] = user.client?.ntnet_light_theme ? "light" : "dark"
	var/client/viewer = user.client
	data["ntnet"]["login"] = list(
		"code" = viewer && viewer.ntnet_code_expires > world.time ? viewer.ntnet_code : null,
		"pending" = viewer?.ntnet_login_pending,
		"retry_seconds" = viewer ? max(0, ceil((viewer.ntnet_login_retry - world.time) / (1 SECONDS))) : 0,
		"error" = viewer?.ntnet_login_error,
	)
	var/list/viewer_entry = site_id && viewer ? viewer.ntnet_viewer_tokens[site_id] : null
	data["ntnet"]["viewer"] = list(
		"token" = site_id ? SSntnet.viewer_token(viewer, site_id) : null,
		"error" = LAZYACCESS(viewer_entry, "error"),
	)

/datum/data/pda/app/ntnet/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!SSntnet.is_enabled())
		return
	switch(action)
		if("ntnet_login")
			SSntnet.request_login(ui.user.client)
		if("ntnet_open")
			if(!SSntnet.has_page(params["site_id"], params["slug"]))
				return
			site_id = params["site_id"]
			slug = params["slug"]
			SSntnet.request_page(site_id, slug)
		if("ntnet_token")
			SSntnet.request_viewer_token(ui.user.client, site_id, ui.user.real_name, !!params["renew"])
		if("ntnet_refresh")
			SSntnet.force_refresh(site_id, slug)
		if("ntnet_theme")
			var/client/viewer = ui.user.client
			if(viewer)
				viewer.ntnet_light_theme = !viewer.ntnet_light_theme
		if("ntnet_search")
			search(params["query"])
		if("Back")
			site_id = null
			slug = null
		else
			return FALSE
	return TRUE

/datum/data/pda/app/ntnet/proc/search(raw_query)
	if(!istext(raw_query) || search_pending || !SSntnet.is_enabled())
		return
	var/query = trim(raw_query)
	if(length_char(query) < 2 || length_char(query) > NTNET_SEARCH_MAX_QUERY_LENGTH)
		search_error = "Введите от 2 до [NTNET_SEARCH_MAX_QUERY_LENGTH] символов."
		return
	search_query = query
	search_results = list()
	search_error = null
	search_pending = TRUE
	search_request++
	var/request_id = search_request
	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/ntnet_api_url)]/api/v1/search?q=[url_encode(query)]", headers = list("X-Server-Key" = CONFIG_GET(string/ntnet_server_key)), proc_callback = CALLBACK(src, PROC_REF(on_search), request_id), sensitive = TRUE)
	addtimer(CALLBACK(src, PROC_REF(search_timeout), request_id), NTNET_SEARCH_TIMEOUT)

/datum/data/pda/app/ntnet/proc/search_timeout(request_id)
	if(!search_pending || search_request != request_id)
		return
	search_pending = FALSE
	search_error = "Поиск не ответил. Попробуйте ещё раз."
	if(!QDELETED(pda))
		SStgui.update_uis(pda)

/datum/data/pda/app/ntnet/proc/on_search(request_id, datum/http_response/response)
	if(!search_pending || search_request != request_id)
		return
	search_pending = FALSE
	search_error = "Не удалось выполнить поиск."
	if(response.errored || response.status_code != 200 || !istext(response.body) || length(response.body) > NTNET_SEARCH_MAX_BODY)
		if(!QDELETED(pda))
			SStgui.update_uis(pda)
		return
	var/list/document = safe_json_decode(response.body)
	if(!islist(document))
		if(!QDELETED(pda))
			SStgui.update_uis(pda)
		return
	var/list/found = document["results"]
	if(!islist(found) || length(found) > NTNET_SEARCH_MAX_RESULTS)
		if(!QDELETED(pda))
			SStgui.update_uis(pda)
		return
	var/list/results = list()
	for(var/list/entry as anything in found)
		if(!islist(entry) || !istext(entry["site_id"]) || !istext(entry["slug"]) || !istext(entry["title"]) || !istext(entry["snippet"]))
			continue
		if(length(entry["snippet"]) > NTNET_SEARCH_MAX_SNIPPET || !SSntnet.has_page(entry["site_id"], entry["slug"]))
			continue
		results += list(entry)
	search_results = results
	search_generation = SSntnet.generation
	search_error = null
	if(!QDELETED(pda))
		SStgui.update_uis(pda)

#undef NTNET_SEARCH_TIMEOUT
#undef NTNET_SEARCH_MAX_QUERY_LENGTH
#undef NTNET_SEARCH_MAX_RESULTS
#undef NTNET_SEARCH_MAX_BODY
#undef NTNET_SEARCH_MAX_SNIPPET
