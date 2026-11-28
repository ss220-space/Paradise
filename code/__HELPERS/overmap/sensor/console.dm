/proc/overmap_open_sensor_console(mob/user)
	if(!user)
		return
	for(var/datum/tgui/open_ui as anything in user.tgui_open_uis)
		if(istype(open_ui.src_object, /obj/machinery/computer/sensors))
			return open_ui.src_object
