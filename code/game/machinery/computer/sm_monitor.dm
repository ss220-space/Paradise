/obj/machinery/computer/sm_monitor
	name = "консоль мониторинга суперматерии"
	desc = "Crystal Integrity Monitoring System, connects to specially calibrated supermatter sensors to provide information on the status of supermatter-based engines."
	icon_keyboard = "power_key"
	icon_screen = "smmon_0"
	circuit = /obj/item/circuitboard/sm_monitor
	light_color = LIGHT_COLOR_DIM_YELLOW
	/// List of supermatters that we are going to send the data of.
	var/list/obj/machinery/power/supermatter_crystal/supermatters = list()
	/// Last status of the active supermatter for caching purposes
	var/last_status = SUPERMATTER_INACTIVE
	/// The supermatter which will send a notification to us if it's delamming.
	var/obj/machinery/power/supermatter_crystal/focused_supermatter

/obj/machinery/computer/sm_monitor/get_ru_names()
	return list(
		NOMINATIVE = "консоль мониторинга суперматерии",
		GENITIVE = "консоли мониторинга суперматерии",
		DATIVE = "консоли мониторинга суперматерии",
		ACCUSATIVE = "консоль мониторинга суперматерии",
		INSTRUMENTAL = "консолью мониторинга суперматерии",
		PREPOSITIONAL = "консоли мониторинга суперматерии"
	)

/obj/machinery/computer/sm_monitor/Initialize(mapload, obj/structure/computerframe/frame)
	. = ..()
	refresh()

/obj/machinery/computer/sm_monitor/Destroy()
	for(var/supermatter in supermatters)
		clear_supermatter(supermatter)
	return ..()

/obj/machinery/computer/sm_monitor/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/sm_monitor/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/sm_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosSupermatter", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/// Refreshes list of active supermatter crystals
/obj/machinery/computer/sm_monitor/proc/refresh()
	var/list/cached_supermatters = supermatters
	for(var/supermatter in cached_supermatters)
		clear_supermatter(supermatter)
	var/turf/user_turf = get_turf(ui_host())
	if(!user_turf)
		return
	for(var/obj/machinery/power/supermatter_crystal/sm as anything in SSmachines.get_by_type(/obj/machinery/power/supermatter_crystal))
		//Exclude Syndicate owned, Delaminating, not within coverage, not on a tile.
		if(!sm.include_in_cims || !isturf(sm.loc) || !(is_station_level(sm.z) || is_mining_level(sm.z) || sm.z == user_turf.z))
			continue
		cached_supermatters += sm
		RegisterSignal(sm, COMSIG_QDELETING, PROC_REF(clear_supermatter))

/obj/machinery/computer/sm_monitor/ui_static_data(mob/user)
	var/list/data = list()
	data["gas_metadata"] = sm_gas_data()
	return data

/obj/machinery/computer/sm_monitor/ui_data(mob/user)
	var/list/data = list()
	data["sm_data"] = list()
	for(var/obj/machinery/power/supermatter_crystal/sm as anything in supermatters)
		data["sm_data"] += list(sm.sm_ui_data())
	data["focus_uid"] = focused_supermatter?.UID()
	return data

/obj/machinery/computer/sm_monitor/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("PRG_refresh")
			refresh()
			return TRUE
		if("PRG_focus")
			var/focus_uid = params["focus_uid"]
			var/obj/machinery/power/supermatter_crystal/sm = locateUID(focus_uid)
			if(focused_supermatter == sm)
				unfocus_supermatter(sm)
			else
				focus_supermatter(sm)
			return TRUE

/*
/// Sends an SM delam alert to the computer if our focused supermatter is delaminating.
/// [var/obj/machinery/power/supermatter_crystal/focused_supermatter].
/obj/machinery/computer/sm_monitor/proc/send_alert()
	SIGNAL_HANDLER
	if(!computer.get_ntnet_status())
		return
	computer.alert_call(src, "Crystal delamination in progress!")
	alert_pending = TRUE
*/

/obj/machinery/computer/sm_monitor/proc/clear_supermatter(obj/machinery/power/supermatter_crystal/sm)
	SIGNAL_HANDLER
	supermatters -= sm
	if(focused_supermatter == sm)
		unfocus_supermatter()
	UnregisterSignal(sm, COMSIG_QDELETING)

/obj/machinery/computer/sm_monitor/proc/focus_supermatter(obj/machinery/power/supermatter_crystal/sm)
	if(sm == focused_supermatter)
		return
	if(focused_supermatter)
		unfocus_supermatter()
	//RegisterSignal(sm, COMSIG_SUPERMATTER_DELAM_ALARM, PROC_REF(send_alert))
	focused_supermatter = sm

/obj/machinery/computer/sm_monitor/proc/unfocus_supermatter()
	if(!focused_supermatter)
		return
	UnregisterSignal(focused_supermatter, COMSIG_SUPERMATTER_DELAM_ALARM)
	focused_supermatter = null

/obj/machinery/computer/sm_monitor/proc/get_status()
	. = SUPERMATTER_INACTIVE
	for(var/obj/machinery/power/supermatter_crystal/supermatter as anything in supermatters)
		. = max(., supermatter.get_status())

/obj/machinery/computer/sm_monitor/process()
	if(stat & (NOPOWER|BROKEN))
		return FALSE

	var/new_status = get_status()
	if(last_status != new_status)
		last_status = new_status
		icon_screen = "smmon_[last_status]"
		update_appearance()

	return TRUE
