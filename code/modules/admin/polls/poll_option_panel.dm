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

/datum/ui_module/poll_option_panel/ui_state(mob/user)
	return GLOB.admin_state

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
			ui_client.poll_option_parse(option_list, poll, option)

/proc/open_poll_option(datum/poll_question/poll, datum/poll_option/option)
	if(!check_rights(R_SERVER))
		return

	var/datum/ui_module/poll_option_panel/panel_pollo = new(usr)
	panel_pollo.poll = poll
	panel_pollo.option = option

	panel_pollo.ui_interact(usr)

/**
 * Show the options for creating a poll option or editing its parameters.
 *
 */
/datum/admins/proc/poll_option_panel(datum/poll_question/poll, datum/poll_option/option)
	var/list/output = list("<form method='get' action='?src=[REF(src)]'>")
	output += {"<input type='hidden' name='src' value='[REF(src)]'> Option for poll [poll.question]
	<br>
	<textarea class='textbox' name='optiontext'>[option?.text]</textarea>
	<br>
	"}
	if(poll.poll_type == POLLTYPE_RATING)
		output += {"Minimum value
		<input type='text' name='minval' size='3' value='[option?.min_val]'>
		Maximum Value
		<input type='text' name='maxval' size='3' value='[option?.max_val]'>
		<div class='row'>
			<div class='column left'>
				<label class='inputlabel checkbox'>Minimum description
				<input type='checkbox' id='descmincheck' name='descmincheck' value='1'[option?.desc_min ? " checked": ""]>
				<div class='inputbox'></div></label>
				<br>
				<label class='inputlabel checkbox'>Middle description
				<input type='checkbox' id='descmidcheck' name='descmidcheck' value='1'[option?.desc_mid ? " checked": ""]>
				<div class='inputbox'></div></label>
				<br>
				<label class='inputlabel checkbox'>Maximum description
				<input type='checkbox' id='descmaxcheck' name='descmaxcheck' value='1'[option?.desc_max ? " checked": ""]>
				<div class='inputbox'></div></label>
			</div>
			<div class='column'>
				<input type='text' name='descmintext' size='26' value='[option?.desc_min]'>
				<br>
				<input type='text' name='descmidtext' size='26' value='[option?.desc_mid]'>
				<br>
				<input type='text' name='descmaxtext' size='26' value='[option?.desc_max]'>
			</div>
		</div>
		"}
	output += {"<label class='inputlabel checkbox'>Include option in poll's results percentage calculation
	<input type='checkbox' id='defpercalc' name='defpercalc' value='1'[option?.default_percentage_calc ? " checked": ""]>
	<div class='inputbox'></div></label><br>
	<input type='hidden' name='submitoption' value='[REF(option)]'>
	<input type='hidden' name='submitoptionpoll' value='[REF(poll)]'>
	<input type='submit' value='Add option'>
	"}
	var/panel_height = 180
	if(poll.poll_type == POLLTYPE_RATING)
		panel_height = 320
	var/datum/browser/panel = new(usr, "popanel", "Poll Option Panel", 370, panel_height)
	panel.set_content(jointext(output, ""))
	panel.open()
