/datum/ui_module/atmos_alert/monitor
	var/select_monitor = FALSE
	var/obj/machinery/computer/atmos_alert/AAmonitor
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = ATMOS_FIRE_FREQ

/datum/ui_module/atmos_alert/monitor/digital
	select_monitor = TRUE

/datum/ui_module/atmos_alert/monitor/New()
	..()
	if(!select_monitor)
		AAmonitor = ui_host()

/datum/ui_module/atmos_alert/monitor/ui_data(mob/user)
	var/list/data = list()

	data["priority"] = list()
	for(var/zone in priority_alarms)
		data["priority"] |= zone
	data["minor"] = list()
	for(var/zone in minor_alarms)
		data["minor"] |= zone

	return data

/datum/ui_module/atmos_alert/monitor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AtmosAlert", name, 600, 600, master_ui, state)
		ui.open()

/datum/ui_module/atmos_alert/monitor/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("clear")
			var/zone = params["zone"]
			if(zone in priority_alarms)
				to_chat(usr, "<span class='notice'>Priority alarm for [zone] cleared.</span>")
				priority_alarms -= zone
				. = TRUE
			if(zone in minor_alarms)
				to_chat(usr, "<span class='notice'>Minor alarm for [zone] cleared.</span>")
				minor_alarms -= zone
				. = TRUE
