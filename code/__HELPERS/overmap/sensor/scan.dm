/proc/overmap_write_dump_paper(obj/item/paper/sheet, list/uids, source_name)
	if(!sheet)
		return null
	sheet.overmap_scan_dump = uids?.Copy() || list()
	sheet.name = "дамп сенсоров"
	var/obj/machinery/computer/sensors/format_host = locate() in GLOB.sensor_computers
	if(format_host)
		sheet.info = format_host.format_sensor_dump_cipher(sheet.overmap_scan_dump, source_name)
	else
		sheet.info = "NT-OS SENSOR ARCHIVE<br>BLOCKS: [length(sheet.overmap_scan_dump)]"
	sheet.updateinfolinks()
	sheet.update_icon()
	return sheet
