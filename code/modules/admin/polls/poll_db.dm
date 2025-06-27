/**
 * Processes topic data from poll management panel.
 *
 * Reads through returned form data and assigns data to the poll datum, creating a new one if required, before passing it to be saved.
 * Also does some simple error checking to ensure the poll will be valid before creation.
 *
 */
/client/proc/poll_parse(datum/ui_module/poll_management_panel/our_panel, datum/poll_question/poll)
	var/list_poll = our_panel.list_poll
	if(!check_rights(R_SERVER))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/list/error_state = list()
	var/new_poll = FALSE // submit_ready
	var/clear_votes = FALSE
	var/submit_ready = FALSE
	if(!poll)
		poll = new(creator = usr.client.ckey)
		new_poll = TRUE
	if(new_poll)
		poll.poll_type = list_poll["poll_type"]
	if(list_poll["run_duration"])
		poll.duration = text2num(list_poll["duration"])
		poll.interval = list_poll["interval"]
	else
		if(list_poll["end_datetime"] != "YYYY-MM-DD HH:MM:SS")
			poll.duration = list_poll["end_datetime"]
			if(new_poll)
				poll.end_datetime = poll.duration
	if(!poll.duration)
		error_state += "No duration was provided or it was incorrectly typed(Check: YYYY-MM-DD HH:MM:SS)."
	if(list_poll["run_start"])
		poll.start_datetime = null
	else
		if(list_poll["start_datetime"] && list_poll["start_datetime"] != "YYYY-MM-DD HH:MM:SS")
			poll.start_datetime = list_poll["start_datetime"]
		else
			error_state += "Start datetime was selected but none was provided."
	if(list_poll["question"])
		poll.question = list_poll["question"]
	else
		error_state += "No question was provided."
	poll.subtitle = list_poll["subtitle"]
	if(list_poll["admin_only"])
		poll.admin_only = TRUE
	else
		poll.admin_only = FALSE
	if(list_poll["dont_show"])
		poll.dont_show = TRUE
	else
		poll.dont_show = FALSE
	if(list_poll["allow_revoting"])
		poll.allow_revoting = TRUE
	else
		poll.allow_revoting = FALSE
	if(list_poll["clear_votes"])
		clear_votes = TRUE
	if(list_poll["submitpoll"])
		submit_ready = TRUE
	if(poll.poll_type == POLLTYPE_MULTI)
		if(text2num(list_poll["options_allowed"]))
			poll.options_allowed = text2num(list_poll["options_allowed"])
			if(poll.options_allowed == null)
				error_state += "Multiple choice options allowed isn't set properly."
			if(poll.options_allowed == 1)
				error_state += "Multiple choice polls require more than one option allowed, use a standard option poll for singlular voting."
			if(poll.options_allowed < 0)
				error_state += "Multiple choice options allowed cannot be negative."
		else
			error_state += "Multiple choice poll was selected but no number of allowed options was provided."
	if(submit_ready && poll.poll_type != POLLTYPE_TEXT && !length(poll.options))
		error_state += "This poll type requires at least one option."
	if(error_state.len)
		if(poll.edit_ready)
			to_chat(usr, span_danger("Not all edits were applied because the following errors were present:\n[error_state.Join("\n")]"), confidential = TRUE)
		else
			to_chat(usr, span_danger("Poll not [new_poll ? "initialized" : "submitted"] because the following errors were present:\n[error_state.Join("\n")]"), confidential = TRUE)
			if(new_poll)
				qdel(poll)
		return
	to_chat(usr, span_notice("all clear"))
	if(submit_ready)
		var/db = poll.edit_ready //if the poll is new it will need its options inserted for the first time
		poll.save_poll_data(clear_votes)
		if(!db)
			poll.save_all_options()
	our_panel.poll = poll //set or qdel'd, no matter
	SStgui.try_update_ui(usr, our_panel)

/**
 * Processes topic data from poll option panel.
 *
 * Reads through returned form data and assigns data to the option datum, creating a new one if required, before passing it to be saved.
 * Also does some simple error checking to ensure the option will be valid before creation.
 *
 */
