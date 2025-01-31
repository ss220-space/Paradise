/*
 * Poll Management Panel
 *
 * Show the options for creating a poll or editing its parameters along with its linked options.
 */
/datum/ui_module/poll_option_panel
	name = "Poll Option Panel"
	// Our poll to what option we're adding/editing option.
	var/datum/poll_question/poll = null
	// It is set if we have a option asked to be edited. Else we create new poll
	var/datum/poll_option/option = null
	// Temp-configuration for option. Firstly designed for TGUI use and on completion, sets to editing/adding option.
	var/list/option_list = list()

/proc/open_poll_option(datum/poll_question/poll, datum/poll_option/option)
	if(!check_rights(R_SERVER))
		return

	var/datum/ui_module/poll_option_panel/panel_pollo = new(usr)
	panel_pollo.poll = poll
	panel_pollo.option = option

	panel_pollo.ui_interact(usr)

/datum/ui_module/poll_option_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/poll_option_panel/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PollOptionPanel", name)
		ui.open()

/datum/ui_module/poll_option_panel/ui_static_data(mob/user)
	. = list()
	.["poll_question"] = "Option for poll [poll.question]"

	return .

/datum/ui_module/poll_option_panel/ui_data(mob/user)
	. = list()
	option_list["text"] = option ? option.text : ""
	option_list["default_percentage_calc"] = option ? option.default_percentage_calc : TRUE
	option_list["min_val"] = option ? option.min_val : "0"
	option_list["max_val"] = option ? option.max_val : "10"
	option_list["desc_min_check"] = option?.desc_min ? TRUE : FALSE
	option_list["desc_mid_check"] = option?.desc_mid ? TRUE : FALSE
	option_list["desc_max_check"] = option?.desc_max ? TRUE : FALSE
	option_list["desc_min_text"] = option ? option.desc_min : ""
	option_list["desc_mid_text"] = option ? option.desc_mid : ""
	option_list["desc_max_text"] = option ? option.desc_max : ""
	.["option"] = option_list


/datum/ui_module/poll_option_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/client/ui_client = ui.user.client
	switch (action)
		if("submit_option")
			option_list["text"] = params["text"]
			option_list["default_percentage_calc"] = params["default_percentage_calc"]
			option_list["min_val"] = params["min_val"]
			option_list["max_val"] = params["max_val"]
			option_list["desc_min_check"] = params["desc_min_check"]
			option_list["desc_mid_check"] = params["desc_mid_check"]
			option_list["desc_max_check"] = params["desc_max_check"]
			option_list["desc_min_text"] = params["desc_min_text"]
			option_list["desc_mid_text"] = params["desc_mid_text"]
			option_list["desc_max_text"] = params["desc_max_text"]
			ui_client.poll_option_parse(option_list, poll, option)
			ui.close() // done
