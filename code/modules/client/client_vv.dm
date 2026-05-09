/client/can_vv_get(var_name)
	var/static/list/protected_vars = list(
		"address", "chatOutput", "computer_id", "connection", "jbh", "pm_tracker", "related_accounts_cid", "related_accounts_ip", "watchlisted"
	)
	if(!check_rights(R_ADMIN, FALSE, usr) && (var_name in protected_vars))
		return FALSE
	return TRUE
