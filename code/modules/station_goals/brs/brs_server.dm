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
	luminosity = TRUE
	max_integrity = 500
	var/active = FALSE
	var/research_points = 0			// Research points for the target
	var/roulette_points = 0			// Roulette Points Event/Reward
	var/roulette_points_price = 500	// Roulette game price
	var/emagged_prob_division = 5	// For division roulette points
	var/activate_sound = 'sound/effects/electheart.ogg'
	var/deactivate_sound = 'sound/effects/basscannon.ogg'

	var/research_time = 10 SECONDS		// time for the process of learning "active animation"
	var/counter_research_time = 0		// counter until animation completes

	var/static/gid = 0
	var/id = 0

/obj/machinery/brs_server/Initialize(mapload)
	. = ..()
	GLOB.bluespace_rifts_server_list.Add(src)
	GLOB.poi_list |= src
	update_icon()
	new_component_parts()
	id = gid++
	name = "[name] \[[id]\]"

/obj/machinery/brs_server/Destroy()
	GLOB.bluespace_rifts_server_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/machinery/brs_server/process()
	if (active && counter_research_time < world.time)
		change_active()

/obj/machinery/brs_server/proc/research_process(var/points)
	if (!active)
		change_active()
	research_points += points
	roulette_points += points
	counter_research_time = world.time + research_time

/obj/machinery/brs_server/proc/change_active()
	active = !active
	if (active)
		playsound(loc, activate_sound, 100, 1)
	else
		playsound(loc, deactivate_sound, 100, 1)
	update_icon()

/obj/machinery/brs_server/update_icon()
	var/prefix = initial(icon_state)
	if(stat & (BROKEN))
		icon_state = "[prefix]-broken"
		return
	if(stat & (NOPOWER))
		icon_state = prefix
		return
	if(emagged)
		icon_state = active ? "[prefix]-act-emagged" : "[prefix]-on-emagged"
	else
		icon_state = active ? "[prefix]-act" : "[prefix]-on"

//==========Interactions========
/obj/machinery/brs_server/wrench_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='notice'>Болты заблокированы протоколом безопасности.</span>")
		return
	. = default_unfasten_wrench(user, I, 80)
	if(.)
		power_change()

/obj/machinery/brs_server/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/brs_server/screwdriver_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='warning'>Панель заблокирована протоколом безопасности.</span>")
		return

	to_chat(user, "<span class='notice'>[anchored ? "От" : "За"]кручиваю панель-блокатор [name].</span>")
	if(!I.use_tool(src, user, 120, volume = I.tool_volume))
		return

	. = default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	if(!.)
		return
	to_chat(user, "<span class='notice'>Панель-блокатор [name] [anchored ? "от" : "за"]кручена..</span>")
	overlays.Cut()
	if(panel_open)
		overlays += image(icon, "[initial(icon_state)]-panel")

/obj/machinery/brs_server/crowbar_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='warning'>Панель заблокирована протоколом безопасности.</span>")
		return
	to_chat(user, "<span class='notice'>Начат процесс разборки [name] на составные компоненты.</span>")
	if(!I.use_tool(src, user, 200, volume = I.tool_volume))
		return

	. = default_deconstruction_crowbar(user, I)
	if(!.)
		return
	to_chat(user, "<span class='notice'>[name] разобран на составные компоненты.</span>")

/obj/machinery/brs_server/welder_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return
	if(!I.use_tool(src, user, 200, volume = I.tool_volume))
		return

	. = default_welder_repair(user, I)
	if(!.)
		return
	stat &= ~BROKEN
	obj_integrity = max_integrity

// Composite Components
/obj/machinery/brs_server/proc/new_component_parts()
	component_parts = list()
	var/obj/item/circuitboard/brs_server/board = new(null)
	for (var/obj/item/stock_parts/component in board.req_components)
		component_parts += new component(null)
	component_parts += board
	component_parts += new /obj/item/stack/sheet/metal(null, 10)
	component_parts += new /obj/item/stack/sheet/glass(null, 5)
	component_parts += new /obj/item/stack/cable_coil(null, 20)

	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)

	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	RefreshParts()

