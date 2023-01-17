//Scanners for researching rifts and transmitting data to servers
//=============================
//Portable Scanner 1x1
//=============================
/obj/item/circuitboard/brs_scanner
	name = "Портативный сканер разлома (Машинная Плата)"
	build_path = /obj/machinery/brs_scanner
	icon_state = "scannerplat"
	board_type = "machine"
	origin_tech = "engineering=4;bluespace=3"
	req_components = list(
					/obj/item/stack/sheet/metal = 5,
					/obj/item/stock_parts/capacitor/super = 2,
					/obj/item/stock_parts/micro_laser/ultra = 1,
					/obj/item/stock_parts/scanning_module/phasic = 5,
					/obj/item/stack/ore/bluespace_crystal = 1
					)

/obj/machinery/brs_scanner
	name = "Портативный сканер разлома"
	icon = 'icons/obj/machines/BRS/scanner_dynamic.dmi'
	icon_state = "scanner"
	anchored = FALSE
	density = FALSE
	luminosity = TRUE
	max_integrity = 300
	var/toggle = FALSE	// protrude/retract
	var/active = FALSE	// bluespace rift activity

	var/toggle_sound = 'sound/effects/servostep.ogg'
	var/activate_sound = 'sound/effects/electheart.ogg'
	var/deactivate_sound = 'sound/effects/basscannon.ogg'
	var/alarm_sound = 'sound/effects/alert.ogg'

	var/critical_time = 5 SECONDS	// time to failure in critical conditions and to its restoration to the usual values
	var/max_range = 10				// maximum scanning distance

	var/counter_critical_time = 0			// time to failure counter
	var/obj/brs_rift/rift_for_scan = null	// concentration on the rift to scan
	var/rift_range = 0						// Max. distances on the selected rift

	var/static/gid = 0
	var/id = 0

/obj/machinery/brs_scanner/dynamic_toggle
	anchored = TRUE
	density = TRUE
	toggle = TRUE

/obj/machinery/brs_scanner/Initialize(mapload)
	. = ..()
	update_icon()
	new_component_parts()
	id = gid++
	name = "[name] \[[id]\]"

/obj/machinery/brs_scanner/process()
	if(stat & BROKEN)
		return FALSE
	if (!toggle)
		return FALSE

	if (rift_for_scan)
		var/dist = get_dist(src, rift_for_scan)
		if (!emagged)
			if (dist > rift_range)
				rift_for_scan = null
				change_active()
			else if (dist <= rift_for_scan.force_sized)
				critical_process(dist)
			else
				scanner_process(dist)
		else	//With EMAG, it is possible to scan in any radius. Outside it is a critical zone
			if (dist <= rift_range)
				scanner_process(dist)
			else
				critical_process(dist)
		return TRUE
	else
		find_nearest_rift()

/obj/machinery/brs_scanner/proc/scanner_process(var/dist)
	var/temp_points = 0
	var/list/rifts_list = list()
	for (var/obj/machinery/brs_server/S in GLOB.bluespace_rifts_server_list)
		if(S.z != z)
			continue
		var/division = (1 - max(1, dist) / rift_range)
		var/points = 1 + round(10 * division)

		temp_points += points
		rifts_list.Add(S)

		//event creation process
		var/event_chance = 1 + round(2 * rift_for_scan.force_sized * max(1, length(rift_for_scan.related_rifts_list)) * division)
		if(prob(event_chance))
			rift_for_scan.event_process(FALSE, dist, rift_range)

	//division of points for all servers
	if(length(rifts_list))
		temp_points = min(1, round(temp_points / length(rifts_list)))
		for (var/obj/machinery/brs_server/S in rifts_list)
			S.research_process(temp_points)

/obj/machinery/brs_scanner/proc/critical_process(var/dist)
	//Restoration of the critical threshold
	if (counter_critical_time + critical_time * 2 < world.time)
		counter_critical_time = 0

	//Countdown start
	if (counter_critical_time == 0)
		counter_critical_time = world.time + critical_time

	//Passing critical threshold
	if (counter_critical_time < world.time)
		obj_break()
		anchored = FALSE
		density = FALSE
		toggle = FALSE
		rift_for_scan.event_process(TRUE, dist, rift_range)
		update_icon()
		var/fs = 1 * rift_for_scan.force_sized
		explosion(src.loc, 0, 0, 1*fs,  2*fs, flame_range =  3*fs, cause = "[src.name] critical rift explode")
	else
		playsound(loc, alarm_sound, 100, 1)

/obj/machinery/brs_scanner/update_icon()
	var/prefix = initial(icon_state)
	if (stat & BROKEN)
		icon_state = "[prefix]-broken"
		return

	if (anchored)
		if (toggle)
			if (active)
				if (emagged)
					icon_state = "[prefix]-act-emagged"
				else
					icon_state = "[prefix]-act"
			else
				icon_state = "[prefix]-on"
		else
			icon_state = "[prefix]-anchored"
	else
		icon_state = prefix

//Interactions, disassembly
/obj/machinery/brs_scanner/wrench_act(mob/living/user, obj/item/I)
	if (toggle)
		return FALSE

	. = default_unfasten_wrench(user, I, 40)
	update_icon()

/obj/machinery/brs_scanner/welder_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return
	if(!I.use_tool(src, user, 200, volume = I.tool_volume))
		return

	. = default_welder_repair(user, I)
	if(!.)
		return
	stat &= ~BROKEN
	obj_integrity = max_integrity

