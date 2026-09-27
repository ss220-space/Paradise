/datum/unit_test/ntnet_responses
	var/list/saved_state

/datum/unit_test/ntnet_responses/Destroy()
	for(var/var_name in saved_state)
		SSntnet.vars[var_name] = saved_state[var_name]
	saved_state = null
	return ..()

/datum/unit_test/ntnet_responses/Run()
	var/datum/controller/subsystem/ntnet/network = SSntnet
	saved_state = list()
	for(var/var_name in list("sites", "catalog", "zones", "pages", "page_retry", "pending", "available", "index_pending", "next_refresh"))
		saved_state[var_name] = network.vars[var_name]
	network.sites = list()
	network.catalog = list()
	network.pages = list()
	network.page_retry = list()
	network.pending = list()
	var/datum/http_response/response = allocate(/datum/http_response)
	response.status_code = 200
	var/list/site = list("id" = "test", "domain" = "test.ss13", "title" = "Test", "version" = "1", "pages" = list(list("slug" = "index", "title" = "Index")))
	response.body = json_encode(list("sites" = list(site), "zones" = list("ss13", "dp")))
	network.on_index(response)
	TEST_ASSERT(network.available, "Valid catalog was rejected")
	TEST_ASSERT_EQUAL(length(network.zones), 2, "Zone list was not cached")
	response.body = json_encode(list("sites" = list(site), "zones" = list(42)))
	network.on_index(response)
	TEST_ASSERT_NOT(network.available, "Malformed zone list was accepted")
	response.body = json_encode(list("sites" = list(site), "zones" = list("ss13", "dp")))
	network.on_index(response)
	TEST_ASSERT(network.has_page("test", "index"), "Catalog page is missing")
	TEST_ASSERT_NOT(network.has_page("test", "../secret"), "Unlisted page was accepted")
	TEST_ASSERT_NOT(network.has_page(list("test"), "index"), "Malformed site ID was accepted")
	var/cache_key = json_encode(list("test", "index"))
	response.body = json_encode(list("site_id" = "test", "slug" = "index", "version" = "1", "tree" = list("type" = "text", "text" = "hello")))
	network.on_page("test", "index", response)
	TEST_ASSERT(network.pages[cache_key], "Valid page was not cached")
	var/list/cached_page = network.pages[cache_key]
	TEST_ASSERT_NULL(cached_page["interactive"], "Missing interactive field was invented")
	var/address = "https://sandbox.wiki-ss13.space/i/0123456789abcdef0123456789abcdef/index"
	TEST_ASSERT(network.interactive_address(address), "Sandbox address was rejected")
	var/list/document = list("site_id" = "test", "slug" = "index", "version" = "1")
	document["tree"] = list("type" = "text", "text" = "hello")
	document["interactive"] = list("url" = address, "version" = 1)
	response.body = json_encode(document)
	network.on_page("test", "index", response)
	cached_page = network.pages[cache_key]
	var/list/kept = cached_page["interactive"]
	TEST_ASSERT_EQUAL(kept["url"], address, "Interactive address was not kept")
	document["interactive"] = list("url" = "https://evil.example/steal")
	response.body = json_encode(document)
	network.on_page("test", "index", response)
	cached_page = network.pages[cache_key]
	TEST_ASSERT_NULL(cached_page["interactive"], "Foreign interactive address was accepted")
	var/deep_tree = "{\"type\":\"text\",\"text\":\"deep\"}"
	for(var/level in 1 to 16)
		deep_tree = "{\"type\":\"div\",\"children\":\[[deep_tree]\]}"
	response.body = json_encode(list("site_id" = "test", "slug" = "index", "version" = "1", "tree" = deep_tree))
	network.on_page("test", "index", response)
	cached_page = network.pages[cache_key]
	TEST_ASSERT_EQUAL(cached_page["tree"], deep_tree, "Deep page tree was not kept as text")
	var/list/ui_payload = list("data" = list("ntnet" = list("page" = cached_page)))
	TEST_ASSERT_NOT(findtext(json_encode(ui_payload), "null"), "Deep page tree broke the UI payload")
	TEST_ASSERT(network.media_address("https://media.wiki-ss13.space/0123456789abcdef0123456789abcdef/0123456789abcdef.png"), "Media address was rejected")
	TEST_ASSERT_NOT(network.media_address("https://media.wiki-ss13.space/0123456789abcdef0123456789abcdef/0123456789abcdef.svg"), "Svg icon was accepted")
	TEST_ASSERT_NOT(network.media_address("javascript:alert(1)"), "Junk icon was accepted")
	var/list/bad_addresses = list("byond://?src=admin", "javascript:alert(1)")
	bad_addresses += "http://sandbox.wiki-ss13.space/i/0123456789abcdef0123456789abcdef/index"
	bad_addresses += "https://sandbox.wiki-ss13.space/i/0123456789abcdef0123456789abcdef/index?x=1"
	bad_addresses += "https://sandbox.wiki-ss13.space/i/short/index"
	bad_addresses += "https://sandbox.wiki-ss13.space/other/path"
	for(var/bad_address in bad_addresses)
		TEST_ASSERT_NOT(network.interactive_address(bad_address), "Bad interactive address was accepted: [bad_address]")
	response.errored = TRUE
	network.on_index(response)
	TEST_ASSERT_NOT(network.available, "Network failure was not reported")
	TEST_ASSERT(network.has_page("test", "index"), "Network failure discarded catalog")
	TEST_ASSERT(network.pages[cache_key], "Network failure discarded cached page")
	response.errored = FALSE
	response.body = "invalid json"
	network.on_index(response)
	TEST_ASSERT(network.has_page("test", "index"), "Malformed JSON discarded catalog")
	response.body = json_encode(list("sites" = list(42)))
	network.on_index(response)
	TEST_ASSERT(network.has_page("test", "index"), "Malformed entry discarded catalog")
	site["version"] = "2"
	response.body = json_encode(list("sites" = list(site)))
	network.on_index(response)
	TEST_ASSERT_NULL(network.pages[cache_key], "Updated site retained stale page")
	response.body = json_encode(list("site_id" = "test", "slug" = "index", "version" = "1", "tree" = list()))
	network.on_page("test", "index", response)
	TEST_ASSERT_NULL(network.pages[cache_key], "Late response restored stale page")
	TEST_ASSERT_NOT(network.page_failed("test", "index"), "Stale response blocked an immediate retry")
	response.body = json_encode(list("site_id" = "test", "slug" = "index", "version" = "junk", "tree" = list()))
	network.on_page("test", "index", response)
	TEST_ASSERT(network.page_failed("test", "index"), "Junk version was not treated as a broken response")
	network.page_retry.Cut()
	network.next_refresh = INFINITY
	response.body = json_encode(list("site_id" = "test", "slug" = "index", "version" = "3", "tree" = list()))
	network.on_page("test", "index", response)
	TEST_ASSERT(network.pages[cache_key], "Page saved after the catalog refresh was rejected")
	TEST_ASSERT_EQUAL(network.next_refresh, 0, "Newer page did not schedule a catalog refresh")
	network.pages -= cache_key
	response.status_code = 404
	network.on_page("test", "index", response)
	TEST_ASSERT(network.available, "Missing page took the whole network offline")
	TEST_ASSERT(network.page_failed("test", "index"), "Missing page was not reported as failed")
	response.status_code = 200
	network.page_retry.Cut()
	network.pending[json_encode(list("stuck", "index"))] = world.time - 1
	network.request_page("test", "index")
	TEST_ASSERT_NULL(network.pending[json_encode(list("stuck", "index"))], "Lost request kept its slot forever")
	response.body = json_encode(list("sites" = list()))
	network.on_index(response)
	TEST_ASSERT_NOT(network.has_page("test", "index"), "Removed site remains accessible")

