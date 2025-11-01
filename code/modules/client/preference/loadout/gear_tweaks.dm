/datum/gear_tweak
	/// Displayed in TGUI name
	var/display_type
	/// Font Awesome icon
	var/fa_icon
	/// Explains what is this do in TGUI tooltip
	var/info

/datum/gear_tweak/proc/get_contents(metadata)
	return

/datum/gear_tweak/proc/get_metadata(user, metadata)
	return

/datum/gear_tweak/proc/get_default()
	return

/datum/gear_tweak/proc/get_tgui_data(param)
	return

/datum/gear_tweak/proc/update_gear_intro()
	return

/datum/gear_tweak/proc/tweak_gear_data(metadata, datum/gear_data)
	return

/datum/gear_tweak/proc/tweak_item(obj/item/gear, metadata)
	return

/*
* Color adjustment
*/

/datum/gear_tweak/color
	display_type = "Цвет"
	fa_icon = "palette"
	info = "Перекрашиваемое"
	var/list/valid_colors
	var/datum/gear/parent

/datum/gear_tweak/color/New(list/colors, datum/gear/parent)
	valid_colors = colors
	src.parent = parent
	..()

/datum/gear_tweak/color/get_contents(metadata)
	return "Цвет: <font color='[metadata]'>&#9899;</font>"

/datum/gear_tweak/color/get_default()
	return valid_colors ? valid_colors[1] : COLOR_WHITE

/datum/gear_tweak/color/get_metadata(user, metadata)
	if(valid_colors)
		metadata = tgui_input_list(user, "Выберите цвет предмета.", "Настройка цвета", valid_colors, metadata)
	else
		metadata = tgui_input_color(user, "Выберите цвет предмета.", "Настройка цвета", metadata)
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
	display_type = "Подтип"
	fa_icon = "bars"
	info = "Имеет подтипы"
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
	metadata = tgui_input_list(user, "Выберите подтип предмета.", "Выбор подтипа", valid_paths, metadata)
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
	var/atom/item = new path(src)
	tgui_data["icon_file"] = item.icon
	tgui_data["icon_state"] = item.icon_state
	var/list/names = item.ru_names || item.get_ru_names_cached()
	tgui_data["name"] = names ? names[NOMINATIVE] : item.name
	return tgui_data

/datum/gear_tweak/path/tweak_gear_data(metadata, datum/gear_data/gear_data)
	if(!(metadata in valid_paths))
		return
	gear_data.path = valid_paths[metadata]

// MARK: Rename
/datum/gear_tweak/rename
	display_type = "Название"
	fa_icon = "edit"
	info = "Можно переименовать"

/datum/gear_tweak/rename/get_default()
	return ""


/datum/gear_tweak/rename/get_metadata(user, metadata)
	var/new_name = tgui_input_text(user, "Переименуйте объект. При пустом поле будет выбрано стандартное название.", "Переименование предмета", metadata, MAX_NAME_LEN)
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
