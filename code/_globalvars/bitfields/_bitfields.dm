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
	return FALSE

/// Turns /datum/bitfield subtypes into a list for use in debugging
/proc/generate_bitfields()
	var/list/bitfields = list()
	for(var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		bitfields[bitfield.variable] = bitfield.flags
	return bitfields

/// Returns an associative list of bitflag name -> number for all valid bitflags in the passed in field
/proc/get_valid_bitflags(var_name)
	if(!istext(var_name))
		return list()
	return GLOB.bitfields[var_name] || list()

/proc/get_random_bitflag(var_name)
	var/list/flags = get_valid_bitflags(var_name)
	if(!length(flags))
		return
	var/name = pick(flags)
	return flags[name]

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

/proc/input_bitfield(mob/user, bitfield, current_value, allowed_edit_field = ALL)
	var/list/bitflags = get_valid_bitflags(bitfield)
	if(!user || !length(bitflags))
		return
	var/list/currently_checked = list()
	for(var/bit_name in bitflags)
		var/bit_value = bitflags[bit_name]
		if(!(allowed_edit_field & bit_value))
			continue
		currently_checked[bit_name] = !!(current_value & bit_value)

	if(!length(currently_checked))
		return

	var/list/result = tgui_input_checkbox_list(user, "Редактирование битовой маски для [bitfield].", "Битовая маска", currently_checked)
	if(isnull(result) || !islist(result))
		return

	var/result_bitfield = current_value & ~allowed_edit_field
	for(var/flag_name in result)
		if(result[flag_name])
			result_bitfield |= bitflags[flag_name]
	return result_bitfield

/// Returns null if no such field exists, a list of all matching flags by name otherwise
/proc/get_matching_bitflags(var_name, value)
	var/list/valid_bitflags = get_valid_bitflags(var_name)
	if(!length(valid_bitflags))
		return null

	var/list/flags = list()
	for(var/bit_name in valid_bitflags)
		if(value & valid_bitflags[bit_name])
			flags += bit_name
	return flags