/datum/unit_test/ntnet_login_response/Run()
	var/datum/http_response/response = allocate(/datum/http_response)
	response.status_code = 201
	response.body = json_encode(list("code" = "ABCD-EFGH-JKLM", "expires_in" = 900))
	TEST_ASSERT_EQUAL(parse_ntnet_login_response(response), "ABCD-EFGH-JKLM", "Valid code rejected")
	response.status_code = 429
	TEST_ASSERT_NULL(parse_ntnet_login_response(response), "Rate-limited response accepted")
	response.status_code = 201
	response.errored = TRUE
	TEST_ASSERT_NULL(parse_ntnet_login_response(response), "Failed request accepted")
	response.errored = FALSE
	for(var/bad_body in list("not json", "null", "42", json_encode(list("code" = "ABCD-EFGH-JKLM", "expires_in" = 3600)), json_encode(list("code" = "<script>alert(1)</script>", "expires_in" = 900)), json_encode(list("code" = list("ABCD-EFGH-JKLM"), "expires_in" = 900))))
		response.body = bad_body
		TEST_ASSERT_NULL(parse_ntnet_login_response(response), "Malformed login response accepted")

/datum/unit_test/ntnet_viewer_token/Run()
	var/datum/http_response/response = allocate(/datum/http_response)
	response.status_code = 201
	response.body = json_encode(list("token" = "eyJzIjoiYSJ9.c2lnbmF0dXJl_-", "expires_in" = 3600))
	TEST_ASSERT_EQUAL(parse_ntnet_viewer_token(response), "eyJzIjoiYSJ9.c2lnbmF0dXJl_-", "Valid viewer token rejected")
	response.status_code = 404
	TEST_ASSERT_NULL(parse_ntnet_viewer_token(response), "Refused viewer token accepted")
	response.status_code = 201
	for(var/bad_body in list("not json", json_encode(list("token" = "abc.def", "expires_in" = 900)), json_encode(list("token" = "abc.def.ghi", "expires_in" = 3600)), json_encode(list("token" = "abc'.def", "expires_in" = 3600)), json_encode(list("token" = list("abc.def"), "expires_in" = 3600))))
		response.body = bad_body
		TEST_ASSERT_NULL(parse_ntnet_viewer_token(response), "Malformed viewer token accepted")

