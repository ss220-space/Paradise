GLOBAL_LIST_EMPTY(custom_item_datums)

SUBSYSTEM_DEF(custom_item)
	name = "Custom item"
	init_order = INIT_ORDER_CUSTOM_ITEM
	flags = SS_NO_FIRE
	ss_id = "custom_item"

	var/list/custom_gear_info

/datum/controller/subsystem/custom_item/Initialize(timeofday)
	init_custom_datums()

	if(!get_icons())
		return SS_INIT_FAILURE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/custom_item/proc/init_custom_datums()
	for(var/datum/custom_item_datum/type as anything in subtypesof(/datum/custom_item_datum))
		GLOB.custom_item_datums[type::name] = new type

/datum/controller/subsystem/custom_item/Recover()
	init_custom_datums()
	get_icons()

/datum/controller/subsystem/custom_item/proc/get_icons()
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT ckey, name, dummy, type FROM [format_table_name("custom_items")]"
	)
	if(!query.Execute())
		qdel(query)
		return FALSE

	var/savefile/dummySave = get_dummy_savefile()
	var/icon/icon

	while(query.NextRow())
		var/ckey = query.item[1]
		var/name = query.item[2]
		var/dummy = query.item[3]
		var/type = query.item[4]
		var/datum/datum_type = GLOB.custom_item_datums[type]
		dummySave.ImportText("dummy", dummy)
		READ_FILE(dummySave["dummy"], icon)
		var/datum/custom_item_datum/new_custom = new datum_type.type(name, icon)
		LAZYADDASSOC(custom_gear_info, ckey, new_custom)

	qdel(query)

	return TRUE

/datum/controller/subsystem/custom_item/proc/save_icon(ckey, icon/icon_to_save, type, name)
	var/savefile/dummySave = get_dummy_savefile()
	WRITE_FILE(dummySave["dummy"], icon_to_save)
	var/iconData = dummySave.ExportText("dummy")

	var/datum/db_query/query = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("custom_items")] (ckey, name, dummy, type, created_datetime)
		VALUES (:ckey, :name, :dummy, :type, Now())
		ON DUPLICATE KEY UPDATE name = :name, dummy = :dummy, type = :type, created_datetime = Now()"}, list(
			"ckey" = ckey,
			"name" = name,
			"dummy" = iconData,
			"type" = type
		))

	if(!query.warn_execute())
		qdel(query)
		return

/datum/custom_item_datum
	var/name = "base"
	var/optional_min_num = 0
	var/optional_max_num = 0
	var/list/necessary_sprite_types = list("base")
	var/list/optional_sprite_types
	var/base_item

	var/item_name
	var/icon/item_icon

/datum/custom_item_datum/proc/validate_icon(icon/new_icon, mob/user)
	var/check_list = icon_states(new_icon)
	if(!length(check_list) || length(check_list) > 1)
		return FALSE
	if(ckey(check_list[1]) != ckey(user.ckey))
		return FALSE
	if((new_icon.Width() != 32) || (new_icon.Height() != 32))
		return FALSE

	return TRUE

/datum/custom_item_datum/proc/get_custom_dmi(mob/user, datum/custom_holder/holder)
	var/list/choosen_sprite_types = necessary_sprite_types.Copy()
	var/optional_num = LAZYLEN(optional_sprite_types)
	if(optional_num)
		if(optional_num == optional_min_num)
			choosen_sprite_types += optional_sprite_types
		var/list/choosen_optional = tgui_input_checkbox_list(user, "Выберите опциональные спрайты.", "Спрайты", optional_sprite_types)
		if(LAZYLEN(choosen_optional))
			choosen_sprite_types += choosen_optional

	for(var/sprite_type in choosen_sprite_types)
		var/sprite = input(user, "Выберите dmi файл для [get_type_desc(sprite_type)]", "Загрузка спрайта") as null|file
		if(!sprite)
			return FALSE

		if(copytext("[sprite]",-4) != ".dmi")
			to_chat(user, "Bad sprite file: [sprite]")
			return FALSE

		var/icon/new_icon = icon(sprite)

		if(!validate_icon(new_icon, user))
			to_chat(user, "Bad sprite file: [sprite]")
			qdel(new_icon)
			return FALSE

		LAZYADDASSOC(holder.icons, sprite_type, new_icon)

	return TRUE

/datum/custom_item_datum/proc/get_type_desc(type)
	return type

/datum/custom_item_datum/New(new_name, new_icon)
	item_name = new_name
	item_icon = new_icon

/datum/custom_item_datum/plushie
	name = "plushie"
	necessary_sprite_types = list("base", "inhand_l", "inhand_r")
	base_item = /obj/item/toy/plushie/custom

/datum/custom_holder
	var/name
	var/desc
	var/ckey
	var/custom_type
	var/list/icons

/datum/custom_holder/New(name, desc, ckey, custom_type)
	. = ..()
	src.name = name
	src.desc = desc
	src.ckey = ckey
	src.custom_type = custom_type

/obj/item/toy/plushie/custom
	name = "custom"