//Extending and retracting the d.scanner, activating the st.scanner
/obj/machinery/brs_scanner/attack_hand(mob/user)
	if(..())
		return TRUE
	if(!anchored)
		to_chat(user, "<span class='warning'>Протоколы безопасности: Активация сканнера невозможна, сканер не прикручен и не зафиксирован.</span>")
		return FALSE
	if(do_after(user, 20, target = src))
		playsound(loc, toggle_sound, 100, 1)
		density = !density
		toggle = !toggle
		if (toggle)
			START_PROCESSING(SSobj, src)
			find_nearest_rift()
		else
			STOP_PROCESSING(SSobj, src)
		update_icon()
	return TRUE

//Rewriting security protocols
/obj/machinery/brs_scanner/proc/rewrite_protocol()
	emagged = TRUE
	playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
	update_icon()

/obj/machinery/brs_scanner/emag_act(mob/user)
	if(!emagged)
		rewrite_protocol()
		to_chat(user, "<span class='warning'>@?%!№@Протоколы безопасности сканнера перезаписаны@?%!№@</span>")

/obj/machinery/brs_scanner/emp_act(severity)
	if(!emagged && prob(40 / severity))
		rewrite_protocol()

/obj/machinery/brs_scanner/proc/change_active()
	active = !active
	if (active)
		playsound(loc, activate_sound, 100, 1)
		setDir(get_dir(src, rift_for_scan))
	else
		playsound(loc, deactivate_sound, 100, 1)
	update_icon()

/obj/machinery/brs_scanner/proc/find_nearest_rift()
	var/obj/brs_rift/min_rift
	var/min_dist = max_range*2
	for (var/obj/brs_rift/rift in GLOB.bluespace_rifts_list)
		if(rift.z != z)
			continue
		var/dist = get_dist(src, rift)
		var/temp_range = max_range + rift.force_sized
		if (dist <= temp_range && dist <= min_dist)
			min_rift = rift
			min_dist = dist
		else
			continue

	rift_for_scan = min_rift
	if(rift_for_scan)
		rift_range = max_range + rift_for_scan.force_sized
		change_active()
		return TRUE
	return FALSE

// Composite Components
/obj/machinery/brs_scanner/proc/new_component_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/brs_scanner(null)

	component_parts += new /obj/item/stack/sheet/metal(null, 5)
	component_parts += new /obj/item/stack/ore/bluespace_crystal(null, 1)

	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)

	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)

	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	RefreshParts()

//=============================
// Static Scanner 3x3
//=============================

/obj/item/circuitboard/brs_scanner/s_static
	name = "Статичный сканер разлома (Машинная Плата)"
	build_path = /obj/machinery/brs_scanner/s_static
	icon_state = "bluespace_scannerplat"
	origin_tech = "engineering=6;bluespace=5"
	req_components = list(
					/obj/item/stack/sheet/metal = 30,
					/obj/item/stock_parts/capacitor/super = 8,
					/obj/item/stock_parts/micro_laser/ultra = 2,
					/obj/item/stock_parts/scanning_module/phasic = 10,
					/obj/item/stack/ore/bluespace_crystal = 4
					)

/obj/machinery/brs_scanner/s_static
	name = "Статичный сканер разлома"
	icon = 'icons/obj/machines/BRS/scanner_static.dmi'
	icon_state = "scanner"
	pixel_x = -32
	pixel_y = -32
	anchored = TRUE
	density = TRUE
	max_integrity = 500
	critical_time = 30 SECONDS	//time to failure under critical conditions
	max_range = 50	//maximum research distance

/obj/machinery/brs_scanner/s_static/toggle
	toggle = TRUE

/obj/machinery/brs_scanner/s_static/process()
	. = ..()
	if (!.)
		return

	if (rift_for_scan)
		setDir(get_dir(src, rift_for_scan))

/obj/machinery/brs_scanner/s_static/update_icon()
	var/prefix = initial(icon_state)
	if (stat & BROKEN)
		icon_state = "[prefix]-broken"
		return

	if (toggle && !active)
		icon_state = "[prefix]-act"
	else
		icon_state = prefix

//Interactions
/obj/machinery/brs_scanner/s_static/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>Сканер статичен и не может быть откручен.</span>")

/obj/machinery/brs_scanner/s_static/screwdriver_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='warning'>Панель заблокирована протоколом безопасности.</span>")
		return

	to_chat(user, "<span class='notice'>[anchored ? "От" : "За"]кручиваю панель-блокатор [name].</span>")
	if(!I.use_tool(src, user, 200, volume = I.tool_volume))
		return

	. = default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	if(!.)
		return
	to_chat(user, "<span class='notice'>Панель-блокатор [name] [anchored ? "от" : "за"]кручена..</span>")
	overlays.Cut()
	if(panel_open)
		overlays += image(icon, "[initial(icon_state)]-panel")

/obj/machinery/brs_scanner/s_static/crowbar_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='warning'>Панель заблокирована протоколом безопасности.</span>")
		return
	to_chat(user, "<span class='notice'>Начат процесс разборки [name] на составные компоненты.</span>")
	if(!I.use_tool(src, user, 400, volume = I.tool_volume))
		return

	. = default_deconstruction_crowbar(user, I)
	if(!.)
		return
	to_chat(user, "<span class='notice'>[name] разобран на составные компоненты.</span>")

// Composite Components
/obj/machinery/brs_scanner/s_static/new_component_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/brs_scanner/s_static(null)

	component_parts += new /obj/item/stack/sheet/metal(null, 30)
	component_parts += new /obj/item/stack/ore/bluespace_crystal(null, 4)

	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)

	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)

	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	RefreshParts()