/datum/unit_test/ntnet_opt_in
	var/saved_enabled
	var/saved_url
	var/saved_key

/datum/unit_test/ntnet_opt_in/Destroy()
	CONFIG_SET(flag/ntnet_enabled, saved_enabled)
	CONFIG_SET(string/ntnet_api_url, saved_url)
	CONFIG_SET(string/ntnet_server_key, saved_key)
	return ..()

/datum/unit_test/ntnet_opt_in/Run()
	saved_enabled = CONFIG_GET(flag/ntnet_enabled)
	saved_url = CONFIG_GET(string/ntnet_api_url)
	saved_key = CONFIG_GET(string/ntnet_server_key)
	CONFIG_SET(flag/ntnet_enabled, FALSE)
	var/obj/item/pda/disabled = allocate(/obj/item/pda)
	TEST_ASSERT_NULL(disabled.find_program(/datum/data/pda/app/ntnet), "Disabled app installed")
	CONFIG_SET(flag/ntnet_enabled, TRUE)
	CONFIG_SET(string/ntnet_api_url, "http://127.0.0.1:8091")
	CONFIG_SET(string/ntnet_server_key, "")
	var/obj/item/pda/unconfigured = allocate(/obj/item/pda)
	TEST_ASSERT_NULL(unconfigured.find_program(/datum/data/pda/app/ntnet), "App installed without a server key")
	CONFIG_SET(string/ntnet_server_key, "unit-test-key")
	var/obj/item/pda/enabled = allocate(/obj/item/pda)
	TEST_ASSERT_NOTNULL(enabled.find_program(/datum/data/pda/app/ntnet), "Enabled app was not installed")
