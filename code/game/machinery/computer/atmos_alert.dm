/obj/machinery/computer/atmos_alert
	name = "atmospheric alert computer"
	desc = "Используется для доступа к атмосферным датчикам станции."
	circuit = /obj/item/circuitboard/atmos_alert
	icon_keyboard = "atmos_key"
	icon_screen = "alert:0"
	light_color = LIGHT_COLOR_CYAN
	/// List of alarms and their state in areas. This is sent to TGUI
	var/list/alarm_cache

/obj/machinery/computer/atmos_alert/Initialize(mapload)
	. = ..()
	alarm_cache = list()
	alarm_cache["priority"] = list()
	alarm_cache["minor"] = list()
	alarm_cache["mode"] = list()

/obj/machinery/computer/atmos_alert/process()
	alarm_cache = list()
	alarm_cache["priority"] = list()
	alarm_cache["minor"] = list()
	alarm_cache["mode"] = list()
	for(var/area/area in GLOB.all_areas)
		var/alarm_level = null
		for(var/obj/machinery/alarm/air_alarm in area.air_alarms)
			if(air_alarm.z != z)
				continue
			if(!istype(air_alarm))
				continue
			if(!air_alarm.report_danger_level)
				continue
			switch(air_alarm.alarm_area.atmosalm)
				if(ATMOS_ALARM_DANGER)
					alarm_level = "priority"
				if(ATMOS_ALARM_WARNING)
					if(isnull(alarm_level))
						alarm_level = "minor"
			if(!isnull(alarm_level))
				alarm_cache[alarm_level] += area.name
			if(air_alarm.mode != AALARM_MODE_FILTERING)
				alarm_cache["mode"][area.name] = GLOB.aalarm_modes["[air_alarm.mode]"]

	update_icon()

/obj/machinery/computer/atmos_alert/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/atmos_alert/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/atmos_alert/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosAlertConsole", name)
		ui.open()

/obj/machinery/computer/atmos_alert/ui_data(mob/user)
	return alarm_cache

/obj/machinery/computer/atmos_alert/update_icon_state()
	if(!length(alarm_cache)) // This happens if were mid init
		icon_screen = "alert:0"
		return ..()

	if(length(alarm_cache["priority"]))
		icon_screen = "alert:2"
	else if(length(alarm_cache["minor"]))
		icon_screen = "alert:1"
	else
		icon_screen = "alert:0"
	..()

/obj/machinery/computer/atmos_alert/old_frame
	icon = 'icons/obj/machines/computer3.dmi'
	icon_state = "frame-eng"
	icon_keyboard = "kb4"