// Rewriting security protocols
/obj/machinery/brs_server/proc/rewrite_protocol()
	emagged = TRUE
	playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
	update_icon()
	roulette_points_price = emagged ? round(roulette_points_price / emagged_prob_division) : initial(roulette_points_price)


/obj/machinery/brs_server/emag_act(mob/user)
	if(!emagged)
		rewrite_protocol()
		to_chat(user, "<span class='warning'>@?%!№@Протоколы безопасности сканнера перезаписаны@?%!№@</span>")

/obj/machinery/brs_server/emp_act(severity)
	if(!emagged && prob(40 / severity))
		rewrite_protocol()

/obj/machinery/brs_server/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/brs_server/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/brs_server/attack_hand(mob/user)
	if(..())
		return TRUE

	if(stat & (BROKEN|NOPOWER))
		return

	ui_interact(user)

// Interface
/obj/machinery/brs_server/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "BluespaceRiftServer", name, 475, 400)
		ui.open()

/obj/machinery/brs_server/ui_data(mob/user)
	var/list/data = list()

	var/datum/station_goal/brs/G = locate() in SSticker.mode.station_goals
	if(G)
		data["brs_can_give_reward"] = G.check_can_give_reward()
		data["brs_server_points_goal"] = G.get_max_server_points_goal()
		data["brs_server_points_goal_max"] = G.scanner_goal
		data["brs_server_points_goal_percentage"] = (G.get_max_server_points_goal() / G.scanner_goal) * 100

		data["roulette_points"] = roulette_points
		data["roulette_points_price"] = roulette_points_price
		data["roulette_points_percentage"] = (roulette_points / roulette_points_price) * 100

	data["servers"] = list()
	for(var/obj/machinery/brs_server/S in GLOB.bluespace_rifts_server_list)
		if(S.z != z)
			continue
		data["servers"] += list(list(
			"id" = S.id,
			"stat" = S.stat,
			"active" = S.active,
			"points" = S.research_points
		))

	data["scanners"] = list()
	for(var/obj/machinery/brs_scanner/S in GLOB.machines)
		if(S.z != z)
			continue
		data["scanners"] += list(list(
			"id" = S.id,
			"stat" = S.stat,
			"toggle" = S.toggle,
			"active" = S.active
		))

	return data

/obj/machinery/brs_server/ui_act(action, params)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return

	var/datum/station_goal/brs/G = locate() in SSticker.mode.station_goals
	if(!G)
		return FALSE

	var/mob/user = usr
	add_fingerprint(user)

	switch(action)
		if("give_reward")
			if(G.check_can_give_reward())
				give_reward(src.loc)
				G.is_give_reward = TRUE
				playsound(loc, 'sound/machines/chime.ogg', 100, 1)
				visible_message("<span class='notice'>Исследование завершено.</span>")
				. = TRUE
			else
				playsound(loc, 'sound/machines/buzz-two.ogg', 100, 1)
				visible_message("<span class='warning'>Результат исследований уже был получен!</span>")

		//For research points, we give a chance to try your luck and it is POSSIBLE to get a good thing or stimulate events
		if("luck")
			if(roulette_points >= roulette_points_price)
				roulette_points -= roulette_points_price
				if(prob(round(50 / emagged ? round(emagged_prob_division/2) : 1)))
					var/turf/T
					for(var/obj/brs_rift/rift in G.rifts_list)
						if(prob(70))
							T = rift.loc
					give_random_reward(T ? T : src.loc)
					playsound(loc, 'sound/machines/chime.ogg', 100, 1)
					visible_message("<span class='notice'>Разлом положительно реагирует на стимулирующее вмешательство!</span>")

				else
					playsound(loc, 'sound/machines/buzz-two.ogg', 100, 1)
					for(var/obj/brs_rift/rift in G.rifts_list)
						rift.event_process()
					visible_message("<span class='warning'>Разлом негативно реагирует на стимулирующее вмешательство!</span>")

