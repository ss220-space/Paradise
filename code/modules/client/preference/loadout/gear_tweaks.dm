/datum/gear_tweak
	/// Displayed in TGUI name
	var/display_type
	/// Font Awesome icon
	var/fa_icon
	/// Explains what is this do in TGUI tooltip
	var/info

/datum/gear_tweak/proc/get_contents(var/metadata)
	return

/datum/gear_tweak/proc/get_metadata(var/user, var/metadata)
	return

/datum/gear_tweak/proc/get_default()
	return

/datum/gear_tweak/proc/get_tgui_data(param)
	return

/datum/gear_tweak/proc/update_gear_intro()
	return

/datum/gear_tweak/proc/tweak_gear_data(var/metadata, var/datum/gear_data)
	return

/datum/gear_tweak/proc/tweak_item(obj/item/gear, metadata)
	return

/*
* Color adjustment
*/

/datum/gear_tweak/color
	display_type = "Color"
	fa_icon = "palette"
	info = "Recolorable"
	var/list/valid_colors
	var/datum/gear/parent

/datum/gear_tweak/color/New(list/colors, datum/gear/parent)
	valid_colors = colors
	src.parent = parent
	..()

/datum/gear_tweak/color/get_contents(metadata)
	return "Color: <font color='[metadata]'>&#9899;</font>"

/datum/gear_tweak/color/get_default()
	return valid_colors ? valid_colors[1] : COLOR_WHITE

/datum/gear_tweak/color/get_metadata(user, metadata)
	if(valid_colors)
		metadata = tgui_input_list(user, "Choose an item color.", "Character Preference", valid_colors, metadata)
	else
		metadata = tgui_input_color(user, "Choose an item color.", "Global Preference", metadata)
	update_gear_intro(metadata)
	return metadata

/datum/gear_tweak/color/get_tgui_data(param)
	var/tgui_data = list()
	if(!param)
		return tgui_data
	tgui_data["display_param"] = param
	tgui_data["icon"] = parent.base64icon
	return tgui_data

/datum/gear_tweak/color/update_gear_intro(color)
	parent.update_gear_icon(color)

/datum/gear_tweak/color/tweak_item(obj/item/gear, metadata)
	if((valid_colors && !(metadata in valid_colors)) || !metadata)
		return
	gear.color = metadata

/*
* Path adjustment
*/

/datum/gear_tweak/path
	display_type = "Subtype"
	fa_icon = "bars"
	info = "Has subtypes"
	var/list/valid_paths = list()
	var/datum/gear/parent

/datum/gear_tweak/path/New(list/paths, datum/gear/parent, name = FALSE)
	if(name)
		for(var/atom/path as anything in paths)
			valid_paths[initial(path.name)] = path
	else
		valid_paths = paths
	src.parent = parent
	..()

/datum/gear_tweak/path/get_contents(metadata)
	return "Type: [metadata]"

/datum/gear_tweak/path/get_default()
	return valid_paths[1]

/datum/gear_tweak/path/get_metadata(user, metadata)
	metadata = tgui_input_list(user, "Choose a type.", "Character Preference", valid_paths, metadata)
	update_gear_intro(metadata)
	return metadata

/datum/gear_tweak/path/update_gear_intro(path)
	parent.path = valid_paths[path]
	parent.update_gear_icon()

/datum/gear_tweak/path/get_tgui_data(param)
	var/tgui_data = list()
	if(!param)
		return tgui_data
	tgui_data["display_param"] = param
	var/obj/item/path = valid_paths[param]
	tgui_data["icon_file"] = path.icon
	tgui_data["icon_state"] = path.icon_state
	tgui_data["name"] = path.name
	return tgui_data

/datum/gear_tweak/path/tweak_gear_data(metadata, datum/gear_data/gear_data)
	if(!(metadata in valid_paths))
		return
	gear_data.path = valid_paths[metadata]

// MARK: Rename
/datum/gear_tweak/rename
	display_type = "Name"
	fa_icon = "edit"
	info = "Renameable"

/datum/gear_tweak/rename/get_default()
	return ""


/datum/gear_tweak/rename/get_metadata(user, metadata)
	var/new_name = tgui_input_text(user, "Rename an object. Enter empty line for stock name", "Rename Gear", metadata, MAX_NAME_LEN)
	if(isnull(new_name))
		return metadata
	return new_name

/datum/gear_tweak/rename/get_tgui_data(param)
	var/tgui_data = list()
	if(!param)
		return tgui_data
	tgui_data["display_param"] = param
	tgui_data["name"] = param
	return tgui_data

/datum/gear_tweak/rename/tweak_item(obj/item/gear, metadata)
	if(!metadata)
		return

	gear.name = metadata
