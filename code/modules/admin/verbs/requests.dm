/// Verb for opening the requests manager panel
/client/proc/requests()
	set name = "Requests Manager"
	set desc = "Open the request manager panel to view all requests during this round"
	set category = ADMIN_CATEGORY_TICKETS
	GLOB.requests.ui_interact(usr)
	BLACKBOX_LOG_ADMIN_VERB("Request Manager")
