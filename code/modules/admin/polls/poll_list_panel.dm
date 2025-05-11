/*
 * Poll List Panel
 *
 * Shows a list of all current and future polls and buttons to edit or delete them or create a new poll.
 */
/datum/ui_module/poll_list_panel
	name = "Poll List Panel"

/datum/admins/proc/open_poll_list()
	set name = "Server Poll Management"
	set category = "Admin.Admin"

	if(!check_rights(R_SERVER))
		return

	var/datum/ui_module/poll_list_panel/panel_pollo = new(usr)
	panel_pollo.ui_interact(usr)


/datum/ui_module/poll_list_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/poll_list_panel/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PollListPanel", name)
		ui.open()

/datum/ui_module/poll_list_panel/ui_data(mob/user)
	. = list()
	// Polls
	var/list/polls = list()
	for(var/datum/poll_question/poll in GLOB.polls)
		var/description = ""
		if(poll.subtitle)
			description += "[poll.subtitle]\n"
		description += "[poll.future_poll ? "Starts" : "Started"] at [poll.start_datetime] | Ends at [poll.end_datetime]"
		if(poll.admin_only)
			description += " | Admin only"
		if(poll.dont_show)
			description += " | Hidden from tracking until complete"
		description += " | [poll.poll_votes] players have [poll.poll_type == POLLTYPE_TEXT ? "responded" : "voted"]"

		var/list/list_poll = list(
			"id" = poll.poll_id,
			"question" = poll.question,
			"description" = description,
		)
		polls += list(list_poll)
	.["polls"] = polls

/datum/ui_module/poll_list_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/client/ui_client = ui.user.client
	switch (action)
		if("newpoll")
			ui_client.open_poll_management()
		if("editpoll")
			var/datum/poll_question/our_poll = null
			for(var/datum/poll_question/poll_check in GLOB.polls)
				if(poll_check.poll_id == params["poll_to_edit"])
					our_poll = poll_check
					break
			if(!our_poll)
				log_runtime(EXCEPTION("Couldn't find poll to edit with id [params["poll_to_edit"]]"))
				return
			ui_client.open_poll_management(our_poll)
		if("deletepoll")
			var/datum/poll_question/our_poll = null
			for(var/datum/poll_question/poll_check in GLOB.polls)
				if(poll_check.poll_id == params["poll_to_delete"])
					our_poll = poll_check
					break
			if(!our_poll)
				log_runtime(EXCEPTION("Couldn't find poll to delete with id [params["poll_to_delete"]]"))
				return
			our_poll.delete_poll()
		if("resultspoll")
			var/datum/poll_question/our_poll = null
			for(var/datum/poll_question/poll_check in GLOB.polls)
				if(poll_check.poll_id == params["poll_to_result"])
					our_poll = poll_check
					break
			if(!our_poll)
				log_runtime(EXCEPTION("Couldn't find poll to result with id [params["poll_to_result"]]"))
				return

			var/start_index = text2num(params["startat"]) || 0
			ui_client.holder.poll_results_panel(our_poll, start_index)


/**
  * Shows the results for a poll
  */
/datum/admins/proc/poll_results_panel(datum/poll_question/poll, start_index = 0)
	if(!check_rights(R_SERVER))
		return
	if(!SSdbcore.IsConnected())
		to_chat(usr, span_danger("Not connected to database. Cannot retrieve data."))
		return
	var/output = {"<div align='center'><b>Player Poll Results</b><hr>[poll.question]<hr>"}
	//Each poll type is different
	switch (poll.poll_type)
		//Show the options that were clicked
		if (POLLTYPE_MULTI, POLLTYPE_OPTION)
			output += "<table><tr><th>Options</th><th>Votes</th></tr>"
			//Get the results
			var/datum/db_query/query_get_poll_results = SSdbcore.NewQuery({"
				SELECT p.text, count(*)
				FROM [format_table_name("poll_vote")] AS pv
				INNER JOIN [format_table_name("poll_option")] AS p ON pv.optionid = p.id
				WHERE pv.pollid = :pollid AND pv.deleted = 0
				GROUP BY optionid
				ORDER BY count(*) DESC"},
				list(
					"pollid" = poll.poll_id,
				))
			if(!query_get_poll_results.warn_execute())
				qdel(query_get_poll_results)
				return
			while(query_get_poll_results.NextRow())
				output += "<tr><td>[query_get_poll_results.item[1]]</td><td>[query_get_poll_results.item[2]]</td></tr>"
			qdel(query_get_poll_results)
		//Provide lists of ckeys and their answers
		if (POLLTYPE_TEXT)
			//Change the table name
			output += "<a href='byond://?_src_=holder;resultspoll=[poll.UID()];startat=[start_index-10]'>Previous Page</a><a href='byond://?_src_=holder;resultspoll=[poll.UID()];startat=[start_index+10]'>Next Page</a><br/>"
			output += "<table><tr><th>Ckey</th><th>Response</th></tr>"
			//Get the results
			var/datum/db_query/query_get_poll_results = SSdbcore.NewQuery({"
				SELECT ckey, replytext
				FROM [format_table_name("poll_textreply")]
				WHERE pollid = :pollid AND deleted = 0
				LIMIT :limstart,:limend"},
				list(
					"pollid" = poll.poll_id,
					"limstart" = start_index,
					"limend" = 10
				))
			if(!query_get_poll_results.warn_execute())
				qdel(query_get_poll_results)
				return
			while(query_get_poll_results.NextRow())
				output += "<tr><td>[query_get_poll_results.item[1]]</td><td>[query_get_poll_results.item[2]]</td></tr>"
			qdel(query_get_poll_results)
		//Show each option, how many times it was rated for each and then the average
		if (POLLTYPE_RATING)
			output += "<table><tr><th>Option</th><th>Rating</th><th>Count</th></tr>"
			//Get the results
			var/datum/db_query/query_get_poll_results = SSdbcore.NewQuery({"
				SELECT p.text, pv.rating, COUNT(*)
				FROM [format_table_name("poll_vote")] AS pv
				INNER JOIN [format_table_name("poll_option")] AS p ON pv.optionid = p.id
				WHERE p.pollid = :pollid AND pv.deleted = 0
				GROUP BY optionid, rating
				ORDER BY optionid, rating DESC"},
				list(
					"pollid" = poll.poll_id,
				))
			if(!query_get_poll_results.warn_execute())
				qdel(query_get_poll_results)
				return
			while(query_get_poll_results.NextRow())
				output += "<tr><td>[query_get_poll_results.item[1]]</td><td>[query_get_poll_results.item[2]]</td><td>[query_get_poll_results.item[3]]</td></tr>"
			qdel(query_get_poll_results)
	output += "</table>"
	if(!QDELETED(usr))
		var/datum/browser/popup = new(usr, "playerpolllist", "Player Poll List", 500, 300)
		popup.set_content(output)
		popup.open(FALSE)
