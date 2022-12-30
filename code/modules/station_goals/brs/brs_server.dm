//Сервер для контроля спутников
/obj/item/circuitboard/brs_server
	name = "Сервер сканирирования разлома (Computer Board)"
	build_path = /obj/machinery/brs_server
	icon_state = "cpuboard_super"
	origin_tech = "engineering=4;bluespace=3"
	req_components = list(
					/obj/item/stack/sheet/metal = 10,
					/obj/item/stack/sheet/glass = 5,
					/obj/item/stock_parts/capacitor/super = 10,
					/obj/item/stock_parts/scanning_module/phasic = 2,
					/obj/item/stack/cable_coil = 20
					)

/obj/machinery/brs_server
	name = "Сервер сканирирования разлома"
	icon = 'icons/obj/machines/BRS/scanner_server.dmi'
	icon_state = "scan_server"
	anchored = TRUE
	density = TRUE
	var/active = FALSE
	var/researchpoints = 0
	var/activate_sound = 'sound/effects/electheart.ogg'
	var/deactivate_sound = 'sound/effects/basscannon.ogg'
	//var/id = 0

/obj/machinery/brs_server/update_icon()
	var/prefix = initial(icon_state)
	if(stat & (BROKEN))
		icon_state = "[prefix]-b"
	else if(stat & (NOPOWER))
		icon_state = prefix
	else icon_state = active ? "[prefix]-act" : "[prefix]-on"

/obj/machinery/brs_server/Destroy()
	. = ..()
	//Удаляем сервер из списков общих серверов

/obj/machinery/brs_server/proc/change_active()
	active = !active
	if (active)
		playsound(loc, activate_sound, 100, 1)
	else
		playsound(loc, deactivate_sound, 100, 1)

/*
/obj/machinery/brs_server/process()
	if(stat & (BROKEN|NOPOWER))
		return FALSE
	//получаем данные
*/

//==========Взаимодействия========
/obj/machinery/brs_server/wrench_act(mob/living/user, obj/item/I)
	. = default_unfasten_wrench(user, I, 40)
	if(.)
		power_change()

/obj/machinery/brs_server/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/brs_server/screwdriver_act(mob/living/user, obj/item/I)
	. = default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	if(!.)
		return

	overlays.Cut()
	if(panel_open)
		overlays += image(icon, "[initial(icon_state)]-panel")

/obj/machinery/brs_server/crowbar_act(mob/living/user, obj/item/I)
	. = default_deconstruction_crowbar(user, I)

//Перезапись протоколов безопасности.
/obj/machinery/brs_server/proc/rewrite_protocol()
	emagged = TRUE
	playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
	update_icon()
	// сервер ломается/ускоряется?

/obj/machinery/brs_server/emag_act(mob/user)
	if(!emagged)
		rewrite_protocol()
		to_chat(user, "<span class='notice'>Протоколы безопасности сканнера перезаписаны.</span>")

/obj/machinery/brs_server/emp_act(severity)
	if(!emagged && prob(40 / severity))
		rewrite_protocol()



///obj/machinery/smartfridge  -- отсюда многое можно взять

//открываем ТГУИшку?
///obj/machinery/smartfridge/attackby(obj/item/O, var/mob/user)



/obj/machinery/brs_server/attack_ai(mob/user)
	return FALSE

/obj/machinery/brs_server/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/brs_server/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	//ui_interact(user)
	return ..()

/*
/obj/machinery/brs_server/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	user.set_machine(src)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Smartfridge", name, 500, 500)
		ui.open()
*/


/*
/obj/machinery/computer/brs_control
	name = "Сервер сканирования разлома"
	desc = "Используется для сбора и хранения данных сканирования разлома."
	circuit = /obj/item/circuitboard/computer/brs_control
	icon_screen = "accelerator"
	icon_keyboard = "accelerator_key"
	var/notice

/obj/machinery/computer/brs_control/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/machinery/computer/brs_control/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SatelliteControl", name, 475, 400)
		ui.open()

/obj/machinery/computer/brs_control/ui_data(mob/user)
	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/S in GLOB.machines)
		data["satellites"] += list(list(
			"id" = S.id,
			"active" = S.active,
			"mode" = S.mode
		))
	data["notice"] = notice

	var/datum/station_goal/rift_scanner/G = locate() in SSticker.mode.station_goals
	if(G)
		data["meteor_shield"] = 1
		data["meteor_shield_coverage"] = G.get_coverage()
		data["meteor_shield_coverage_max"] = G.coverage_goal
		data["meteor_shield_coverage_percentage"] = (G.get_coverage() / G.coverage_goal) * 100
	return data

/obj/machinery/computer/brs_control/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("toggle")
			toggle(text2num(params["id"]))
			. = TRUE

/obj/machinery/computer/brs_control/proc/toggle(id)
	for(var/obj/machinery/satellite/S in GLOB.machines)
		if(S.id == id && atoms_share_level(src, S))
			if(!S.toggle())
				notice = "Вы можете активировать только находящиеся в космосе спутники"
			else
				notice = null
*/
