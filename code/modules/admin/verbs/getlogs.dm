ADMIN_VERB(get_server_logs, R_ADMIN|R_DEBUG, "Get Server Logs", "View or retrieve logfiles.", ADMIN_CATEGORY_MAIN)
	user.browseserverlogs()

ADMIN_VERB(get_current_logs, R_ADMIN|R_DEBUG, "Get Current Logs", "View or retrieve logfiles for the current round.", ADMIN_CATEGORY_MAIN)
	user.browseserverlogs(current = TRUE)

/// This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/browseserverlogs(current = FALSE)
	var/path = browse_files(current ? BROWSE_ROOT_CURRENT_LOGS : BROWSE_ROOT_ALL_LOGS)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins(span_adminnotice("[key_name_admin(src)] accessed file: [path]"))
	log_admin("[key_name(src)] accessed file: [path]")
	switch(tgui_alert(usr, "View (in game), Open (in your system's text editor), or Download?", path, list("View", "Open", "Download")))
		if("View")
			var/datum/browser/popup = new(src, "viewfile.[path]", "Server Logs")
			popup.set_content("<pre style='word-wrap: break-word;'>[html_encode(WRAP_FILE2TEXT(WRAP_FILE(path)))]</pre>")
			popup.open(FALSE)
		if("Open")
			src << run(WRAP_FILE(path))
		if("Download")
			src << ftp(WRAP_FILE(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.", confidential = TRUE)
