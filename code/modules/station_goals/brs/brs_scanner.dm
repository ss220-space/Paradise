//Сканеры для исследования разломов и передачи данных на сервера
//=============================
//Портативный сканер 1х1
//=============================
/obj/item/circuitboard/brs_scanner
	name = "Портативный сканер разлома (Computer Board)"
	build_path = /obj/machinery/brs_scanner
	icon_state = "scannerplat"
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
	var/toggle = FALSE	//вывиднут/задвинут
	var/active = FALSE	//активность блюспейс-разлома

	var/toggle_sound = 'sound/effects/servostep.ogg'
	var/activate_sound = 'sound/effects/electheart.ogg'
	var/deactivate_sound = 'sound/effects/basscannon.ogg'
	var/alarm_sound = 'sound/effects/alert.ogg'

	var/critical_time = 5 SECONDS	//время до поломки в критических условиях и до его восстановления на привычные значения
	var/max_range = 10				//максимальное расстояния для сканирования

	var/counter_critical_time = 0			//счетчик времени до поломки
	var/obj/brs_rift/rift_for_scan = null	//концентрация на разломе для сканирования
	var/rift_range = 0						//макс. расстояния на выбранном разломе
	//var/id = 0

/obj/machinery/brs_scanner/dynamic_toggle
	anchored = TRUE
	density = TRUE
	toggle = TRUE

/obj/machinery/brs_scanner/Initialize(mapload)
	. = ..()
	update_icon()
	new_component_parts()

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
		else	//При ЕМАГе, возможно сканирование в любом радиусе. Вне его - критическая зона
			if (dist <= rift_range)
				scanner_process(dist)
			else
				critical_process(dist)
		return TRUE

	for (var/obj/brs_rift/rift in GLOB.bluespace_rifts_list)
		var/dist = get_dist(src, rift)
		var/temp_range = max_range + rift.force_sized
		if (dist <= temp_range)
			change_active()
			rift_for_scan = rift
			rift_range = temp_range
			return TRUE

/obj/machinery/brs_scanner/proc/scanner_process(var/dist)
	for (var/obj/machinery/brs_server/server in GLOB.bluespace_rifts_server_list)
		var/points = 1 + round(10 * (1 - dist / rift_range))
		message_admins("Получены очки: [points]")
		server.research_process(points)
		if(prob(round(rift_for_scan.force_sized * rift_range/dist)))
			rift_for_scan.event_process(FALSE, dist)

/obj/machinery/brs_scanner/proc/critical_process(var/dist)
	//Восстановление критического порога
	if (counter_critical_time + critical_time * 2 < world.time)
		counter_critical_time = 0

	//Начало отсчета
	if (counter_critical_time == 0)
		counter_critical_time = world.time + critical_time

	//Прохождение критического порога
	if (counter_critical_time < world.time)
		obj_break()
		anchored = FALSE
		density = FALSE
		toggle = FALSE
		rift_for_scan.event_process(TRUE, dist)
		update_icon()
		var/fs = 1 * rift_for_scan.force_sized
		explosion(src.loc, 0, 0, 1*fs,  2*fs, flame_range =  3*fs, cause = "[src.name] critical rift explode")
	else
		playsound(loc, alarm_sound, 100, 1)

/obj/machinery/brs_scanner/proc/change_active()
	active = !active
	if (active)
		playsound(loc, activate_sound, 100, 1)
	else
		playsound(loc, deactivate_sound, 100, 1)
	update_icon()

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

//Взаимодействия, разбор
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
		else
			STOP_PROCESSING(SSobj, src)
		update_icon()

// Составные компоненты
/obj/machinery/brs_scanner/proc/new_component_parts()
	component_parts = list()
	var/obj/item/circuitboard/brs_scanner/board = new(null)
	for (var/obj/item/stock_parts/component in board.req_components)
		component_parts += new component(null)
	component_parts += board
	component_parts += new /obj/item/stack/sheet/metal(null, 5)
	component_parts += new /obj/item/stack/ore/bluespace_crystal(null, 1)
	RefreshParts()

//Перезапись протоколов безопасности.
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

//=============================
//Статичный сканер 3х3
//=============================

/obj/item/circuitboard/brs_scanner/s_static
	name = "Статичный сканер разлома (Computer Board)"
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
	critical_time = 30 SECONDS	//время до поломки в критических условиях
	max_range = 50	//максимальное расстояния для исследований

/obj/machinery/brs_scanner/s_static/toggle
	toggle = TRUE

/obj/machinery/brs_scanner/s_static/process()
	. = ..()
	if (!.)
		return

	message_admins("Дошел до скана")
	if (rift_for_scan)
		message_admins("Сканирует")
		setDir(get_dir(src, rift_for_scan))	//even if you can't shoot, follow the target

/obj/machinery/brs_scanner/s_static/update_icon()
	var/prefix = initial(icon_state)
	if (stat & BROKEN)
		icon_state = "[prefix]-broken"
		return

	if (toggle && !active)
		icon_state = "[prefix]-act"
	else
		icon_state = prefix

//Взаимодействия
/obj/machinery/brs_scanner/s_static/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>Сканер статичен и не может быть откручен.</span>")

/obj/machinery/brs_scanner/s_static/screwdriver_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='notice'>Панель заблокирована протоколом безопасности.</span>")
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
		to_chat(user, "<span class='notice'>Панель заблокирована протоколом безопасности.</span>")
		return
	to_chat(user, "<span class='notice'>Начат процесс разборки [name] на составные компоненты.</span>")
	if(!I.use_tool(src, user, 400, volume = I.tool_volume))
		return

	. = default_deconstruction_crowbar(user, I)
	if(!.)
		return
	to_chat(user, "<span class='notice'>[name] разобран на составные компоненты.</span>")

// Составные компоненты
/obj/machinery/brs_scanner/s_static/new_component_parts()
	component_parts = list()
	var/obj/item/circuitboard/brs_scanner/s_static/board = new(null)
	for (var/obj/item/stock_parts/component in board.req_components)
		component_parts += new component(null)
	component_parts += board
	component_parts += new /obj/item/stack/sheet/metal(null, 30)
	component_parts += new /obj/item/stack/ore/bluespace_crystal(null, 4)
	RefreshParts()
