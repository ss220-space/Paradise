/*
 * Poll Management Panel
 *
 * Show the options for creating a poll or editing its parameters along with its linked options.
 */
/datum/ui_module/poll_management_panel
	name = "Poll Management Panel"
	// It is set if we have a poll asked to be edited. Else we create new poll
	var/datum/poll_question/poll = null
	// Temp-configuration for poll. Firstly designed for TGUI use and on completion, sets to editing poll/new poll.
	var/list/list_poll = list()
	var/run_duration = TRUE // TRUE - run for, FALSE - run until
	var/run_start = TRUE // TRUE - run now , FALSE - at datetime
	var/clear_votes = TRUE // Should clean votes upon updating poll

/client/proc/open_poll_management(datum/poll_question/poll, datum/tgui/ui = null)
	if(!check_rights(R_SERVER))
		return

	var/datum/ui_module/poll_management_panel/panel_pollo = new(usr)
	panel_pollo.poll = poll

	panel_pollo.ui_interact(usr)

/datum/ui_module/poll_management_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/poll_management_panel/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PollManagement", name)
		ui.open()

/datum/ui_module/poll_management_panel/ui_static_data(mob/user)
	. = list()
	.["poll_types"] = list(POLLTYPE_OPTION, POLLTYPE_TEXT, POLLTYPE_RATING, POLLTYPE_MULTI)
	.["interval_types"] = list(POLL_SECOND, POLL_MINUTE, POLL_HOUR, POLL_DAY, POLL_WEEK, POLL_MONTH, POLL_YEAR)

/datum/ui_module/poll_management_panel/ui_data(mob/user)
	. = list()
	.["has_poll"] = poll ? TRUE : FALSE
	list_poll["question"] = poll ? poll.question : ""
	list_poll["poll_type"] = poll ? poll.poll_type : POLLTYPE_OPTION
	list_poll["options_allowed"] = poll ? poll.options_allowed : "0"
	list_poll["admin_only"] = poll ? poll.admin_only : FALSE
	list_poll["dont_show"] = poll ? poll.dont_show : FALSE
	list_poll["allow_revoting"] = poll ? poll.allow_revoting : FALSE
	list_poll["interval"] = poll ? poll.interval : POLL_DAY
	list_poll["duration"] = poll ? poll.duration : 1
	list_poll["start_datetime"] = poll ? poll.start_datetime : ""
	list_poll["end_datetime"] = poll ? poll.end_datetime : ""
	list_poll["subtitle"] = poll ? poll.subtitle : ""
	list_poll["poll_votes"] = poll ? poll.poll_votes : 0
	list_poll["minimum_playtime"] = poll ? poll.minimum_playtime : 0
	// non-poll but needed
	list_poll["run_duration"] = run_duration
	list_poll["run_start"] = run_start
	list_poll["clear_votes"] = clear_votes

	list_poll["options"] = list()
	if(poll)
		var/option_count = 0
		for(var/datum/poll_option/option in poll.options)
			option_count++
			var/list/list_option = list("num" = "[option_count]",
				"id" = option.option_id,
				"text" = option.text,
				"min_val" = option.min_val,
				"max_val" = option.max_val,
				"desc_min" = option.desc_min,
				"desc_mid" = option.desc_mid,
				"desc_max" = option.desc_max
			)
			list_poll["options"] += list(list_option)
	.["poll"] = list_poll

/datum/ui_module/poll_management_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/client/ui_client = ui.user.client
	switch (action)
		if("clear_poll_votes")
			poll.clear_poll_votes()
		if("initialize_poll")
			list_poll["submitpoll"] = FALSE
			list_poll["question"] = params["question"] // I'd be happy if useLocalState could connect to DM, without pull&push params
			list_poll["poll_type"] = params["poll_type"] // or I'm dumb, I'm not sorry
			list_poll["options_allowed"] = params["options_allowed"]
			list_poll["admin_only"] = params["admin_only"]
			list_poll["dont_show"] = params["dont_show"]
			list_poll["allow_revoting"] = params["allow_revoting"]
			list_poll["interval"] = params["interval"]
			list_poll["duration"] = params["duration"]
			list_poll["start_datetime"] = params["start_datetime"]
			list_poll["end_datetime"] = params["end_datetime"]
			list_poll["subtitle"] = params["subtitle"]
			list_poll["poll_votes"] = params["poll_votes"]
			list_poll["minimum_playtime"] = params["minimum_playtime"]
			// non-poll
			list_poll["run_duration"] = params["run_duration"]
			list_poll["run_start"] = params["run_start"]
			list_poll["clear_votes"] = params["clear_votes"]
			ui_client.poll_parse(src)
		if("submit_poll")
			list_poll["submitpoll"] = TRUE
			list_poll["question"] = params["question"]
			list_poll["poll_type"] = params["poll_type"]
			list_poll["options_allowed"] = params["options_allowed"]
			list_poll["admin_only"] = params["admin_only"]
			list_poll["dont_show"] = params["dont_show"]
			list_poll["allow_revoting"] = params["allow_revoting"]
			list_poll["interval"] = params["interval"]
			list_poll["duration"] = params["duration"]
			list_poll["start_datetime"] = params["start_datetime"]
			list_poll["end_datetime"] = params["end_datetime"]
			list_poll["subtitle"] = params["subtitle"]
			list_poll["poll_votes"] = params["poll_votes"]
			list_poll["minimum_playtime"] = params["minimum_playtime"]
			// non-poll
			list_poll["run_duration"] = params["run_duration"]
			list_poll["run_start"] = params["run_start"]
			list_poll["clear_votes"] = params["clear_votes"]
			ui_client.poll_parse(src, poll)
		if("add_poll_option")
			open_poll_option(poll)
		if("edit_poll_option")
			for(var/datum/poll_option/option in poll.options)
				if(option.option_id == params["option_to_edit"]) // we lookd by id
					open_poll_option(poll, option)
					break
		if("delete_poll_option")
			for(var/datum/poll_option/option in poll.options)
				if(option.option_id == params["option_to_edit"])
					option.delete_option()
					break

