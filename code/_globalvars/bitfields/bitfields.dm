GLOBAL_LIST_INIT(bitfields, generate_bitfields())

/// Specifies a bitfield for smarter debugging
/datum/bitfield
	/// The variable name that contains the bitfield
	var/variable

	/// An associative list of the readable flag and its true value
	var/list/flags



/datum/bitfield/can_vv_delete()
	return FALSE

/datum/bitfield/vv_edit_var(var_name, var_value)
	return FALSE // no.

/// Turns /datum/bitfield subtypes into a list for use in debugging
/proc/generate_bitfields()
	var/list/bitfields = list()
	for (var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		bitfields[bitfield.variable] = bitfield.flags
	return bitfields


/proc/translate_bitfield(variable_type, variable_name, variable_value)
	if(variable_type != VV_BITFIELD)
		return variable_value

	var/list/flags = list()
	for(var/flag in GLOB.bitfields[variable_name])
		if(variable_value & GLOB.bitfields[variable_name][flag])
			flags += flag
	if(length(flags))
		return jointext(flags, ", ")
	return "NONE"

/proc/input_bitfield(mob/user, bitfield, current_value)
	if(!user || !(bitfield in GLOB.bitfields))
		return
	var/list/currently_checked = list()
	for(var/name in GLOB.bitfields[bitfield])
		currently_checked[name] = (current_value & GLOB.bitfields[bitfield][name])

	var/list/result = tgui_input_checkbox_list(user, "Редактирование битовой маски для [bitfield].", "Битовая маска", currently_checked)
	if(isnull(result) || !islist(result))
		return

	var/new_result = 0
	for(var/name in GLOB.bitfields[bitfield])
		if(result[name])
			new_result |= GLOB.bitfields[bitfield][name]
	return new_result

