/datum/buildmode_mode/varedit
	key = "edit"
	// Varedit mode
	var/varholder = "name"
	var/valueholder = "value"

/datum/buildmode_mode/varedit/Destroy()
	varholder = null
	valueholder = null
	return ..()

/datum/buildmode_mode/varedit/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Select var(type) & value")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Set var(type) & value")] -> Left Mouse Button on turf/obj/mob\n\
		[span_bold("Reset var's value")] -> Right Mouse Button on turf/obj/mob"))
	)

/datum/buildmode_mode/varedit/Reset()
	. = ..()
	varholder = null
	valueholder = null

// FIXME: This needs to use a standard var-editing interface instead of
// doing its own thing here
/datum/buildmode_mode/varedit/change_settings(mob/user)
	var/temp_varname = tgui_input_text(user, "Enter variable name:", "Name", "name", encode = FALSE)
	if(!vv_varname_lockcheck(temp_varname))
		return

	var/temp_value = user.client.vv_get_value()
	if(isnull(temp_value["class"]))
		Reset()
		to_chat(user, "<span class='notice'>Variable unset.</span>")
		return
	// we assign this once all user input is done, since things could get wonky otherwise
	varholder = temp_varname
	valueholder = temp_value["value"]

/datum/buildmode_mode/varedit/handle_click(user, params, obj/object)
	var/list/modifiers = params2list(params)

	if(isnull(varholder))
		to_chat(user, span_warning("Choose a variable to modify first."))
		return
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(object.vars.Find(varholder))
			if(!object.vv_edit_var(varholder, valueholder))
				to_chat(user, span_warning("Your edit was rejected by the object."))
				return
			log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [valueholder]")
		else
			to_chat(user, span_warning("[initial(object.name)] does not have a var called '[varholder]'"))
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(object.vars.Find(varholder))
			var/reset_value = initial(object.vars[varholder])
			if(!object.vv_edit_var(varholder, reset_value))
				to_chat(user, span_warning("Your edit was rejected by the object."))
				return
			log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [reset_value]")
		else
			to_chat(user, span_warning("[initial(object.name)] does not have a var called '[varholder]'"))

