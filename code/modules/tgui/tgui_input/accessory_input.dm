/proc/tgui_input_accessory(mob/user, message, title = "Select", list/items, default, category, timeout = 0, ui_state = GLOB.always_state)
	if(!user)
		user = usr

	if(!length(items))
		CRASH("[user] tried to open an empty TGUI Accessory Picker. Contents are: [items]")

	if(length(items) == 1)
		return items[1]

	if(!istype(user))
		if(!isclient(user))
			CRASH("We passed something that wasn't a user/client in a TGUI Accessory Picker! The passed user was [user]!")
		var/client/client = user
		user = client.mob

	if(isnull(user.client))
		return

	if(user.client.prefs?.toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT)
		return input(user, message, title, default) as null|anything in items

	var/datum/tgui_list_input/accessory/picker = new(user, message, title, items, default, timeout, ui_state, category)

	if(picker.invalid)
		qdel(picker)
		return

	picker.ui_interact(user)
	picker.wait()
	if(picker)
		. = picker.choice
		qdel(picker)

/datum/tgui_list_input/accessory
	modal_type = "AccessoryInputWindow"
	var/category

/datum/tgui_list_input/accessory/New(mob/user, message, title, list/_items, default, timeout, ui_state, category)
	src.category = category
	return ..(user, message, title, _items, default, timeout, ui_state)

/datum/tgui_list_input/accessory/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/spritesheet_batched/sprite_accessories)

/datum/tgui_list_input/accessory/ui_static_data(mob/user)
	. = ..()
	var/datum/asset/spritesheet_batched/sprite_accessories/sheet = get_asset_datum(/datum/asset/spritesheet_batched/sprite_accessories)
	var/list/preview_keys = list()
	for(var/item in items)
		preview_keys[item] = sheet.get_preview_key(category, items_map[item])
	.["icon_prefix"] = "[sheet.name][ICON_SIZE_X]x[ICON_SIZE_Y]"
	.["preview_keys"] = preview_keys
