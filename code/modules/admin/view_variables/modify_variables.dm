GLOBAL_LIST_INIT(VVlocked, list("vars", "datum_flags", "client", "mob")) // R_DEBUG
GLOBAL_PROTECT(VVlocked)
GLOBAL_LIST_INIT(VVicon_edit_lock, list("icon", "icon_state", "overlays", "underlays", "resize")) // R_EVENT | R_DEBUG
GLOBAL_PROTECT(VVicon_edit_lock)
GLOBAL_LIST_INIT(VVckey_edit, list("key", "ckey")) // R_SPAWN | R_DEBUG
GLOBAL_PROTECT(VVckey_edit)
GLOBAL_LIST_INIT(VVpixelmovement, list("step_x", "step_y", "step_size", "bound_height", "bound_width", "bound_x", "bound_y")) // R_DEBUG + warning
GLOBAL_PROTECT(VVpixelmovement)

/client/proc/vv_parse_text(source, new_var)
	if(source && findtext(new_var, "\["))
		var/process_vars = tgui_alert(usr, "\[] detected in string, process as variables?", "Process Variables?", list("Yes", "No"))
		if(process_vars == "Yes")
			. = string2listofvars(new_var, source)

/**
 * Do they want you to include subtypes?
 *
 * Type:
 * 1) FALSE = no subtypes, strict exact type pathing (or the type doesn't have subtypes)
 * 2) TRUE = Yes subtypes
 * 3) NULL = User cancelled at the prompt or invalid type given
 */
/client/proc/vv_subtype_prompt(type)
	if(!ispath(type))
		return
	var/list/subtypes = subtypesof(type)
	if(!subtypes || !length(subtypes))
		return FALSE
	if(subtypes && length(subtypes))
		switch(tgui_alert(usr, "Strict object type detection?", "Type detection", list("Strictly this type", "This type and subtypes", "Cancel")))
			if("Strictly this type")
				return FALSE
			if("This type and subtypes")
				return TRUE
			else
				return

/client/proc/vv_reference_list(type, subtypes)
	. = list()
	var/list/types = list(type)
	if(subtypes)
		types = typesof(type)

	var/list/fancytypes = make_types_fancy(types)

	for(var/fancytype in fancytypes) //swap the assoication
		types[fancytypes[fancytype]] = fancytype

	var/things = get_all_of_type(type, subtypes)

	var/i = 0
	for(var/thing in things)
		var/datum/datum = thing
		i++
		/**
		 * Try one of 3 methods to shorten the type text:
		 * 1) fancy type
		 * 2) fancy type with the base type removed from the begaining
		 * 3) the type with the base type removed from the begaining
		 */
		var/fancytype = types[datum.type]
		if(findtext(fancytype, types[type]))
			fancytype = copytext(fancytype, length(types[type]) + 1)
		var/shorttype = copytext("[datum.type]", length("[type]") + 1)
		if(length_char(shorttype) > length_char(fancytype))
			shorttype = fancytype
		if(!length(shorttype))
			shorttype = "/"

		.["[datum]([shorttype])[UID_of(datum)]#[i]"] = datum

/client/proc/mod_list_add_ass(atom/target_atom)
	var/list/value_info = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
	var/class = value_info["class"]
	if(!class)
		return
	var/var_value = value_info["value"]

	if(class == VV_TEXT || class == VV_MESSAGE)
		var/list/var_names = vv_parse_text(target_atom, var_value)
		for(var/var_name in var_names)
			var_value = replacetext(var_value,"\[[var_name]]","[target_atom.vars[var_name]]")

	return var_value

