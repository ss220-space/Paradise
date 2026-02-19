/atom/proc/investigate_log(message, subject)
	if(!message)
		return

	if(!subject)
		CRASH("No subject provided for investigate_log")

	var/file = wrap_file("[GLOB.log_directory]/[subject].html")
	var/source = "[src]"
	if(isliving(src))
		var/mob/living/source_mob = src
		source += " ([source_mob.ckey ? source_mob.ckey : "*no key*"])"

	WRITE_FILE(file, "[time_stamp()] [UID()] ([x],[y],[z]) || [source] [message]<br>")

ADMIN_VERB(investigate_show, R_ADMIN, "Investigate", "Browse various detailed logs.", ADMIN_CATEGORY_GAME)
	var/list/investigates = list(
		INVESTIGATE_ACCESSCHANGES,
		INVESTIGATE_ATMOS,
		INVESTIGATE_BOMB,
		INVESTIGATE_BOTANY,
		INVESTIGATE_CARGO,
		INVESTIGATE_CRAFTING,
		INVESTIGATE_ENGINE,
		INVESTIGATE_EXPERIMENTOR,
		INVESTIGATE_GRAVITY,
		INVESTIGATE_HALLUCINATIONS,
		INVESTIGATE_TELEPORTATION,
		INVESTIGATE_RECORDS,
		INVESTIGATE_RENAME,
		INVESTIGATE_RESEARCH,
		INVESTIGATE_SYNDIE_CARGO,
		INVESTIGATE_WIRES,
	)

	var/list/logs_present = list("notes", "watchlist", "hrefs")
	var/list/logs_missing = list("---")

	for(var/subject in investigates)
		var/temp_file = file("[GLOB.log_directory]/[subject].html")
		if(fexists(temp_file))
			logs_present += subject
		else
			logs_missing += "[subject] (empty)"

	var/list/combined = sortList(logs_present) + sortList(logs_missing)

	var/selected = tgui_input_list(user, "Investigate what?", "Investigate", combined)

	if(!(selected in combined) || selected == "---")
		return

	selected = replacetext(selected, " (empty)", "")

	switch(selected)
		if("notes")
			show_note()

		if("watchlist")
			user.watchlist_show()

		if("hrefs") //persistant logs and stuff
			if(config && CONFIG_GET(flag/log_hrefs))
				if(GLOB.world_href_log)
					var/datum/browser/popup = new(user, "investigate[selected]", capitalize("investigate[selected]"), 800, 300)
					popup.set_content(wrap_file(GLOB.world_href_log))
					popup.open(FALSE)
				else
					to_chat(user, span_red("Error: admin_investigate: No href logfile found."))
					return
			else
				to_chat(user, span_red("Error: admin_investigate: Href Logging is not on."))
				return

		else //general one-round-only stuff
			var/file = file("[GLOB.log_directory]/[selected].html")
			if(!fexists(file))
				to_chat(user, span_danger("No [selected] logfile was found."), confidential = TRUE)
				return

			file = wrap_file2text(file)
			var/datum/browser/popup = new(user, "investigate[selected]", capitalize("investigate[selected]"), 800, 300)
			popup.set_content(file)
			popup.open(FALSE)
