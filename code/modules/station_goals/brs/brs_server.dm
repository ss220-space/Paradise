//Server to control scanners and monitor the execution of the goal
/obj/item/circuitboard/brs_server
	name = "Сервер сканирирования разлома (Computer Board)"
	desc = "Плата для сбора сервера изучения сканирования разломов."
	build_path = /obj/machinery/brs_server
	icon_state = "cpuboard_super"
	board_type = "machine"
	origin_tech = "engineering=4;bluespace=3"
	req_components = list(
		/obj/item/stack/sheet/metal = 10,
		/obj/item/stack/sheet/glass = 5,
		/obj/item/stock_parts/capacitor/super = 10,
		/obj/item/stock_parts/scanning_module/phasic = 2,
		/obj/item/stack/cable_coil = 20
	)

/obj/machinery/brs_server
	name = "Сервер сканирования разлома"
	icon = 'icons/obj/machines/BRS/scanner_server.dmi'
	icon_state = "scan_server"
	anchored = TRUE
	density = TRUE
	luminosity = 1
	max_integrity = 350
	integrity_failure = 150

	use_power = IDLE_POWER_USE
	idle_power_usage = 4000
	active_power_usage = 12000

	/// Points needed to complete the station goal
	var/research_points = 0
	/// Points needed to "probe" a rift
	var/probe_points = 0

	/// One probe price
	var/points_per_probe = 500
	/// One probe price if the server is emagged
	var/points_per_probe_emagged = 250
	/// 0 <= chance <= 1, 0-never, 1-always
	var/probe_success_chance = 0.5
	///	0 <= chance <= 1, 0-never, 1-always
	var/probe_success_chance_emagged = 0.2

	var/research_points_on_probe_success = 100

	/// Needed for users to distinguish between servers
	var/id

	var/times_rift_scanned = 0
	var/goal_points_mined = 0
	var/probe_points_mined = 0

/obj/machinery/brs_server/Initialize(mapload)
	. = ..()

	// Assign an id
	var/list/existing_ids = list()
	for(var/obj/machinery/brs_server/server as anything in GLOB.bluespace_rifts_server_list)
		existing_ids += server.id
	for(var/possible_id in 1 to length(existing_ids))
		if(!(possible_id in existing_ids))
			id = possible_id
	if(!id)
		id = length(existing_ids) + 1
	name = "[name] \[#[id]\]"

	GLOB.bluespace_rifts_server_list.Add(src)
	new_component_parts()
	update_icon()

/obj/machinery/brs_server/Destroy()
	GLOB.bluespace_rifts_server_list.Remove(src)
	return ..()

/obj/machinery/brs_server/process()
	if(!times_rift_scanned)
		return
	
	research_points += goal_points_mined * (1 + log(times_rift_scanned))
	probe_points += probe_points_mined * (1 + log(times_rift_scanned))

	times_rift_scanned = 0
	goal_points_mined = 0
	probe_points_mined = 0

/obj/machinery/brs_server/proc/research_process(added_research_points, added_probe_points)
	research_points += added_research_points
	probe_points += added_probe_points

/obj/machinery/brs_server/update_icon()
	var/prefix = initial(icon_state)

	overlays.Cut()
	if(panel_open)
		overlays += image(icon, "[initial(icon_state)]-panel")

	if(stat & (BROKEN))
		icon_state = "[prefix]-broken"
		set_light(0)
		return
	if(stat & (NOPOWER))
		icon_state = prefix
		set_light(0)
		return
	if(emagged)
		icon_state = "[prefix]-on-emagged"
		set_light(l_range = 1, l_power = 1, l_color = COLOR_RED_LIGHT)
		return
	icon_state = "[prefix]-on"
	set_light(l_range = 1, l_power = 1, l_color = COLOR_BLUE_LIGHT)

/obj/machinery/brs_server/power_change()
	..()
	update_icon()

/obj/machinery/brs_server/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 80)

/obj/machinery/brs_server/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon()

/obj/machinery/brs_server/crowbar_act(mob/living/user, obj/item/I)
	if((!panel_open) || (flags & NODECONSTRUCT))
		return FALSE
	. = TRUE

	// Add a delay, as server's points will be lost after disassembly
	user.visible_message("[user] начина[pluralize_ru(user.gender, "ет", "ют")] разбирать [src].", "Вы начинаете разбирать [src].")
	if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume))
		return

	default_deconstruction_crowbar(user, I)

/obj/machinery/brs_server/welder_act(mob/user, obj/item/I)
	. = TRUE
	default_welder_repair(user, I)

/obj/machinery/brs_server/proc/new_component_parts()
	component_parts = list()

	component_parts += new /obj/item/circuitboard/brs_server(null)
	
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)

	for(var/i in 1 to 10)
		component_parts += new /obj/item/stock_parts/capacitor/super(null)

	component_parts += new /obj/item/stack/sheet/metal(null, 10)
	component_parts += new /obj/item/stack/sheet/glass(null, 5)
	component_parts += new /obj/item/stack/cable_coil(null, 20)

	RefreshParts()