/client/proc/mod_list_add(list/target_list, atom/target_object, original_name, objectvar)
	var/list/value_info = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
	var/class = value_info["class"]
	if(!class)
		return
	var/var_value = value_info["value"]

	if(class == VV_TEXT || class == VV_MESSAGE)
		var/list/variable_names = vv_parse_text(target_object, var_value)
		for(var/var_name in variable_names)
			var_value = replacetext(var_value,"\[[var_name]]","[target_object.vars[var_name]]")

	if(target_object)
		target_list = target_list.Copy()

	target_list += list(var_value)

	switch(tgui_alert(usr, "Would you like to associate a value with the list entry?", null, list("Yes", "No")))
		if("Yes")
			target_list[var_value] = mod_list_add_ass(target_object) //hehe
	if(target_object)
		if(!target_object.vv_edit_var(objectvar, target_list))
			to_chat(src, "Your edit was rejected by the object.")
			return
	log_world("### ListVarEdit by [src]: [(target_object ? target_object.type : "/list")] [objectvar]: ADDED=[var_value]")
	log_admin("[key_name(src)] modified [original_name]'s [objectvar]: ADDED=[var_value]")
	message_admins("[key_name_admin(src)] modified [original_name]'s [objectvar]: ADDED=[var_value]")

/client/proc/mod_list(list/target_list, atom/target_atom, original_name, objectvar, index, autodetect_class = FALSE)
	if(!check_rights(R_VAREDIT))
		return
	if(!islist(target_list))
		to_chat(src, "Not a List.", confidential = TRUE)
		return
	if(isalist(target_list))
		to_chat(src, "alists are currently unsupported", confidential = TRUE)
		return

	if(length(target_list) > 1000)
		var/confirm = tgui_alert(usr, "The list you're trying to edit is very long, continuing may crash the server.", "Warning", list("Continue", "Abort"))
		if(confirm != "Continue")
			return

	var/is_normal_list = IS_NORMAL_LIST(target_list)
	var/list/names = list()
	for(var/pos in 1 to length(target_list))
		var/key = target_list[pos]
		var/value
		if(is_normal_list && !isnum(key))
			value = target_list[key]
		if(value == null)
			value = "null"
		names["#[pos] [key] = [value]"] = pos
	if(!index)
		var/variable = tgui_input_list(usr, "Which var?", "Var", names + "(ADD VAR)" + "(CLEAR NULLS)" + "(CLEAR DUPES)" + "(SHUFFLE)")

		if(variable == null)
			return

		if(variable == "(ADD VAR)")
			mod_list_add(target_list, target_atom, original_name, objectvar)
			return

		if(variable == "(CLEAR NULLS)")
			target_list = target_list.Copy()
			list_clear_nulls(target_list)
			if(!target_atom.vv_edit_var(objectvar, target_list))
				to_chat(src, "Your edit was rejected by the object.", confidential = TRUE)
				return
			log_world("### ListVarEdit by [src]: [target_atom.type] [objectvar]: CLEAR NULLS")
			log_admin("[key_name(src)] modified [original_name]'s [objectvar]: CLEAR NULLS")
			message_admins("[key_name_admin(src)] modified [original_name]'s list [objectvar]: CLEAR NULLS")
			return

		if(variable == "(CLEAR DUPES)")
			target_list = unique_list(target_list)
			if(!target_atom.vv_edit_var(objectvar, target_list))
				to_chat(src, "Your edit was rejected by the object.", confidential = TRUE)
				return
			log_world("### ListVarEdit by [src]: [target_atom.type] [objectvar]: CLEAR DUPES")
			log_admin("[key_name(src)] modified [original_name]'s [objectvar]: CLEAR DUPES")
			message_admins("[key_name_admin(src)] modified [original_name]'s list [objectvar]: CLEAR DUPES")
			return

		if(variable == "(SHUFFLE)")
			target_list = shuffle(target_list)
			if(!target_atom.vv_edit_var(objectvar, target_list))
				to_chat(src, "Your edit was rejected by the object.", confidential = TRUE)
				return
			log_world("### ListVarEdit by [src]: [target_atom.type] [objectvar]: SHUFFLE")
			log_admin("[key_name(src)] modified [original_name]'s [objectvar]: SHUFFLE")
			message_admins("[key_name_admin(src)] modified [original_name]'s list [objectvar]: SHUFFLE")
			return

		index = names[variable]

	var/assoc_key
	if(index == null)
		return
	var/assoc = 0
	var/prompt = tgui_alert(usr, "Do you want to edit the key or its assigned value?", "Associated List", list("Key", "Assigned Value", "Cancel"))
	if(prompt == "Cancel")
		return
	if(prompt == "Assigned Value")
		assoc = 1
		assoc_key = target_list[index]
	var/default
	var/variable
	var/old_assoc_value // EXPERIMENTAL - Keep old associated value while modifying key, if any
	if(is_normal_list)
		if(assoc)
			variable = target_list[assoc_key]
		else
			variable = target_list[index]
			/* --- EXPERIMENTAL --- */
			if(IS_VALID_ASSOC_KEY(variable))
				var/found = target_list[variable]
				if(!isnull(found))
					old_assoc_value = found
			/* --- EXPERIMENTAL --- */

	default = vv_get_class(objectvar, variable)

	to_chat(src, "Variable appears to be <b>[uppertext(default)]</b>.", confidential = TRUE)
	to_chat(src, "Variable contains: [variable]", confidential = TRUE)

	if(default == VV_NUM)
		var/dir_text = ""
		var/direction_candidate = variable
		if(direction_candidate > 0 && direction_candidate < 16)
			if(direction_candidate & 1)
				dir_text += DIR_NAME_ENG_NORTH
			if(direction_candidate & 2)
				dir_text += DIR_NAME_ENG_SOUTH
			if(direction_candidate & 4)
				dir_text += DIR_NAME_ENG_EAST
			if(direction_candidate & 8)
				dir_text += DIR_NAME_ENG_WEST

		if(dir_text)
			to_chat(usr, "If a direction, direction is: [dir_text]", confidential = TRUE)

	var/original_var = variable

	if(target_atom)
		target_list = target_list.Copy()
	var/class
	if(autodetect_class)
		if(default == VV_TEXT)
			default = VV_MESSAGE
		class = default
	var/list/value_info = vv_get_value(default_class = default, current_value = original_var, restricted_classes = list(VV_RESTORE_DEFAULT), extra_classes = list(VV_LIST, "DELETE FROM LIST"))
	class = value_info["class"]
	if(!class)
		return
	var/new_var = value_info["value"]

	if(class == VV_MESSAGE)
		class = VV_TEXT

	switch(class) //Spits a runtime error if you try to modify an entry in the contents list. Dunno how to fix it, yet.
		if(VV_LIST)
			mod_list(variable, target_atom, original_name, objectvar)

		if("DELETE FROM LIST")
			target_list.Cut(index, index + 1)
			if(target_atom)
				if(target_atom.vv_edit_var(objectvar, target_list))
					to_chat(src, "Your edit was rejected by the object.", confidential = TRUE)
					return
			log_world("### ListVarEdit by [src]: [target_atom.type] [objectvar]: REMOVED=[html_encode("[original_var]")]")
			log_admin("[key_name(src)] modified [original_name]'s [objectvar]: REMOVED=[original_var]")
			message_admins("[key_name_admin(src)] modified [original_name]'s [objectvar]: REMOVED=[original_var]")
			return

		if(VV_TEXT)
			var/list/variable_names = vv_parse_text(target_atom, new_var)
			for(var/var_name in variable_names)
				new_var = replacetext(new_var,"\[[var_name]]","[target_atom.vars[var_name]]")

	if(is_normal_list)
		if(assoc)
			target_list[assoc_key] = new_var
		else
			target_list[index] = new_var
			if(!isnull(old_assoc_value) && IS_VALID_ASSOC_KEY(new_var))
				target_list[new_var] = old_assoc_value
	if(target_atom)
		if(target_atom.vv_edit_var(objectvar, target_list) == FALSE)
			to_chat(src, "Your edit was rejected by the object.", confidential = TRUE)
			return
	log_world("### ListVarEdit by [src]: [(target_atom ? target_atom.type : "/list")] [objectvar]: [original_var]=[new_var]")
	log_admin("[key_name(src)] modified [original_name]'s [objectvar]: [original_var]=[new_var]")
	message_admins("[key_name_admin(src)] modified [original_name]'s varlist [objectvar]: [original_var]=[new_var]")

