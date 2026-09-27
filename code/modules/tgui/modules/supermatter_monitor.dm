/datum/ui_module/supermatter_monitor
	name = "Монитор суперматерии"
	/// List of supermatters that we are going to send the data of.
	var/list/obj/machinery/power/supermatter_crystal/supermatters = list()
	/// The supermatter which will send a notification to us if it's delamming.
	var/obj/machinery/power/supermatter_crystal/focused_supermatter

/datum/ui_module/supermatter_monitor/Destroy()
	for(var/obj/machinery/power/supermatter_crystal/sm as anything in supermatters)
		UnregisterSignal(sm, COMSIG_QDELETING)
	supermatters.Cut()
	unfocus_supermatter()
	return ..()

/datum/ui_module/supermatter_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosSupermatter", name)
		ui.open()

/datum/ui_module/supermatter_monitor/ui_static_data(mob/user)
	var/list/data = list()
	data["gas_metadata"] = sm_gas_data()
	return data

/datum/ui_module/supermatter_monitor/ui_data(mob/user)
	var/list/data = list()
	data["sm_data"] = list()
	for(var/obj/machinery/power/supermatter_crystal/sm as anything in supermatters)
		data["sm_data"] += list(sm.sm_ui_data())
	data["focus_uid"] = focused_supermatter?.UID()
	return data

/datum/ui_module/supermatter_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	switch(action)
		if("PRG_refresh")
			refresh()
		if("PRG_focus")
			var/obj/machinery/power/supermatter_crystal/sm = locateUID(params["focus_uid"])
			if(focused_supermatter == sm)
				unfocus_supermatter()
			else
				focus_supermatter(sm)

/// Refreshes list of active supermatter crystals
/datum/ui_module/supermatter_monitor/proc/refresh()
	for(var/obj/machinery/power/supermatter_crystal/sm as anything in supermatters)
		UnregisterSignal(sm, COMSIG_QDELETING)
	supermatters.Cut()
	var/turf/host_turf = get_turf(ui_host())
	if(!host_turf)
		unfocus_supermatter()
		return
	for(var/obj/machinery/power/supermatter_crystal/sm as anything in SSmachines.get_by_type(/obj/machinery/power/supermatter_crystal))
		//Exclude Syndicate owned, Delaminating, not within coverage, not on a tile.
		if(!sm.include_in_cims || !isturf(sm.loc) || !(is_station_level(sm.z) || is_mining_level(sm.z) || sm.z == host_turf.z))
			continue
		supermatters += sm
		RegisterSignal(sm, COMSIG_QDELETING, PROC_REF(clear_supermatter))
	if(!(focused_supermatter in supermatters))
		unfocus_supermatter()

/datum/ui_module/supermatter_monitor/proc/clear_supermatter(obj/machinery/power/supermatter_crystal/sm)
	SIGNAL_HANDLER
	supermatters -= sm
	if(focused_supermatter == sm)
		unfocus_supermatter()
	UnregisterSignal(sm, COMSIG_QDELETING)

/datum/ui_module/supermatter_monitor/proc/focus_supermatter(obj/machinery/power/supermatter_crystal/sm)
	if(!sm || sm == focused_supermatter)
		return
	unfocus_supermatter()
	focused_supermatter = sm
	RegisterSignal(sm, COMSIG_SUPERMATTER_DELAM_ALARM, PROC_REF(send_alert))

/datum/ui_module/supermatter_monitor/proc/unfocus_supermatter()
	if(!focused_supermatter)
		return
	UnregisterSignal(focused_supermatter, COMSIG_SUPERMATTER_DELAM_ALARM)
	focused_supermatter = null

/datum/ui_module/supermatter_monitor/proc/send_alert(obj/machinery/power/supermatter_crystal/sm)
	SIGNAL_HANDLER
	return

/datum/ui_module/supermatter_monitor/proc/get_status()
	. = SUPERMATTER_INACTIVE
	for(var/obj/machinery/power/supermatter_crystal/sm as anything in supermatters)
		. = max(., sm.get_status())

/datum/ui_module/supermatter_monitor/pda
	var/datum/data/pda/app/supermatter_monitor/app

/datum/ui_module/supermatter_monitor/pda/New(datum/data/pda/app/supermatter_monitor/app)
	..(app)
	src.app = app

/datum/ui_module/supermatter_monitor/pda/Destroy()
	app = null
	return ..()

/datum/ui_module/supermatter_monitor/pda/ui_host()
	return app.pda

/datum/ui_module/supermatter_monitor/pda/send_alert(obj/machinery/power/supermatter_crystal/sm)
	app.notify(span_boldwarning("Тревога! Целостность [sm.declent_ru(GENITIVE)] падает!"))