/client/proc/poll_option_parse(list/option_list, datum/poll_question/poll, datum/poll_option/option)
	if(!check_rights(R_SERVER))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/list/error_state = list()
	var/new_option = FALSE
	if(!option)
		option = new()
		new_option = TRUE
	if(option_list["text"])
		option.text = option_list["text"]
	else
		error_state += "No option text was provided."
	if(option_list["default_percentage_calc"])
		option.default_percentage_calc = TRUE
	else
		option.default_percentage_calc = FALSE
	if(poll.poll_type == POLLTYPE_RATING)
		var/value_in_range = text2num(option_list["min_val"])
		if(option_list["min_val"])
			if(ISINRANGE(value_in_range, -2147483647, 2147483647))
				option.min_val = value_in_range
			else
				error_state += "Minimum value out of range."
		else
			error_state += "No minimum value was provided."
		value_in_range = text2num(option_list["max_val"])
		if(option_list["max_val"])
			if(ISINRANGE(value_in_range, -2147483647, 2147483647))
				if(value_in_range < option.min_val)
					error_state += "Maximum value is less than minimum value."
				else
					option.max_val = value_in_range
			else
				error_state += "Maximum value out of range."
		else
			error_state += "No maximum value was provided."
		if(option_list["desc_min_check"])
			if(option_list["desc_min_text"])
				option.desc_min = option_list["desc_min_text"]
			else
				error_state += "Minimum value description was selected but not provided."
		else
			option.desc_min = null
		if(option_list["desc_mid_check"])
			if(option_list["desc_mid_text"])
				option.desc_mid = option_list["desc_mid_text"]
			else
				error_state += "Middle value description was selected but not provided."
		else
			option.desc_mid = null
		if(option_list["desc_max_check"])
			if(option_list["desc_max_text"])
				option.desc_max = option_list["desc_max_text"]
			else
				error_state += "Maximum value description was selected but not provided."
		else
			option.desc_max = null
	if(error_state.len)
		if(new_option)
			to_chat(usr, span_danger("Option not added because the following errors were present:\n[error_state.Join("\n")]"), confidential = TRUE)
			qdel(option)
		else
			to_chat(usr, span_danger("Not all edits were applied because the following errors were present:\n[error_state.Join("\n")]"), confidential = TRUE)
		return
	to_chat(usr, span_notice("all clear"))
	if(new_option)
		poll.options += option
		option.parent_poll = poll
	if(poll.edit_ready)
		option.save_option()

/**
 * Loads all current and future server polls and their options to store both as datums.
 *
 */
/proc/load_poll_data()
	if(!SSdbcore.Connect())
		to_chat(usr, span_danger("Failed to establish database connection."), confidential = TRUE)
		return
	var/datum/db_query/query_load_polls = SSdbcore.NewQuery("SELECT id, polltype, starttime, endtime, question, subtitle, adminonly, multiplechoiceoptions, dontshow, allow_revoting, IF(polltype = 'Text Reply', (SELECT COUNT(ckey) FROM [format_table_name("poll_textreply")] AS t WHERE t.pollid = q.id AND deleted = 0), (SELECT COUNT(DISTINCT ckey) FROM [format_table_name("poll_vote")] AS v WHERE v.pollid = q.id AND deleted = 0)), IFNULL((SELECT ckey FROM [format_table_name("player")] WHERE ckey = q.createdby_ckey), createdby_ckey), IF(starttime > NOW(), 1, 0), IF(starttime < NOW() AND endtime > NOW(), 1, 0), minimum_playtime FROM [format_table_name("poll_question")] AS q WHERE deleted = 0")
	if(!query_load_polls.Execute())
		log_and_message_admins("Poll questions failed to load! There's SQL issue ongoing, contact developers.")
		qdel(query_load_polls)
		return
	var/list/poll_ids = list()
	while(query_load_polls.NextRow())
		new /datum/poll_question(query_load_polls.item[1], query_load_polls.item[2], query_load_polls.item[3], query_load_polls.item[4], query_load_polls.item[5], query_load_polls.item[6], query_load_polls.item[7], query_load_polls.item[8], query_load_polls.item[9], query_load_polls.item[10], query_load_polls.item[11], query_load_polls.item[12], query_load_polls.item[13], query_load_polls.item[14], query_load_polls.item[15], TRUE)
		poll_ids += query_load_polls.item[1]
	qdel(query_load_polls)
	if(length(poll_ids))
		var/datum/db_query/query_load_poll_options = SSdbcore.NewQuery("SELECT id, text, minval, maxval, descmin, descmid, descmax, default_percentage_calc, pollid FROM [format_table_name("poll_option")] WHERE pollid IN ([jointext(poll_ids, ",")])")
		if(!query_load_poll_options.Execute())
			log_and_message_admins("Poll options failed to load! There's SQL issue ongoing, contact developers.")
			qdel(query_load_poll_options)
			return
		while(query_load_poll_options.NextRow())
			var/datum/poll_option/option = new(query_load_poll_options.item[1], query_load_poll_options.item[2], query_load_poll_options.item[3], query_load_poll_options.item[4], query_load_poll_options.item[5], query_load_poll_options.item[6], query_load_poll_options.item[7], query_load_poll_options.item[8])
			var/option_poll_id = text2num(query_load_poll_options.item[9])
			for(var/q in GLOB.polls)
				var/datum/poll_question/poll = q
				if(poll.poll_id == option_poll_id)
					poll.options += option
					option.parent_poll = poll
		qdel(query_load_poll_options)