/proc/vv_varname_lockcheck(param_var_name)
	if(param_var_name in GLOB.VVlocked)
		if(!check_rights(R_DEBUG))
			return FALSE
	if(param_var_name in GLOB.VVckey_edit)
		if(!check_rights(R_SPAWN | R_DEBUG))
			return FALSE
	if(param_var_name in GLOB.VVicon_edit_lock)
		if(!check_rights(R_EVENT | R_DEBUG))
			return FALSE
	if(param_var_name in GLOB.VVpixelmovement)
		if(!check_rights(R_DEBUG))
			return FALSE
		var/prompt = tgui_alert(usr, "Editing this var may irreparably break tile gliding for the rest of the round. THIS CAN'T BE UNDONE", "DANGER", list("ABORT ", "Continue", " ABORT"))
		if(prompt != "Continue")
			return FALSE
	return TRUE

/client/proc/modify_variables(atom/target_atom, param_var_name = null, autodetect_class = FALSE)
	if(!check_rights(R_VAREDIT))
		return

	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!(param_var_name in target_atom.vars))
			to_chat(src, "A variable with this name ([param_var_name]) doesn't exist in this datum ([target_atom])", confidential = TRUE)
			return
		variable = param_var_name

	else
		var/list/names = list()
		for(var/var_name in target_atom.vars)
			names += var_name

		names = sort_list(names)

		variable = tgui_input_list(usr, "Which var?", "Var", names)
		if(!variable)
			return

	if(!target_atom.can_vv_get(variable))
		return

	var_value = target_atom.vars[variable]
	if(!vv_varname_lockcheck(variable))
		return

	var/default = vv_get_class(variable, var_value)

	if(isnull(default))
		to_chat(src, "Unable to determine variable type.", confidential = TRUE)
	else
		to_chat(src, "Variable appears to be <b>[uppertext(default)]</b>.", confidential = TRUE)

	to_chat(src, "Variable contains: [var_value]", confidential = TRUE)

	if(default == VV_NUM)
		var/dir_text = ""
		if(var_value > 0 && var_value < 16)
			if(var_value & 1)
				dir_text += DIR_NAME_ENG_NORTH
			if(var_value & 2)
				dir_text += DIR_NAME_ENG_SOUTH
			if(var_value & 4)
				dir_text += DIR_NAME_ENG_EAST
			if(var_value & 8)
				dir_text += DIR_NAME_ENG_WEST

		if(dir_text)
			to_chat(src, "If a direction, direction is: [dir_text]")

	if(autodetect_class && default != VV_NULL)
		if(default == VV_TEXT)
			default = VV_MESSAGE
		class = default

	var/list/value = vv_get_value(class, default, var_value, extra_classes = list(VV_LIST), var_name = variable)
	class = value["class"]

	if(!class)
		return
	var/var_new = value["value"]

	if(class == VV_MESSAGE)
		class = VV_TEXT

	var/original_name = "[target_atom]"

	switch(class)
		if(VV_LIST)
			if(!islist(var_value))
				mod_list(list(), target_atom, original_name, variable)

			mod_list(var_value, target_atom, original_name, variable)
			return

		if(VV_RESTORE_DEFAULT)
			var_new = initial(target_atom.vars[variable])

		if(VV_TEXT)
			var/list/varsvars = vv_parse_text(target_atom, var_new)
			for(var/var_name in varsvars)
				var_new = replacetext(var_new, "\[[var_name]]", "[target_atom.vars[var_name]]")

	if(!target_atom.vv_edit_var(variable, var_new))
		to_chat(src, "Your edit was rejected by the object.", confidential = TRUE)
		return
	vv_update_display(target_atom, "varedited", VV_MSG_EDITED)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_VAR_EDIT, args)
	log_world("### VarEdit by [key_name(src)]: [target_atom.type] [variable]=[var_value] => [var_new]")
	log_admin("[key_name(src)] modified [original_name]'s [variable] from [html_encode("[var_value]")] to [html_encode("[var_new]")]")
	var/msg = "[key_name_admin(src)] modified [original_name]'s [variable] from [var_value] to [var_new]"
	message_admins(msg)
	return TRUE
