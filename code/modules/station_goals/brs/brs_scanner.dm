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
	var/toggle = FALSE	//вывиднут/задвинут
	var/active = FALSE	//активность блюспейс-разлома

	var/toggle_sound = 'sound/effects/servostep.ogg'
	var/activate_sound = 'sound/effects/electheart.ogg'
	var/deactivate_sound = 'sound/effects/basscannon.ogg'
	var/alarm_sound = 'sound/effects/alert.ogg'

	var/critical_time = 5 SECONDS	//время до поломки в критических условиях и до его восстановления на привычные значения
	var/max_range = 10				//максимальное расстояния для сканирования

	var/counter_critical_time = 0		//счетчик времени до поломки
	var/obj/brs_rift/rift_for_scan = null	//концентрация на разломе для сканирования
	//var/id = 0

/obj/brs_rift/Initialize(mapload)
	. = ..()
	GLOB.poi_list |= src
	GLOB.bluespace_rifts_list.Add(src)

/obj/brs_rift/Destroy()
	GLOB.bluespace_rifts_list.Remove(src)
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/brs_scanner/process()
	if(stat & BROKEN)
		return FALSE
	if (!toggle)
		return FALSE

	if (rift_for_scan)
		var/dist = get_dist(src, rift_for_scan)
		if (!emagged)
			if (dist > max_range + rift_for_scan.force_sized)
				rift_for_scan = null
				change_active()
			else if (dist <= rift_for_scan.force_sized)
				critical_process()
			else
				scanner_process()
		else	//При ЕМАГе, возможно сканирование в любом радиусе. Вне его - критическая зона
			if (dist <= max_range + rift_for_scan.force_sized)
				scanner_process()
			else
				critical_process()
		return TRUE

	for (var/obj/brs_rift/rift in GLOB.bluespace_rifts_list)
		var/dist = get_dist(src, rift)
		if (dist <= max_range)
			change_active()
			rift_for_scan = rift
			break

/obj/machinery/brs_scanner/proc/critical_process()
	if (counter_critical_time + critical_time < world.time)	//!!!!ПРОВЕРИТЬ ЕСТЬ ЛИ ВОССТАНОВЛЕНИЕ
		counter_critical_time = 0
		message_admins("КРИТИЧЕСКИЙ ПОРОГ ВОССТАНОВЛЕН")

	if (counter_critical_time == 0)
		counter_critical_time = world.time + critical_time
		message_admins("Начат отсчет [counter_critical_time]/[world.time]")
	if (counter_critical_time < world.time)
		obj_break()
		anchored = FALSE
		message_admins("КРИТИЧЕСКИЙ ПОРОГ ПРОЙДЕН")
	else
		message_admins("Критическое значение [counter_critical_time]/[world.time]")
		playsound(loc, alarm_sound, 100, 1)

/obj/machinery/brs_scanner/proc/scanner_process()
	for (var/obj/machinery/brs_server/server in GLOB.bluespace_rifts_server_list)
		server.research_process(1)

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

//Взаимодействия
/obj/machinery/brs_scanner/wrench_act(mob/living/user, obj/item/I)
	if (!toggle)
		return FALSE

	. = default_unfasten_wrench(user, I, 40)
	update_icon()

	//!!!!!!!!!Стукает в конце при откручивании/прикручивании. Проверить с чем связано.

/obj/machinery/brs_scanner/attack_hand(mob/user)
	if(..())
		return TRUE
	if(!anchored)
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

//Перезапись протоколов безопасности.
/obj/machinery/brs_scanner/proc/rewrite_protocol()
	emagged = TRUE
	playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
	update_icon()
	//!!! сканнер отрубает протоколы и может в крит зонах находиться, но вдали от дальней зоны - он бахнет.

/obj/machinery/brs_scanner/emag_act(mob/user)
	if(!emagged)
		rewrite_protocol()
		to_chat(user, "<span class='notice'>Протоколы безопасности сканнера перезаписаны.</span>")

/obj/machinery/brs_scanner/emp_act(severity)
	if(!emagged && prob(40 / severity))
		rewrite_protocol()

//=============================
//Статичный сканер 3х3
//=============================

/obj/item/circuitboard/brs_scanner/brs_scanner_static
	name = "Статичный сканер разлома (Computer Board)"
	build_path = /obj/machinery/brs_scanner/brs_scanner_static
	icon_state = "bluespace_scannerplat"
	origin_tech = "engineering=6;bluespace=5"
	req_components = list(
					/obj/item/stack/sheet/metal = 30,
					/obj/item/stock_parts/capacitor/super = 8,
					/obj/item/stock_parts/micro_laser/ultra = 2,
					/obj/item/stock_parts/scanning_module/phasic = 10,
					/obj/item/stack/ore/bluespace_crystal = 4
					)

/obj/machinery/brs_scanner/brs_scanner_static
	name = "Статичный сканер разлома"
	icon = 'icons/obj/machines/BRS/scanner_static.dmi'
	icon_state = "scanner"
	critical_time = 60 SECONDS	//время до поломки в критических условиях
	max_range = 50	//максимальное расстояния для исследований
