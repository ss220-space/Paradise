SUBSYSTEM_DEF(custom_item)
	name = "Custom item"
	init_order = INIT_ORDER_CUSTOM_ITEM
	flags = SS_NO_FIRE
	ss_id = "custom_item"

	var/list/custom_gear_info

/datum/controller/subsystem/custom_item/Initialize(timeofday)
	if(!get_icons())
		return SS_INIT_FAILURE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/custom_item/proc/get_icons()
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT ckey, dummy FROM [format_table_name("custom_items")]"
	)
	if(!query.Execute())
		qdel(query)
		return FALSE

	var/savefile/dummySave = get_dummy_savefile()
	var/icon/icon

	while(query.NextRow())
		var/ckey = query.item[1]
		var/dummy = query.item[2]
		dummySave.ImportText("dummy", dummy)
		READ_FILE(dummySave["dummy"], icon)
		LAZYADDASSOC(custom_gear_info, ckey, icon)

	qdel(query)

	return TRUE

/datum/controller/subsystem/custom_item/proc/save_icon(ckey, icon/icon_to_save)
	var/savefile/dummySave = get_dummy_savefile()
	WRITE_FILE(dummySave["dummy"], icon_to_save)
	var/iconData = dummySave.ExportText("dummy")

	var/datum/db_query/query = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("custom_items")] (ckey, dummy, created_datetime)
		VALUES (:ckey, :dummy, Now())
		ON DUPLICATE KEY UPDATE dummy = :dummy, created_datetime = Now()"}, list(
			"ckey" = ckey,
			"dummy" = iconData,
		))

	if(!query.warn_execute())
		qdel(query)
		return

