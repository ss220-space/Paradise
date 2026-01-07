/// Verb for opening the requests manager panel
ADMIN_VERB(requests, R_ADMIN, "Requests Manager", "Open the request manager panel to view all requests during this round.", ADMIN_CATEGORY_GAME)
	GLOB.requests.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Request Manager")
