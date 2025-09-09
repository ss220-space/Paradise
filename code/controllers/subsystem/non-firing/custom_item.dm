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
	var/possible_icon_states
	var/necessary_icon_states
	var/base_item

	var/item_name
	var/icon/item_icon

/datum/custom_item_datum/proc/validate_icon(icon/new_icon)
	var/check_list = icon_states(new_icon)
	if(length(check_list - (check_list & possible_icon_states)))
		return FALSE
	if(length(necessary_icon_states - (check_list & necessary_icon_states)))
		return FALSE
	if((new_icon.Width() != 32) || (new_icon.Height() != 32))
		return FALSE

	return TRUE

/datum/custom_item_datum/New(new_name, new_icon)
	item_name = new_name
	item_icon = new_icon

/datum/custom_item_datum/plushie
	name = "plushie"
	possible_icon_states = list("plushie")
	necessary_icon_states = list("plushie")
	base_item = /obj/item/toy/plushie/custom

/obj/item/toy/plushie/custom
	name = "custom"