/obj/machinery/brs_server/emag_act(mob/user)
	if(emagged)
		return
	emagged = TRUE
	points_per_probe = points_per_probe_emagged
	probe_success_chance = probe_success_chance_emagged
	playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
	update_icon()
	to_chat(user, span_warning("@?%!№@Протоколы безопасности сканнера перезаписаны@?%!№@"))

/obj/machinery/brs_server/emp_act(severity)
	if(!(stat & (BROKEN|NOPOWER)))
		flick_active()
	return ..()

/obj/machinery/brs_server/proc/flick_active()
	if(stat & (BROKEN|NOPOWER))
		return
	var/prefix = initial(icon_state)
	if(emagged)
		flick("[prefix]-act-emagged", src)
	else
		flick("[prefix]-act", src)

/obj/machinery/brs_server/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/brs_server/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/brs_server/attack_hand(mob/user)
	if(..())
		return TRUE
	
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	ui_interact(user)

/obj/machinery/brs_server/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BluespaceRiftServer", name, 570, 400)
		ui.open()

/obj/machinery/brs_server/ui_data(mob/user)
	var/list/data = list()

	data["pointsPerProbe"] = points_per_probe
	data["emagged"] = emagged

	data["goals"] = list()
	var/datum/station_goal/bluespace_rift/goal = locate() in SSticker.mode.station_goals
	var/rift_name = goal.rift.name
	data["goals"] += list(list(
		"riftId" = goal.UID(),
		"riftName" = rift_name,
		"targetResearchPoints" = goal.target_research_points,
		"researchPoints" = research_points,
		"probePoints" = probe_points,
		"rewardGiven" = goal.reward_given,
	))

	data["scanners"] = list()
	for(var/obj/machinery/power/brs_stationary_scanner/scanner in GLOB.bluespace_rifts_scanner_list)
		if(scanner.z != z)
			continue
		if(scanner.stat & (BROKEN|NOPOWER))
			continue
		data["scanners"] += list(list(
			"scannerId" = scanner.UID(),
			"scannerName" = scanner.name,
			"scanStatus" = scanner.scanning_status,
			"canSwitch" = 1,
			"switching" = scanner.switching,
		))
	for(var/obj/machinery/brs_portable_scanner/scanner in GLOB.bluespace_rifts_scanner_list)
		if(scanner.z != z)
			continue
		if(scanner.stat & (BROKEN|NOPOWER))
			continue
		data["scanners"] += list(list(
			"scannerName" = scanner.name,
			"scanStatus" = scanner.scanning_status,
			"canSwitch" = 0,
			"switching" = scanner.switching,
		))

	data["servers"] = list()
	for(var/obj/machinery/brs_server/server in GLOB.bluespace_rifts_server_list)
		if(server.z != z)
			continue
		if(server.stat & (BROKEN|NOPOWER))
			continue
		data["servers"] += list(list(
			"servName" = server.name,
			"servData" = list(
				"riftName" = rift_name,
				"probePoints" = probe_points,
			)
		))

	return data

/obj/machinery/brs_server/ui_act(action, list/params)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return

	switch(action)
		if("toggle_scanner")
			var/scanner_uid = params["scanner_id"]
			var/obj/machinery/power/brs_stationary_scanner/scanner = locateUID(scanner_uid)
			scanner.toggle()
			return TRUE
		if("probe")
			flick_active()
			var/goal_uid = params["rift_id"]
			var/datum/station_goal/bluespace_rift/goal = locateUID(goal_uid)
			probe(goal.rift)
			return TRUE
		if("reward")
			flick_active()
			var/goal_uid = params["rift_id"]
			var/datum/station_goal/bluespace_rift/goal = locateUID(goal_uid)
			if(goal.reward_given)
				return FALSE
			goal.rift.spawn_reward()
			goal.reward_given = TRUE
			visible_message(span_notice("Исследование завершено. Судя по индикации сервера, из разлома выпало что-то, что может представлять большую научную ценность."))
			return TRUE

/obj/machinery/brs_server/proc/probe(datum/bluespace_rift/rift)
	if(probe_points < points_per_probe)
		return

	use_power(active_power_usage)

	probe_points -= points_per_probe

	var/successful
	if(probe_success_chance == 0)
		successful = FALSE
	else if(rand() <= probe_success_chance)
		successful = TRUE
	else
		successful = FALSE

	if(successful)
		rift.probe(successful = TRUE)
		visible_message(span_notice("Судя по индикации сервера, зондирование прошло успешно. Из разлома удалось извлечь какой-то предмет."))
		research_points += research_points_on_probe_success
	else
		rift.probe(successful = FALSE)
		visible_message(span_warning("Судя по индикации сервера, зондирование спровоцировало изменение стабильности блюспейс-разлома. Это не хорошо."))